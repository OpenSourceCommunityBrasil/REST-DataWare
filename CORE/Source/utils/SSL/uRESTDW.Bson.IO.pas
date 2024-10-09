unit uRESTDW.Bson.IO;

{$SCOPEDENUMS ON}

(*< JSON and BSON reading and writing.

  @bold(Quick Start)

  Consider this JSON document:

  @preformatted(
    { "x" : 1,
      "y" : 2,
      "z" : [ 3.14, true] }
  )

  You can serialize it manually to BSON like this:

  <source>
  var
    Writer: IgoBsonWriter;
    Bson: TBytes;
  begin
    Writer := TRESTDWBsonWriter.Create;
    Writer.WriteStartDocument;

    Writer.WriteName('x');
    Writer.WriteInt32(1);

    Writer.WriteInt32('y', 2); // Writes name and value in single call

    Writer.WriteName('z');
    Writer.WriteStartArray;
    Writer.WriteDouble(3.14);
    Writer.WriteBoolean(True);
    Writer.WriteEndArray;

    Writer.WriteEndDocument;

    Bson := Writer.ToBson;
  end;
  </source>

  Likewise, you can serialize to JSON by using the IgoJsonWriter interface
  instead.

  You can also manually deserialize by using the IgoBsonReader and IgoJsonReader
  interfaces. However, these are a bit more complicated to use since you don't
  know the deserialized BSON types in advance.

  You can look at the unit tests in the unit RESTDW.Data.Bson.IO.Tests
  for examples of manual serialization and deserialization. *)

{$INCLUDE 'uRESTDW.inc'}

interface

uses
  {$IFNDEF FPC}
   System.Classes,
   System.SysUtils,
  {$ELSE}
   Classes,
   SysUtils,
   StreamEX,
   Math,
  {$ENDIF}
  uRESTDW.Bson;

{$IFDEF FPC}
ResourceString
 SArgumentNil = 'Argument must not be nil';
{$ENDIF}

type
  { Type of exception that is raised when parsing an invalid JSON source. }
  EgoJsonParserError = class(Exception)
  {$REGION 'Internal Declarations'}
  private
    FLineNumber: Integer;
    FColumnNumber: Integer;
    FPosition: Integer;
  {$WARNINGS OFF}
  private
    constructor Create(const AMsg: String; const ALineNumber,
      AColumnNumber, APosition: Integer);
  {$WARNINGS ON}
  {$ENDREGION 'Internal Declarations'}
  public
    { The line number of the error in the source text, starting at 1. }
    property LineNumber: Integer read FLineNumber;

    { The column number of the error in the source text, starting at 1. }
    property ColumnNumber: Integer read FColumnNumber;

    { The position of the error in the source text, starting at 0.
      The position is the offset (in characters) from the beginning of the
      text. }
    property Position: Integer read FPosition;
  end;

type
  { State of a IgoBsonBaseWriter }
  TRESTDWBsonWriterState = (
    { Initial state }
    Initial,

    { The writer is positioned to write a name }
    Name,

    { The writer is positioned to write a value }
    Value,

    { The writer is positioned to write a scope document (call
      WriteStartDocument to start writing the scope document). }
    ScopeDocument,

    { The writer is done }
    Done,

    { The writer is closed }
    Closed);

type
  { State of a IgoBsonBaseReader }
  TRESTDWBsonReaderState = (
    { Initial state }
    Initial,

    { The reader is positioned at the type of an element or value }
    &Type,

    { The reader is positioned at the name of an element }
    Name,

    { The reader is positioned at the value }
    Value,

    { The reader is positioned at a scope document }
    ScopeDocument,

    { The reader is positioned at the end of a document }
    EndOfDocument,

    { The reader is positioned at the end of an array }
    EndOfArray,

    { The reader has finished reading a document }
    Done,

    { The reader is closed }
    Closed);

type
  { Used internally by BSON/JSON readers and writers to represent the current
    context. }
  TRESTDWBsonContextType = (
    { The top level of a BSON document }
    TopLevel,

    { A (possible embedded) BSON document }
    Document,

    { A BSON array }
    &Array,

    { A JavaScript w/Scope BSON value }
    JavaScriptWithScope,

    { The scope document of a JavaScript w/Scope BSON value }
    ScopeDocument);

type
  { Base interface for IgoBsonWriter, IgoJsonWriter and IgoBsonDocumentWriter }
  IgoBsonBaseWriter = interface
  ['{4525DC0D-C54E-47B2-85BE-4C09A8F5DF54}']
    {$REGION 'Internal Declarations'}
    function GetState: TRESTDWBsonWriterState;
    {$ENDREGION 'Internal Declarations'}

    { Writes a BSON value.

      Parameters:
        AValue: the BSON value to write.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
        True). }
    procedure WriteValue(const AValue: TRESTDWBsonValue);

    { Writes a BSON binary.

      Parameters:
        AValue: the BSON binary to write.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
        True). }
    procedure WriteBinaryData(const AValue: TRESTDWBsonBinaryData);

    { Writes a BSON Regular Expression.

      Parameters:
        AValue: the BSON Regular Expression to write.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
        True). }
    procedure WriteRegularExpression(const AValue: TRESTDWBsonRegularExpression); overload;

    { Writes both an element name and a BSON Regular Expression.

      Parameters:
        AName: the element name.
        AValue: the BSON Regular Expression to write.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
        True). }
    procedure WriteRegularExpression(const AName: String; const AValue: TRESTDWBsonRegularExpression); overload;

    { Writes the name of an element.

      Parameters:
        AName: the element name. }
    procedure WriteName(const AName: String);

    { Writes a Boolean value.

      Parameters:
        AValue: the Boolean value. }
    procedure WriteBoolean(const AValue: Boolean); overload;

    { Writes a name/value pair with a Boolean value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Boolean value. }
    procedure WriteBoolean(const AName: String; const AValue: Boolean); overload;

    { Writes a 32-bit Integer value.

      Parameters:
        AValue: the Integer value. }
    procedure WriteInt32(const AValue: Integer); overload;

    { Writes a name/value pair with a 32-bit Integer value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Integer value. }
    procedure WriteInt32(const AName: String; const AValue: Integer); overload;

    { Writes a 64-bit Integer value.

      Parameters:
        AValue: the Integer value. }
    procedure WriteInt64(const AValue: Int64); overload;

    { Writes a name/value pair with a 64-bit Integer value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Integer value. }
    procedure WriteInt64(const AName: String; const AValue: Int64); overload;

    { Writes a Double value.

      Parameters:
        AValue: the Double value. }
    procedure WriteDouble(const AValue: Double); overload;

    { Writes a name/value pair with a Double value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Double value. }
    procedure WriteDouble(const AName: String; const AValue: Double); overload;

    { Writes a String value.

      Parameters:
        AValue: the String value. }
    procedure WriteString(const AValue: String); overload;

    { Writes a name/value pair with a String value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the String value. }
    procedure WriteString(const AName, AValue: String); overload;

    { Writes a DateTime value.

      Parameters:
        AMillisecondsSinceEpoch: the number of UTC milliseconds since the
          Unix epoch }
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); overload;

    { Writes a name/value pair with a DateTime value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AMillisecondsSinceEpoch: the number of UTC milliseconds since the
          Unix epoch }
    procedure WriteDateTime(const AName: String; const AMillisecondsSinceEpoch: Int64); overload;

    { Writes a byte array as binary data of sub type Binary

      Parameters:
        ABytes: the bytes to write }
    procedure WriteBytes(const AValue: TBytes); overload;

    { Writes a name/value pair with binary date.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        ABytes: the bytes to write }
    procedure WriteBytes(const AName: String; const AValue: TBytes); overload;

    { Writes a Timestamp value.

      Parameters:
        AValue: the Timestamp value. }
    procedure WriteTimestamp(const AValue: Int64); overload;

    { Writes a name/value pair with a Timestamp value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Timestamp value. }
    procedure WriteTimestamp(const AName: String; const AValue: Int64); overload;

    { Writes an ObjectId value.

      Parameters:
        AValue: the ObjectId value. }
    procedure WriteObjectId(const AValue: TRESTDWObjectId); overload;

    { Writes a name/value pair with an ObjectId value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the ObjectId value. }
    procedure WriteObjectId(const AName: String; const AValue: TRESTDWObjectId); overload;

    { Writes a JavaScript.

      Parameters:
        ACode: the JavaScript code. }
    procedure WriteJavaScript(const ACode: String); overload;

    { Writes a name/value pair with a JavaScript.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        ACode: the JavaScript code. }
    procedure WriteJavaScript(const AName, ACode: String); overload;

    { Writes a JavaScript with scope.

      Parameters:
        ACode: the JavaScript code.

      @bold(Note): call WriteStartDocument to start writing the scope. }
    procedure WriteJavaScriptWithScope(const ACode: String); overload;

    { Writes a name/value pair with a JavaScript with scope.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        ACode: the JavaScript code.

      @bold(Note): call WriteStartDocument to start writing the scope. }
    procedure WriteJavaScriptWithScope(const AName, ACode: String); overload;

    { Writes a BSON Null value }
    procedure WriteNull; overload;

    { Writes a name/value pair with a BSON Null value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteNull(const AName: String); overload;

    { Writes a BSON Undefined value. }
    procedure WriteUndefined; overload;

    { Writes a name/value pair with a BSON Undefined value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteUndefined(const AName: String); overload;

    { Writes a BSON MaxKey value }
    procedure WriteMaxKey; overload;

    { Writes a name/value pair with a BSON MaxKey value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteMaxKey(const AName: String); overload;

    { Writes a BSON MinKey value }
    procedure WriteMinKey; overload;

    { Writes a name/value pair with a BSON MinKey value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteMinKey(const AName: String); overload;

    { Writes a BSON Symbol.

      Parameters:
        AValue: the symbol. }
    procedure WriteSymbol(const AValue: String); overload;

    { Writes a name/value pair with a BSON Symbol.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the symbol. }
    procedure WriteSymbol(const AName, AValue: String); overload;

    { Writes the start of a BSON Array }
    procedure WriteStartArray; overload;

    { Writes a name/value pair, where the value starts a BSON Array.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteStartArray(const AName: String); overload;

    { Writes the end of a BSON Array }
    procedure WriteEndArray;

    { Writes the start of a BSON Document }
    procedure WriteStartDocument; overload;

    { Writes a name/value pair, where the value starts a BSON Document.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteStartDocument(const AName: String); overload;

    { Writes the end of a BSON Document }
    procedure WriteEndDocument;

    { The current state of the writer }
    property State: TRESTDWBsonWriterState read GetState;
  end;

type
  { Interface for writing BSON values to binary BSON format.
    See TRESTDWBsonWriter for the stock implementation of this interface. }
  IgoBsonWriter = interface(IgoBsonBaseWriter)
  ['{6B413B69-018F-48AD-8D81-140C1078AFA1}']
    { Returns the currently written data as a byte array.

      Returns:
        The data in BSON format.

      @bold(Note): you usually call this method when you have finished writing
      a BSON Document or value }
    function ToBson: TBytes;

    { Writes a raw BSON document.

      Parameters:
        AValue: the raw BSON document to write.

      @bold(Note): no BSON validity checking is performed. The value will be
      written as-is, and generate invalid BSON of not used carefully. }
    procedure WriteRawBsonDocument(const ADocument: TBytes);
  end;

type
  { Interface for writing BSON values to JSON format.
    See TRESTDWJsonWriter for the stock implementation of this interface. }
  IgoJsonWriter = interface(IgoBsonBaseWriter)
  ['{92F5BA20-02C9-401C-8403-B51F8898E692}']
    { Returns the currently written data as a JSON string.

      Returns:
        The data in JSON format.

      @bold(Note): you usually call this method when you have finished writing
      a BSON Document or value }
    function ToJson: String;

    { Inserts a raw value into the current JSON string.

      Parameters:
        AValue: the value to write.

      @bold(Note): no JSON syntax checking is performed. The value will be
      written as-is, and generate invalid JSON of not used carefully. You
      usually never call this method yourself. }
    procedure WriteRaw(const AValue: String);
  end;

type
  { Interface for writing BSON values to a BSON document.
    See TRESTDWBsonDocumentWriter for the stock implementation of this interface. }
  IgoBsonDocumentWriter = interface(IgoBsonBaseWriter)
  ['{4A410F7E-69FA-46A0-ACE2-317AF5DEA2B8}']
    {$REGION 'Internal Declarations'}
    function GetDocument: TRESTDWBsonDocument;
    {$ENDREGION 'Internal Declarations'}

    { The document the writer writes to }
    property Document: TRESTDWBsonDocument read GetDocument;
  end;

type
  { A bookmark that can be used to return a reader to the current position and
    state. }
  IgoBsonReaderBookmark = interface
  ['{7324A2DE-20F6-4FF2-9973-FD861F6833EB}']
    {$REGION 'Internal Declarations'}
    function GetState: TRESTDWBsonReaderState;
    function GetCurrentBsonType: TRESTDWBsonType;
    function GetCurrentName: String;
    {$ENDREGION 'Internal Declarations'}

    { The current state of the reader }
    property State: TRESTDWBsonReaderState read GetState;

    { The current BsonType }
    property CurrentBsonType: TRESTDWBsonType read GetCurrentBsonType;

    { The name of the current element }
    property CurrentName: String read GetCurrentName;
  end;

type
  { Base interface for IgoBsonReader, IgoJsonReader and IgoBsonDocumentReader }
  IgoBsonBaseReader = interface
  ['{A0592C3C-5E24-4424-9662-EA7F33BB1B9A}']
    {$REGION 'Internal Declarations'}
    function GetState: TRESTDWBsonReaderState;
    {$ENDREGION 'Internal Declarations'}

    { Whether the reader is at the end of the stream.

      Returns:
        True if at end of stream }
    function EndOfStream: Boolean;

    { Gets the current BSON type in the stream.

      Returns:
        The current BSON type.

       @bold(Note): calls ReadBsonType if necessary. }
    function GetCurrentBsonType: TRESTDWBsonType;

    { Gets a bookmark to the reader's current position and state.

      Returns:
        A bookmark.

      You can use the returned bookmark to restore the state using
      ReturnToBookmark. }
    function GetBookmark: IgoBsonReaderBookmark;

    { Returns the reader to previously bookmarked position and state.

      AParameters:
        ABookmark: the bookmark to return to. This value has previously been
          acquired using GetBookmark. }
    procedure ReturnToBookmark(const ABookmark: IgoBsonReaderBookmark);

    { Reads a BSON Document from the stream.

      Returns:
        The read BSON Document.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Document, or the stream is invalid. }
    function ReadDocument: TRESTDWBsonDocument;

    { Reads a BSON Array from the stream.

      Returns:
        The read BSON Array.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Array, or the stream is invalid. }
    function ReadArray: TRESTDWBsonArray;

    { Reads a BSON value from the stream.

      Returns:
        The read BSON value.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON value, or the stream is invalid. }
    function ReadValue: TRESTDWBsonValue;

    { Reads a BSON Binary from the stream.

      Returns:
        The read BSON Binary.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Binary, or the stream is invalid. }
    function ReadBinaryData: TRESTDWBsonBinaryData;

    { Reads a BSON Regular Expression from the stream.

      Returns:
        The read BSON Regular Expression.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Regular Expression, or the stream is invalid. }
    function ReadRegularExpression: TRESTDWBsonRegularExpression;

    { Reads a BSON type from the stream.

      Returns:
        The read BSON type.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON type, or the stream is invalid. }
    function ReadBsonType: TRESTDWBsonType;

    { Reads the name of an element from the stream.

      Returns:
        The read element name.

      Raises:
        An exception if the current position in the stream does not contain
        an element name, or the stream is invalid. }
    function ReadName: String;

    { Skips the name of an element.

      Raises:
        An exception if the current position in the stream does not contain
        an element name, or the stream is invalid. }
    procedure SkipName;

    { Skips the value of an element.

      Raises:
        An exception if the current position in the stream does not contain
        an element value, or the stream is invalid. }
    procedure SkipValue;

    { Reads a Boolean value from the stream.

      Returns:
        The read Boolean value.

      Raises:
        An exception if the current position in the stream does not contain
        a Boolean value, or the stream is invalid. }
    function ReadBoolean: Boolean;

    { Reads a 32-bit Integer value from the stream.

      Returns:
        The read Integer value.

      Raises:
        An exception if the current position in the stream does not contain
        a 32-bit Integer value, or the stream is invalid. }
    function ReadInt32: Integer;

    { Reads a 64-bit Integer value from the stream.

      Returns:
        The read Integer value.

      Raises:
        An exception if the current position in the stream does not contain
        a 64-bit Integer value, or the stream is invalid. }
    function ReadInt64: Int64;

    { Reads a Double value from the stream.

      Returns:
        The read Double value.

      Raises:
        An exception if the current position in the stream does not contain
        a Double value, or the stream is invalid. }
    function ReadDouble: Double;

    { Reads a String value from the stream.

      Returns:
        The read String value.

      Raises:
        An exception if the current position in the stream does not contain
        a String value, or the stream is invalid. }
    function ReadString: String;

    { Reads a DateTime value from the stream.

      Returns:
        The read DateTime value as the number of UTC milliseconds since the
        Unix epoch.

      Raises:
        An exception if the current position in the stream does not contain
        a DateTime value, or the stream is invalid. }
    function ReadDateTime: Int64;

    { Reads a Timestamp value from the stream.

      Returns:
        The read Timestamp value.

      Raises:
        An exception if the current position in the stream does not contain
        a Timestamp value, or the stream is invalid. }
    function ReadTimestamp: Int64;

    { Reads an ObjectId value from the stream.

      Returns:
        The read ObjectId value.

      Raises:
        An exception if the current position in the stream does not contain
        a ObjectId value, or the stream is invalid. }
    function ReadObjectId: TRESTDWObjectId;

    { Reads a Binary value from the stream as a byte array.

      Returns:
        The read Binary value.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Binary, or the stream is invalid. }
    function ReadBytes: TBytes;

    { Reads a JavaScript from the stream.

      Returns:
        The read JavaScript.

      Raises:
        An exception if the current position in the stream does not contain
        a JavaScript, or the stream is invalid. }
    function ReadJavaScript: String;

    { Reads a JavaScript with scope from the stream.

      Returns:
        The read JavaScript.

      Raises:
        An exception if the current position in the stream does not contain
        a JavaScript with Scope, or the stream is invalid.

      @bold(Note): call ReadStartDocument next to read the scope. }
    function ReadJavaScriptWithScope: String;

    { Reads a BSON Null value from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        a Null value, or the stream is invalid. }
    procedure ReadNull;

    { Reads a BSON Undefined value from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        a Undefined value, or the stream is invalid. }
    procedure ReadUndefined;

    { Reads a BSON MaxKey value from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        a MaxKey value, or the stream is invalid. }
    procedure ReadMaxKey;

    { Reads a BSON MinKey value from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        a MinKey value, or the stream is invalid. }
    procedure ReadMinKey;

    { Reads a BSON Symbol from the stream.

      Returns:
        The read Symbol name.

      Raises:
        An exception if the current position in the stream does not contain
        a Symbol, or the stream is invalid. }
    function ReadSymbol: String;

    { Reads the start of a BSON Array from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        the start of a BSON Array, or the stream is invalid. }
    procedure ReadStartArray;

    { Reads the end of a BSON Array from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        the end of a BSON Array, or the stream is invalid. }
    procedure ReadEndArray;

    { Reads the start of a BSON Document from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        the start of a BSON Document, or the stream is invalid. }
    procedure ReadStartDocument;

    { Reads the end of a BSON Document from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        the end of a BSON Document, or the stream is invalid. }
    procedure ReadEndDocument;

    { The current state of the reader }
    property State: TRESTDWBsonReaderState read GetState;
  end;

type
  { Interface for reading BSON values from binary BSON format.
    See TRESTDWBsonReader for the stock implementation of this interface. }
  IgoBsonReader = interface(IgoBsonBaseReader)
  ['{773A4BBE-A4D9-4DDA-A937-C865ADC0A5B8}']
  end;

type
  { Interface for reading BSON values from JSON format.
    See TRESTDWJsonReader for the stock implementation of this interface. }
  IgoJsonReader = interface(IgoBsonBaseReader)
  ['{F579A93F-760C-463D-9B54-64AAF527F514}']
  end;

type
  { Interface for reading BSON values from a BSON Document.
    See TRESTDWBsonDocumentReader for the stock implementation of this interface. }
  IgoBsonDocumentReader = interface(IgoBsonBaseReader)
  ['{1D4F90C4-C790-491C-844A-C7FFCF58F2E8}']
  end;

type
  { Abstract base class of TRESTDWBsonWriter and TRESTDWJsonWriter.
    Implements the IgoBsonBaseWriter interface. }
  TRESTDWBsonBaseWriter = class abstract(TInterfacedObject, IgoBsonBaseWriter)
  {$REGION 'Internal Declarations'}
  private
    FState: TRESTDWBsonWriterState;
    FName: String;
  private
    procedure WriteValueIntf(const AValue: TRESTDWBsonValue._IValue);
    procedure WriteArray(const AArray: TRESTDWBsonArray._IArray);
    procedure WriteDocument(const ADocument: TRESTDWBsonDocument._IDocument);
    procedure DoWriteBinaryData(const AValue: TRESTDWBsonValue._IValue);
    procedure DoWriteDateTime(const AValue: TRESTDWBsonValue._IValue);
    procedure DoWriteRegularExpression(const AValue: TRESTDWBsonValue._IValue);
    procedure DoWriteJavaScript(const AValue: TRESTDWBsonValue._IValue);
    procedure DoWriteJavaScriptWithScope(const AValue: TRESTDWBsonJavaScriptWithScope); overload;
    procedure DoWriteJavaScriptWithScope(const AValue: TRESTDWBsonValue._IValue); overload;
    procedure DoWriteSymbol(const AValue: TRESTDWBsonValue._IValue);
    procedure DoWriteTimestamp(const AValue: TRESTDWBsonValue._IValue);
  protected
    { IgoBsonBaseWriter }
    procedure WriteName(const AName: String); virtual;
    procedure WriteValue(const AValue: TRESTDWBsonValue);
    function GetState: TRESTDWBsonWriterState;
    procedure WriteBoolean(const AValue: Boolean); overload; virtual; abstract;
    procedure WriteBoolean(const AName: String; const AValue: Boolean); overload;
    procedure WriteInt32(const AValue: Integer); overload; virtual; abstract;
    procedure WriteInt32(const AName: String; const AValue: Int32); overload;
    procedure WriteInt64(const AValue: Int64); overload; virtual; abstract;
    procedure WriteInt64(const AName: String; const AValue: Int64); overload;
    procedure WriteDouble(const AValue: Double); overload; virtual; abstract;
    procedure WriteDouble(const AName: String; const AValue: Double); overload;
    procedure WriteString(const AValue: String); overload; virtual; abstract;
    procedure WriteString(const AName, AValue: String); overload;
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); overload; virtual; abstract;
    procedure WriteDateTime(const AName: String; const AMillisecondsSinceEpoch: Int64); overload;
    procedure WriteBytes(const AValue: TBytes); overload;
    procedure WriteBytes(const AName: String; const AValue: TBytes); overload;
    procedure WriteTimestamp(const AValue: Int64); overload; virtual; abstract;
    procedure WriteTimestamp(const AName: String; const AValue: Int64); overload;
    procedure WriteObjectId(const AValue: TRESTDWObjectId); overload; virtual; abstract;
    procedure WriteObjectId(const AName: String; const AValue: TRESTDWObjectId); overload;
    procedure WriteJavaScript(const ACode: String); overload; virtual; abstract;
    procedure WriteJavaScript(const AName, ACode: String); overload;
    procedure WriteJavaScriptWithScope(const ACode: String); overload; virtual; abstract;
    procedure WriteJavaScriptWithScope(const AName, ACode: String); overload;
    procedure WriteNull; overload; virtual; abstract;
    procedure WriteNull(const AName: String); overload;
    procedure WriteUndefined; overload; virtual; abstract;
    procedure WriteUndefined(const AName: String); overload;
    procedure WriteMaxKey; overload; virtual; abstract;
    procedure WriteMaxKey(const AName: String); overload;
    procedure WriteMinKey; overload; virtual; abstract;
    procedure WriteMinKey(const AName: String); overload;
    procedure WriteSymbol(const AValue: String); overload; virtual; abstract;
    procedure WriteSymbol(const AName, AValue: String); overload;
    procedure WriteStartArray; overload; virtual; abstract;
    procedure WriteStartArray(const AName: String); overload;
    procedure WriteEndArray; virtual; abstract;
    procedure WriteStartDocument; overload; virtual; abstract;
    procedure WriteStartDocument(const AName: String); overload;
    procedure WriteEndDocument; virtual; abstract;
    procedure WriteBinaryData(const AValue: TRESTDWBsonBinaryData); virtual; abstract;
    procedure WriteRegularExpression(const AValue: TRESTDWBsonRegularExpression); overload; virtual; abstract;
    procedure WriteRegularExpression(const AName: String; const AValue: TRESTDWBsonRegularExpression); overload;
  protected
    property State: TRESTDWBsonWriterState read FState write FState;
    property Name: String read FName;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { Stock implementation of the IgoBsonWriter interface. }
  TRESTDWBsonWriter = class(TRESTDWBsonBaseWriter, IgoBsonWriter)
  {$REGION 'Internal Declarations'}
  private type
    TOutput = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private const
      TEMP_BYTES_LENGTH = 128;
    private
      FBuffer: TBytes;
      FSize: Integer;
      FCapacity: Integer;
      FTempBytes: TBytes;
    public
      procedure Initialize;

      procedure Write(const AValue; const ASize: Integer);
      procedure WriteBsonType(const ABsonType: TRESTDWBsonType); inline;
      procedure WriteBinarySubType(const ASubType: TRESTDWBsonBinarySubType); inline;
      procedure WriteByte(const AValue: Byte); inline;
      procedure WriteBoolean(const AValue: Boolean); inline;
      procedure WriteInt32(const AValue: Int32); inline;
      procedure WriteInt32At(const APosition, AValue: Int32); inline;
      procedure WriteInt64(const AValue: Int64); inline;
      procedure WriteDouble(const AValue: Double); inline;
      procedure WriteCString(const AValue: String); overload;
      procedure WriteCString(const AValue: TBytes); overload;
      procedure WriteString(const AValue: String);
      procedure WriteObjectId(const AValue: TRESTDWObjectId);

      function ToBytes: TBytes;

      property Position: Integer read FSize;
    end;
  private
    Type
     PContext      = ^TContext;
     TContext      = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
     private
      FStartPosition: Integer;
      FIndex: Integer;
      FContextType: TRESTDWBsonContextType;
     public
      procedure Initialize(const AContextType: TRESTDWBsonContextType;
        const AStartPosition: Integer); inline;

      property StartPosition: Integer read FStartPosition;
      property Index: Integer read FIndex write FIndex;
      property ContextType: TRESTDWBsonContextType read FContextType;
    End;
    Type
     TArrayContext = Array of TContext;
  protected type
    TArrayElementNameAccelerator = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private class var
      FCachedElementNames: array [0..999] of TBytes;
    private
      class function CreateElementNameBytes(const AIndex: Integer): TBytes; static;
    public
      class constructor Create;
    public
      class function GetElementNameBytes(const AIndex: Integer): TBytes; static;
    end;
  private
    FOutput: TOutput;
    FContextStack: TArrayContext;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TRESTDWBsonWriterState;
    procedure PushContext(const AContextType: TRESTDWBsonContextType;
      const AStartPosition: Integer);
    procedure PopContext;
    procedure WriteNameHelper;
    procedure BackpatchSize;
  protected
    { IgoBsonBaseWriter }
    procedure WriteBoolean(const AValue: Boolean); override;
    procedure WriteInt32(const AValue: Integer); override;
    procedure WriteInt64(const AValue: Int64); override;
    procedure WriteDouble(const AValue: Double); override;
    procedure WriteString(const AValue: String); override;
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); override;
    procedure WriteTimestamp(const AValue: Int64); override;
    procedure WriteObjectId(const AValue: TRESTDWObjectId); override;
    procedure WriteJavaScript(const ACode: String); override;
    procedure WriteJavaScriptWithScope(const ACode: String); override;
    procedure WriteNull; override;
    procedure WriteUndefined; override;
    procedure WriteMaxKey; override;
    procedure WriteMinKey; override;
    procedure WriteSymbol(const AValue: String); override;
    procedure WriteStartArray; override;
    procedure WriteEndArray; override;
    procedure WriteStartDocument; override;
    procedure WriteEndDocument; override;
    procedure WriteBinaryData(const AValue: TRESTDWBsonBinaryData); override;
    procedure WriteRegularExpression(const AValue: TRESTDWBsonRegularExpression); override;
  protected
    { IgoBsonWriter }
    function ToBson: TBytes;
    procedure WriteRawBsonDocument(const ADocument: TBytes);
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a binary BSON writer }
    constructor Create;
  end;

type
  { Stock implementation of the IgoJsonWriter interface. }
  TRESTDWJsonWriter = class(TRESTDWBsonBaseWriter, IgoJsonWriter)
  {$REGION 'Internal Declarations'}
  private type
    PContext = ^TContext;
    TContext = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private
      FIndentation: String;
      FContextType: TRESTDWBsonContextType;
      FHasElements: Boolean;
    public
      procedure Initialize(const AParentContext: PContext;
        const AContextType: TRESTDWBsonContextType;
        const AIndentString: String);

      property Indentation: String read FIndentation;
      property ContextType: TRESTDWBsonContextType read FContextType;
      property HasElements: Boolean read FHasElements write FHasElements;
    end;
   Type
    TArrayContext = Array of TContext;
  private type
    TOutput = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private
      FBuffer: PByte;
      FSize: Integer;
      FCapacity: Integer;
    public
      procedure Initialize;
      procedure Finalize;

      procedure Append(const AValue; const ASize: Integer); overload;
      procedure Append(const AValue: Char); overload; inline;
      procedure Append(const AValue: String); overload; inline;
      procedure Append(const AValue: Integer); overload; inline;
      procedure Append(const AValue: Int64); overload; inline;
      procedure AppendFormat(const AValue: String; const AArgs: array of const); overload;

      function ToString: String; inline;
    end;
  private
    FSettings: TRESTDWJsonWriterSettings;
    FOutput: TOutput;
    FContextStack: TArrayContext;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TRESTDWBsonWriterState;
    procedure PushContext(const AContextType: TRESTDWBsonContextType;
      const AIndentString: String);
    procedure PopContext;
    procedure WriteNameHelper(const AName: String);
    procedure WriteQuotedString(const AValue: String);
    procedure WriteEscapedString(const AValue: String);
    class function GuidToString(const ABytes: TBytes;
      const ASubType: TRESTDWBsonBinarySubType): String; static;
  protected
    { IgoBsonBaseWriter }
    procedure WriteBoolean(const AValue: Boolean); override;
    procedure WriteInt32(const AValue: Integer); override;
    procedure WriteInt64(const AValue: Int64); override;
    procedure WriteDouble(const AValue: Double); override;
    procedure WriteString(const AValue: String); override;
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); override;
    procedure WriteTimestamp(const AValue: Int64); override;
    procedure WriteObjectId(const AValue: TRESTDWObjectId); override;
    procedure WriteJavaScript(const ACode: String); override;
    procedure WriteJavaScriptWithScope(const ACode: String); override;
    procedure WriteNull; override;
    procedure WriteUndefined; override;
    procedure WriteMaxKey; override;
    procedure WriteMinKey; override;
    procedure WriteSymbol(const AValue: String); override;
    procedure WriteStartArray; override;
    procedure WriteEndArray; override;
    procedure WriteStartDocument; override;
    procedure WriteEndDocument; override;
    procedure WriteBinaryData(const AValue: TRESTDWBsonBinaryData); override;
    procedure WriteRegularExpression(const AValue: TRESTDWBsonRegularExpression); override;
  protected
    { IgoJsonWriter }
    function ToJson: String;
    procedure WriteRaw(const AValue: String);
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a JSON writer using the default settings. }
    constructor Create; overload;

    { Creates a JSON writer.

      Parameters:
        ASettings: the writer settings to use. }
    constructor Create(const ASettings: TRESTDWJsonWriterSettings); overload;

    { Destructor }
    destructor Destroy; override;
  end;

type
  { Stock implementation of the IgoBsonDocumentWriter interface. }
  TRESTDWBsonDocumentWriter = class(TRESTDWBsonBaseWriter, IgoBsonDocumentWriter)
  {$REGION 'Internal Declarations'}
  private type
    PContext = ^TContext;
    TContext = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private
      FContextType: TRESTDWBsonContextType;
      FDocument: TRESTDWBsonDocument;
      FArray: TRESTDWBsonArray;
      FName: String;
      FCode: String;
    public
      procedure Initialize(const AContextType: TRESTDWBsonContextType;
        const ADocument: TRESTDWBsonDocument); overload;
      procedure Initialize(const AContextType: TRESTDWBsonContextType;
        const AArray: TRESTDWBsonArray); overload;
      procedure Initialize(const AContextType: TRESTDWBsonContextType;
        const ACode: String); overload;

      property ContextType: TRESTDWBsonContextType read FContextType;
      property Document: TRESTDWBsonDocument read FDocument;
      property &Array: TRESTDWBsonArray read FArray;
      property Name: String read FName write FName;
      property Code: String read FCode;
    end;
   Type
    TArrayContext = Array of TContext;
  private
    FDocument: TRESTDWBsonDocument;
    FContextStack: TArrayContext;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TRESTDWBsonWriterState;
    procedure PushContext(const AContextType: TRESTDWBsonContextType;
      const ADocument: TRESTDWBsonDocument); overload;
    procedure PushContext(const AContextType: TRESTDWBsonContextType;
      const AArray: TRESTDWBsonArray); overload;
    procedure PushContext(const AContextType: TRESTDWBsonContextType;
      const ACode: String); overload;
    procedure PopContext;
    procedure AddValue(const AValue: TRESTDWBsonValue);
  protected
    { IgoBsonBaseWriter }
    procedure WriteName(const AName: String); override;
    procedure WriteBoolean(const AValue: Boolean); override;
    procedure WriteInt32(const AValue: Integer); override;
    procedure WriteInt64(const AValue: Int64); override;
    procedure WriteDouble(const AValue: Double); override;
    procedure WriteString(const AValue: String); override;
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); override;
    procedure WriteTimestamp(const AValue: Int64); override;
    procedure WriteObjectId(const AValue: TRESTDWObjectId); override;
    procedure WriteJavaScript(const ACode: String); override;
    procedure WriteJavaScriptWithScope(const ACode: String); override;
    procedure WriteNull; override;
    procedure WriteUndefined; override;
    procedure WriteMaxKey; override;
    procedure WriteMinKey; override;
    procedure WriteSymbol(const AValue: String); override;
    procedure WriteStartArray; override;
    procedure WriteEndArray; override;
    procedure WriteStartDocument; override;
    procedure WriteEndDocument; override;
    procedure WriteBinaryData(const AValue: TRESTDWBsonBinaryData); override;
    procedure WriteRegularExpression(const AValue: TRESTDWBsonRegularExpression); override;
  protected
    { IgoBsonDocumentWriter }
    function GetDocument: TRESTDWBsonDocument;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON Document writer.

      Parameters:
        ADocument: the BSON Document to write to. }
    constructor Create(const ADocument: TRESTDWBsonDocument);
  end;

type
  { Abstract base class of TRESTDWBsonReader and TRESTDWJsonReader.
    Implements the IgoBsonBaseReader interface. }
  TRESTDWBsonBaseReader = class abstract(TInterfacedObject, IgoBsonBaseReader)
  {$REGION 'Internal Declarations'}
  private type
    TBookmark = class abstract(TInterfacedObject, IgoBsonReaderBookmark)
    private
      FState: TRESTDWBsonReaderState;
      FCurrentBsonType: TRESTDWBsonType;
      FCurrentName: String;
    protected
      { IgoBsonReaderBookmark }
      function GetState: TRESTDWBsonReaderState;
      function GetCurrentBsonType: TRESTDWBsonType;
      function GetCurrentName: String;
    public
      constructor Create(const AState: TRESTDWBsonReaderState;
        const ACurrentBsonType: TRESTDWBsonType; const ACurrentName: String);

      property State: TRESTDWBsonReaderState read FState;
      property CurrentBsonType: TRESTDWBsonType read FCurrentBsonType;
      property CurrentName: String read FCurrentName;
    end;
  private
    FState: TRESTDWBsonReaderState;
    FCurrentBsonType: TRESTDWBsonType;
    FCurrentName: String;
    FAllowDuplicateNames: Boolean;
  private
    function DoReadJavaScriptWithScope: TRESTDWBsonValue;
  protected
    { IgoBsonBaseReader }
    function GetState: TRESTDWBsonReaderState;
    function GetCurrentBsonType: TRESTDWBsonType;
    function ReadDocument: TRESTDWBsonDocument;
    function ReadArray: TRESTDWBsonArray;
    function ReadValue: TRESTDWBsonValue;
    function GetBookmark: IgoBsonReaderBookmark; virtual; abstract;
    procedure ReturnToBookmark(const ABookmark: IgoBsonReaderBookmark); virtual; abstract;
    function EndOfStream: Boolean; virtual; abstract;
    function ReadBsonType: TRESTDWBsonType; virtual; abstract;
    function ReadName: String; virtual; abstract;
    procedure SkipName; virtual; abstract;
    procedure SkipValue; virtual; abstract;
    function ReadBoolean: Boolean; virtual; abstract;
    function ReadInt32: Integer; virtual; abstract;
    function ReadInt64: Int64; virtual; abstract;
    function ReadDouble: Double; virtual; abstract;
    function ReadString: String; virtual; abstract;
    function ReadDateTime: Int64; virtual; abstract;
    function ReadTimestamp: Int64; virtual; abstract;
    function ReadObjectId: TRESTDWObjectId; virtual; abstract;
    function ReadBytes: TBytes; virtual; abstract;
    function ReadJavaScript: String; virtual; abstract;
    function ReadJavaScriptWithScope: String; virtual; abstract;
    procedure ReadNull; virtual; abstract;
    procedure ReadUndefined; virtual; abstract;
    procedure ReadMaxKey; virtual; abstract;
    procedure ReadMinKey; virtual; abstract;
    function ReadSymbol: String; virtual; abstract;
    procedure ReadStartArray; virtual; abstract;
    procedure ReadEndArray; virtual; abstract;
    procedure ReadStartDocument; virtual; abstract;
    procedure ReadEndDocument; virtual; abstract;
    function ReadBinaryData: TRESTDWBsonBinaryData; virtual; abstract;
    function ReadRegularExpression: TRESTDWBsonRegularExpression; virtual; abstract;
  protected
    function ReadDocumentIntf: TRESTDWBsonDocument._IDocument;
    function ReadArrayIntf: TRESTDWBsonArray._IArray;
    function ReadValueIntf: TRESTDWBsonValue._IValue;
    function ReadBinaryDataIntf: TRESTDWBsonValue._IValue;
    function ReadRegularExpressionIntf: TRESTDWBsonValue._IValue;
    function ReadJavaScriptIntf: TRESTDWBsonValue._IValue;
    function ReadJavaScriptWithScopeIntf: TRESTDWBsonValue._IValue;
    function ReadTimeStampIntf: TRESTDWBsonValue._IValue;
    function ReadStringIntf: TRESTDWBsonValue._IValue;
    function ReadSymbolIntf: TRESTDWBsonValue._IValue;
  protected
    procedure EnsureBsonTypeEquals(const ABsonType: TRESTDWBsonType);
    procedure VerifyBsonType(const ARequiredBsonType: TRESTDWBsonType);

    property State: TRESTDWBsonReaderState read FState write FState;
    property CurrentBsonType: TRESTDWBsonType read FCurrentBsonType write FCurrentBsonType;
    property CurrentName: String read FCurrentName write FCurrentName;
    property AllowDuplicateNames: Boolean read FAllowDuplicateNames write FAllowDuplicateNames;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { Stock implementation of the IgoBsonReader interface. }
  TRESTDWBsonReader = class(TRESTDWBsonBaseReader, IgoBsonReader)
  {$REGION 'Internal Declarations'}
  private type
    TInput = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private const
      TEMP_BYTES_LENGTH = 128;
    private class var
      FValidBsonTypes: array [0..255] of Boolean;
    private
      FBuffer: TBytes;
      FSize: Integer;
      FPosition: Integer;
      FTempBytes: TBytes;
    public
      class constructor Create;
    public
      procedure Initialize(const ABuffer: TBytes); inline;
      procedure Skip(const ANumBytes: Integer);

      procedure Read(out AData; const ASize: Integer);
      function ReadBsonType: TRESTDWBsonType; inline;
      function ReadBinarySubType: TRESTDWBsonBinarySubType; inline;
      function ReadByte: Byte; inline;
      function ReadBytes(const ASize: Integer): TBytes;
      function ReadBoolean: Boolean; inline;
      function ReadInt32: Int32; inline;
      function ReadInt64: Int64; inline;
      function ReadDouble: Double; inline;
      function ReadCString: String;
      procedure SkipCString;
      function ReadString: String;
      function ReadObjectId: TRESTDWObjectId;

      property Size: Integer read FSize;
      property Position: Integer read FPosition write FPosition;
    end;
  private type
    PContext = ^TContext;
    TContext = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private
      FStartPosition: Integer;
      FSize: Integer;
      FCurrentArrayIndex: Integer;
      FCurrentElementName: String;
      FContextType: TRESTDWBsonContextType;
    public
      procedure Initialize(const AContextType: TRESTDWBsonContextType;
        const AStartPosition, ASize: Integer); inline;

      property ContextType: TRESTDWBsonContextType read FContextType;
      property CurrentArrayIndex: Integer read FCurrentArrayIndex write FCurrentArrayIndex;
      property CurrentElementName: String read FCurrentElementName write FCurrentElementName;
    end;
   Type
    TArrayContext = Array of TContext;
  private type
    TBsonBookmark = class(TBookmark)
    private
      FContextIndex: Integer;
      FPosition: Integer;
    public
      constructor Create(const AState: TRESTDWBsonReaderState;
        const ACurrentBsonType: TRESTDWBsonType; const ACurrentName: String;
        const AContextIndex, APosition: Integer);

      property ContextIndex: Integer read FContextIndex;
      property Position: Integer read FPosition;
    end;
  private
    FInput: TInput;
    FContextStack: TArrayContext;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TRESTDWBsonReaderState;
    procedure PushContext(const AContextType: TRESTDWBsonContextType;
      const AStartPosition, ASize: Integer);
    procedure PopContext(const APosition: Integer);
    function ReadSize: Integer;
  protected
    { IgoBsonBaseReader }
    function GetBookmark: IgoBsonReaderBookmark; override;
    procedure ReturnToBookmark(const ABookmark: IgoBsonReaderBookmark); override;
    function EndOfStream: Boolean; override;
    function ReadBsonType: TRESTDWBsonType; override;
    function ReadName: String; override;
    procedure SkipName; override;
    procedure SkipValue; override;
    function ReadBoolean: Boolean; override;
    function ReadInt32: Integer; override;
    function ReadInt64: Int64; override;
    function ReadDouble: Double; override;
    function ReadString: String; override;
    function ReadDateTime: Int64; override;
    function ReadTimestamp: Int64; override;
    function ReadObjectId: TRESTDWObjectId; override;
    function ReadBytes: TBytes; override;
    function ReadJavaScript: String; override;
    function ReadJavaScriptWithScope: String; override;
    procedure ReadNull; override;
    procedure ReadUndefined; override;
    procedure ReadMaxKey; override;
    procedure ReadMinKey; override;
    function ReadSymbol: String; override;
    procedure ReadStartArray; override;
    procedure ReadEndArray; override;
    procedure ReadStartDocument; override;
    procedure ReadEndDocument; override;
    function ReadBinaryData: TRESTDWBsonBinaryData; override;
    function ReadRegularExpression: TRESTDWBsonRegularExpression; override;
  protected
    { IgoBsonReader }
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON binary reader.

      Parameters:
        ABson: the binary BSON data to read from. }
    constructor Create(const ABson: TBytes);

    { Creates a BSON binary reader from a file.

      Parameters:
        AFilename: the name of the file containing the BSON data. }
    class function Load(const AFilename: String): IgoBsonReader; overload; static;

    { Creates a BSON binary reader from a stream.

      Parameters:
        AStream: the stream containing the BSON data. }
    class function Load(const AStream: TStream): IgoBsonReader; overload; static;
  end;

type
  { Stock implementation of the IgoJsonReader interface. }
  TRESTDWJsonReader = class(TRESTDWBsonBaseReader, IgoJsonReader)
  {$REGION 'Internal Declarations'}
  private type
    PContext = ^TContext;
    TContext = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private
      FContextType: TRESTDWBsonContextType;
    public
      procedure Initialize(const AContextType: TRESTDWBsonContextType); inline;

      property ContextType: TRESTDWBsonContextType read FContextType;
    end;
    Type
     TArrayContext = Array Of TContext;
  private type
    TBuffer = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private
      FJson: String;
      FBuffer: PChar;
      FCurrent: PChar;
      FErrorPos: PChar;
      FLineNumber: Integer;
      FLineStart: PChar;
      FPrevLineStart: PChar;
    public
      class function Create(const AJson: String): TBuffer; static;
      function Read: Char; inline;
      procedure Unread(const AChar: Char);
      procedure MarkErrorPos; inline;
      procedure ClearErrorPos; inline;

      function ParseError(const AMsg: PResStringRec): EgoJsonParserError; overload;
      function ParseError(const AMsg: String): EgoJsonParserError; overload;
      function ParseError(const AMsg: PResStringRec; const AArgs: array of const): EgoJsonParserError; overload;
      function ParseError(const AMsg: String; const AArgs: array of const): EgoJsonParserError; overload;

      property Current: PChar read FCurrent write FCurrent;
    end;
  private type
    TTokenType = (Invalid, BeginArray, BeginObject, EndArray, LeftParen,
      RightParen, EndObject, Colon, Comma, DateTime, Double, Int32, Int64,
      ObjectId, RegularExpression, &String, UnquotedString, EndOfFile);
  private type
    TToken = class
    {$REGION 'Internal Declarations'}
    private type
      TTokenValue = Record
      case Byte of
        0: (Int32Value: Int32);
        1: (Int64Value: Int64);
        2: (DoubleValue: Double);
      end;
    private
      FTokenType: TTokenType;
      FLexemeStart: PChar;
      FLexemeLength: Integer;
      FStringValue: String;
      FValue: TTokenValue;
    {$ENDREGION 'Internal Declarations'}
    public
      procedure Initialize(const ATokenType: TTokenType;
        const ALexemeStart: PChar; const ALexemeLength: Integer); overload; inline;
      procedure Initialize(const ATokenType: TTokenType;
        const ALexemeStart: PChar; const ALexemeLength: Integer;
        const AStringValue: String); overload; inline;
      procedure Initialize(const ALexemeStart: PChar; const ALexemeLength: Integer;
        const AInt32Value: Int32); overload; inline;
      procedure Initialize(const ALexemeStart: PChar; const ALexemeLength: Integer;
        const AInt64Value: Int64); overload; inline;
      procedure Initialize(const ALexemeStart: PChar; const ALexemeLength: Integer;
        const ADoubleValue: Double); overload; inline;
      procedure InitializeRegEx(const ALexemeStart: PChar;
        const ALexemeLength: Integer); overload; inline;

      procedure Assign(const AOther: TToken);

      function IsLexeme(const AValue: PChar; const AValueLength: Integer): Boolean; inline;
      function LexemeToString: String; inline;

      property TokenType: TTokenType read FTokenType;
      property LexemeStart: PChar read FLexemeStart;
      property LexemeLength: Integer read FLexemeLength;
      property StringValue: String read FStringValue;
      property Int32Value: Int32 read FValue.Int32Value;
      property Int64Value: Int64 read FValue.Int64Value;
      property DoubleValue: Double read FValue.DoubleValue;
    end;
  private type
    TScanner = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private type
      TRegularExpressionState = (InPattern, InEscapeSequence, InOptions,
        Done, Invalid);
    private type
      TCharHandler = procedure(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken);
    private class var
      FCharHandlers: array [#0..#127] of TCharHandler;
    private
      class function IsWhitespace(const AChar: Char): Boolean; inline; static;
    private
      { Character handlers }
      class procedure CharError(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharEof(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharWhitespace(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharBeginObject(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharEndObject(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharBeginArray(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharEndArray(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharLeftParen(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharRightParen(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharColon(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharComma(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharNumberToken(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharStringToken(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharStringTokenUnscape(var ABuffer: TBuffer;
        const AQuoteChar: Char; const AToken: TToken; const AStart: PChar;
        const APrefix: String); static;
      class procedure CharUnquotedStringToken(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharRegularExpressionToken(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
    public
      class procedure Initialize; static;
      class procedure GetNextToken(var ABuffer: TBuffer; const AToken: TToken); static;
    end;
  private type
    TValue = record
      StrVal: String;
      Bytes: TBytes;
      case Byte of
        0: (BoolVal: Boolean);
        1: (Int32Val: Int32);
        2: (Int64Val: Int64);
        3: (DoubleVal: Double);
        4: (ObjectIdVal: TRESTDWObjectId);
        5: (BinarySubType: TRESTDWBsonBinarySubType);
    end;
  private type
    TJsonBookmark = class(TBookmark)
    private
      FContextIndex: Integer;
      FCurrentToken: TToken;
      FCurrentValue: TValue;
      FPushedToken: TToken;
      FCurrent: PChar;
    public
      constructor Create(const AState: TRESTDWBsonReaderState;
        const ACurrentBsonType: TRESTDWBsonType; const ACurrentName: String;
        const AContextIndex: Integer; const ACurrentToken: TToken;
        const ACurrentValue: TValue; const APushedToken: TToken;
        const ACurrent: PChar);
      destructor Destroy; override;

      property ContextIndex: Integer read FContextIndex;
      property CurrentToken: TToken read FCurrentToken;
      property CurrentValue: TValue read FCurrentValue;
      property PushedToken: TToken read FPushedToken;
      property Current: PChar read FCurrent;
    end;
  private
    FBuffer: TBuffer;
    FTokenBase: TToken;
    FTokenToPush: TToken;
    FCurrentToken: TToken;
    FCurrentValue: TValue;
    FPushedToken: TToken;
    FContextStack: TArrayContext;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TRESTDWBsonReaderState;
    procedure PushContext(const AContextType: TRESTDWBsonContextType);
    procedure PopContext;
    procedure PushToken(const AToken: TToken);
    procedure PopToken(out AToken: TToken);
    function ParseDocumentOrExtendedJson: TRESTDWBsonType;
    function ParseExtendedJson(const ANameToken: TToken): TRESTDWBsonType;
    procedure ParseExtendedJsonBinaryData;
    function ParseExtendedJsonDateTime: Int64;
    function ParseExtendedJsonNumberLong: Int64;
    function ParseExtendedJsonJavaScript: TRESTDWBsonType;
    procedure ParseExtendedJsonMaxKey;
    procedure ParseExtendedJsonMinKey;
    procedure ParseExtendedJsonUndefined;
    function ParseExtendedJsonObjectId: TRESTDWObjectId;
    procedure ParseExtendedJsonRegularExpression;
    procedure ParseExtendedJsonSymbol;
    function ParseExtendedJsonTimestamp: Int64;
    function ParseExtendedJsonTimestampNew: Int64;
    function ParseExtendedJsonTimestampOld(const AValueToken: TToken): Int64;
    procedure ParseConstructorBinaryData;
    procedure ParseConstructorDateTime(const AWithNew: Boolean);
    procedure ParseConstructorHexData;
    procedure ParseConstructorISODateTime;
    procedure ParseConstructorNumber;
    procedure ParseConstructorNumberLong;
    procedure ParseConstructorObjectId;
    procedure ParseConstructorRegularExpression;
    procedure ParseConstructorTimestamp;
    procedure ParseConstructorUUID(const ALexemeStart: Char);
    function ParseNew: TRESTDWBsonType;
    procedure VerifyToken(const AExpectedLexeme: Char); overload;
    procedure VerifyToken(const AExpectedLexeme: PChar;
      const AExpectedLexemeLength: Integer); overload;
    procedure VerifyString(const AExpectedString: String);
    procedure SetCurrentValueRegEx(const AToken: TToken);
    class function FormatJavaScriptDateTimeString(const ALocalDateTime: TDateTime): String; static;
  protected
    { IgoBsonBaseReader }
    function GetBookmark: IgoBsonReaderBookmark; override;
    procedure ReturnToBookmark(const ABookmark: IgoBsonReaderBookmark); override;
    function EndOfStream: Boolean; override;
    function ReadBsonType: TRESTDWBsonType; override;
    function ReadName: String; override;
    procedure SkipName; override;
    procedure SkipValue; override;
    function ReadBoolean: Boolean; override;
    function ReadInt32: Integer; override;
    function ReadInt64: Int64; override;
    function ReadDouble: Double; override;
    function ReadString: String; override;
    function ReadDateTime: Int64; override;
    function ReadTimestamp: Int64; override;
    function ReadObjectId: TRESTDWObjectId; override;
    function ReadBytes: TBytes; override;
    function ReadJavaScript: String; override;
    function ReadJavaScriptWithScope: String; override;
    procedure ReadNull; override;
    procedure ReadUndefined; override;
    procedure ReadMaxKey; override;
    procedure ReadMinKey; override;
    function ReadSymbol: String; override;
    procedure ReadStartArray; override;
    procedure ReadEndArray; override;
    procedure ReadStartDocument; override;
    procedure ReadEndDocument; override;
    function ReadBinaryData: TRESTDWBsonBinaryData; override;
    function ReadRegularExpression: TRESTDWBsonRegularExpression; override;
  public
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a JSON reader.

      Parameters:
        AJson: the JSON string to parse. }
    constructor Create(const AJson: String; bAllowDuplicateNames : Boolean = false);

    { Destructor }
    destructor Destroy; override;

    { Creates a JSON reader from a file.

      Parameters:
        AFilename: the name of the file containing the JSON data. }
    class function Load(const AFilename: String; bAllowDuplicateNames : Boolean = false): IgoJsonReader; overload; static;

    { Creates a JSON reader from a stream.

      Parameters:
        AStream: the stream containing the JSON data. }
    class function Load(const AStream: TStream; bAllowDuplicateNames : Boolean = false): IgoJsonReader; overload; static;
  end;

type
  { Stock implementation of the IgoBsonDocumentReader interface. }
  TRESTDWBsonDocumentReader = class(TRESTDWBsonBaseReader, IgoBsonDocumentReader)
  {$REGION 'Internal Declarations'}
  private type
    PContext = ^TContext;
    TContext = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private
      FContextType: TRESTDWBsonContextType;
      FDocument: TRESTDWBsonDocument;
      FArray: TRESTDWBsonArray;
      FIndex: Integer;
    public
      procedure Initialize(const AContextType: TRESTDWBsonContextType;
        const ADocument: TRESTDWBsonDocument); overload; inline;
      procedure Initialize(const AContextType: TRESTDWBsonContextType;
        const AArray: TRESTDWBsonArray); overload; inline;

      function TryGetNextElement(out AElement: TRESTDWBsonElement): Boolean;
      function TryGetNextValue(out AValue: TRESTDWBsonValue): Boolean;

      property ContextType: TRESTDWBsonContextType read FContextType;
      property Document: TRESTDWBsonDocument read FDocument;
      property Index: Integer read FIndex write FIndex;
    end;
    Type
     TArrayContext = Array Of TContext;
  private type
    TDocumentBookmark = class(TBookmark)
    private
      FContextIndex: Integer;
      FContextIndexIndex: Integer;
      FCurrentValue: TRESTDWBsonValue;
    public
      constructor Create(const AState: TRESTDWBsonReaderState;
        const ACurrentBsonType: TRESTDWBsonType; const ACurrentName: String;
        const AContextIndex, AContextIndexIndex: Integer; const ACurrentValue: TRESTDWBsonValue);

      property ContextIndex: Integer read FContextIndex;
      property ContextIndexIndex: Integer read FContextIndexIndex;
      property CurrentValue: TRESTDWBsonValue read FCurrentValue;
    end;
  private
    FCurrentValue: TRESTDWBsonValue;
    FContextStack: TArrayContext;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TRESTDWBsonReaderState;
    procedure PushContext(const AContextType: TRESTDWBsonContextType;
      const ADocument: TRESTDWBsonDocument); overload;
    procedure PushContext(const AContextType: TRESTDWBsonContextType;
      const AArray: TRESTDWBsonArray); overload;
    procedure PopContext;
  protected
    { IgoBsonBaseReader }
    function GetBookmark: IgoBsonReaderBookmark; override;
    procedure ReturnToBookmark(const ABookmark: IgoBsonReaderBookmark); override;
    function EndOfStream: Boolean; override;
    function ReadBsonType: TRESTDWBsonType; override;
    function ReadName: String; override;
    procedure SkipName; override;
    procedure SkipValue; override;
    function ReadBoolean: Boolean; override;
    function ReadInt32: Integer; override;
    function ReadInt64: Int64; override;
    function ReadDouble: Double; override;
    function ReadString: String; override;
    function ReadDateTime: Int64; override;
    function ReadTimestamp: Int64; override;
    function ReadObjectId: TRESTDWObjectId; override;
    function ReadBytes: TBytes; override;
    function ReadJavaScript: String; override;
    function ReadJavaScriptWithScope: String; override;
    procedure ReadNull; override;
    procedure ReadUndefined; override;
    procedure ReadMaxKey; override;
    procedure ReadMinKey; override;
    function ReadSymbol: String; override;
    procedure ReadStartArray; override;
    procedure ReadEndArray; override;
    procedure ReadStartDocument; override;
    procedure ReadEndDocument; override;
    function ReadBinaryData: TRESTDWBsonBinaryData; override;
    function ReadRegularExpression: TRESTDWBsonRegularExpression; override;
  protected
    { IgoBsonDocumentReader }
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON Document reader.

      Parameters:
        ADocument: the BSON Document to read from. }
    constructor Create(const ADocument: TRESTDWBsonDocument);
  end;

resourcestring
  RS_BSON_NOT_SUPPORTED = 'Unsupported feature';
  RS_BSON_INVALID_WRITER_STATE = 'Cannot write Bson/Json element in current state';
  RS_BSON_INVALID_READER_STATE = 'Cannot read Bson/Json element in current state';
  RS_BSON_INVALID_DATA = 'Bson/Json data is invalid';
  RS_BSON_INT_EXPECTED = 'Integer value expected';
  RS_BSON_UNEXPECTED_TOKEN = 'Unexpected token';
  RS_BSON_TOKEN_EXPECTED = 'Expected token with value "%s" but got "%s"';
  RS_BSON_STRING_EXPECTED = 'String value expected';
  RS_BSON_STRING_WITH_VALUE_EXPECTED = 'Expected string with value "%s" but got "%s"';
  RS_BSON_INT_OR_STRING_EXPECTED = 'Integer or string value expected';
  RS_BSON_COLON_EXPECTED = 'Colon (":") expected';
  RS_BSON_COMMA_EXPECTED = 'Comma (",") expected';
  RS_BSON_QUOTE_EXPECTED = 'Double quotes (") expected';
  RS_BSON_CLOSE_BRACKET_EXPECTED = 'Close bracket ("]") expected';
  RS_BSON_CLOSE_BRACE_EXPECTED = 'Curly close brace ("}") expected';
  RS_BSON_COMMA_OR_CLOSE_BRACE_EXPECTED = 'Comma (",") or curly close brace ("}") expected';
  RS_BSON_STRING_OR_CLOSE_BRACE_EXPECTED = 'String or curly close brace ("}") expected';
  RS_BSON_INVALID_NUMBER = 'Invalid number';
  RS_BSON_INVALID_STRING = 'Invalid character string';
  RS_BSON_INVALID_DATE = 'Invalid date value';
  RS_BSON_INVALID_GUID = 'Invalid GUID value';
  RS_BSON_INVALID_NEW_STATEMENT = 'Invalid "new" statement';
  RS_BSON_INVALID_EXTENDED_JSON = 'Invalid extended JSON';
  RS_BSON_INVALID_BINARY_TYPE = 'Invalid binary type';
  RS_BSON_INVALID_REGEX = 'Invalid regular expression';
  RS_BSON_INVALID_UNICODE_CODEPOINT = 'Invalid Unicode codepoint';
  RS_BSON_JS_DATETIME_STRING_NOT_SUPPORTED = 'JavaScript date/time strings are not supported';

implementation

uses
 {$IFNDEF FPC}
  System.Math,
  System.Types,
  System.Character,
  System.RTLConsts,
  System.DateUtils,
  {$IF Defined(MACOS)}
   Macapi.CoreFoundation,
  {$IFEND}
 {$ELSE}
  Types,
  Character,
  RTLConsts,
  DateUtils,
 {$ENDIF}
  uRESTDW.SysUtils,
  uRESTDW.DateUtils,
  uRESTDW.BinaryCoding;

type
  TRESTDWCharBuffer = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  private const
    SIZE = 256;
  private type
    TBuffer = array [0..SIZE - 1] of Char;
    PBuffer = ^TBuffer;
  private
    FStatic: TBuffer;
    FDynamic: PBuffer;
    FCurrent: PChar;
    FCurrentEnd: PChar;
    FDynamicCount: Integer;
  public
    procedure Initialize; inline;
    procedure Release; inline;
    procedure Append(const AChar: Char); inline;
    function ToString: String; inline;
  end;

procedure TRESTDWCharBuffer.Append(const AChar: Char);
begin
  if (FCurrent < FCurrentEnd) then
  begin
    FCurrent^ := AChar;
    Inc(FCurrent);
    Exit;
  end;

  ReallocMem(FDynamic, (FDynamicCount + 1) * SizeOf(TBuffer));
  FCurrent := PChar(FDynamic) + (FDynamicCount * SIZE);
  FCurrentEnd := FCurrent + SIZE;
  Inc(FDynamicCount);

  FCurrent^ := AChar;
  Inc(FCurrent);
end;

function TRESTDWCharBuffer.ToString: String;
var
  I, StrIndex, TrailingLength: Integer;
  Src: PBuffer;
  Start: PChar;
begin
  if (FDynamic = nil) then
  begin
    Start := @FStatic;
    SetString(Result, Start, FCurrent - Start);
    Exit;
  end;

  TrailingLength := SIZE - (FCurrentEnd - FCurrent);
  SetLength(Result, (FDynamicCount * SIZE) + TrailingLength);
  Move(FStatic, Result[Low(String)], SizeOf(TBuffer));
  StrIndex := Low(String) + SIZE;

  Src := FDynamic;
  for I := 0 to FDynamicCount - 2 do
  begin
    Move(Src^, Result[StrIndex], SizeOf(TBuffer));
    Inc(Src);
    Inc(StrIndex, SIZE);
  end;

  Move(Src^, Result[StrIndex], TrailingLength * SizeOf(Char));
end;

procedure TRESTDWCharBuffer.Initialize;
begin
  FDynamic := nil;
  FCurrent := @FStatic;
  FCurrentEnd := FCurrent + SIZE;
  FDynamicCount := 0;
end;

procedure TRESTDWCharBuffer.Release;
begin
  FreeMem(FDynamic);
end;

{ EgoJsonParserError }

constructor EgoJsonParserError.Create(const AMsg: String;
  const ALineNumber, AColumnNumber, APosition: Integer);
begin
  inherited CreateFmt('(%d:%d) %s', [ALineNumber, AColumnNumber, AMsg]);
  FLineNumber := ALineNumber;
  FColumnNumber := AColumnNumber;
  FPosition := APosition;
end;

{ TRESTDWBsonBaseWriter }

procedure TRESTDWBsonBaseWriter.DoWriteBinaryData(
  const AValue: TRESTDWBsonValue._IValue);
var
  Value: TRESTDWBsonBinaryData;
begin
  _goGetBinaryData(AValue, Value);
  WriteBinaryData(Value);
end;

procedure TRESTDWBsonBaseWriter.DoWriteDateTime(const AValue: TRESTDWBsonValue._IValue);
var
  Value: TRESTDWBsonDateTime;
begin
  _goGetDateTime(AValue, Value);
  WriteDateTime(Value.MillisecondsSinceEpoch);
end;

procedure TRESTDWBsonBaseWriter.DoWriteJavaScript(
  const AValue: TRESTDWBsonValue._IValue);
var
  Value: TRESTDWBsonJavaScript;
begin
  _goGetJavaScript(AValue, Value);
  WriteJavaScript(Value.Code);
end;

procedure TRESTDWBsonBaseWriter.DoWriteJavaScriptWithScope(
  const AValue: TRESTDWBsonValue._IValue);
var
  Value: TRESTDWBsonJavaScriptWithScope;
begin
  _goGetJavaScriptWithScope(AValue, Value);
  DoWriteJavaScriptWithScope(Value);
end;

procedure TRESTDWBsonBaseWriter.DoWriteJavaScriptWithScope(
  const AValue: TRESTDWBsonJavaScriptWithScope);
begin
  WriteJavaScriptWithScope(AValue.Code);
  WriteDocument(AValue.Scope._Impl);
end;

procedure TRESTDWBsonBaseWriter.DoWriteRegularExpression(
  const AValue: TRESTDWBsonValue._IValue);
var
  Value: TRESTDWBsonRegularExpression;
begin
  _goGetRegularExpression(AValue, Value);
  WriteRegularExpression(Value);
end;

procedure TRESTDWBsonBaseWriter.DoWriteSymbol(const AValue: TRESTDWBsonValue._IValue);
var
  Value: TRESTDWBsonSymbol;
begin
  _goGetSymbol(AValue, Value);
  WriteSymbol(Value.Name);
end;

procedure TRESTDWBsonBaseWriter.DoWriteTimestamp(const AValue: TRESTDWBsonValue._IValue);
var
  Value: TRESTDWBsonTimestamp;
begin
  _goGetTimestamp(AValue, Value);
  WriteTimestamp(Value.Value);
end;

function TRESTDWBsonBaseWriter.GetState: TRESTDWBsonWriterState;
begin
  Result := FState;
end;

procedure TRESTDWBsonBaseWriter.WriteArray(const AArray: TRESTDWBsonArray._IArray);
var
  I: Integer;
  Item: TRESTDWBsonValue._IValue;
begin
  WriteStartArray;

  for I := 0 to AArray.Count - 1 do
  begin
    AArray.GetItem(I, Item);
    WriteValueIntf(Item);
  end;

  WriteEndArray;
end;

procedure TRESTDWBsonBaseWriter.WriteBoolean(const AName: String;
  const AValue: Boolean);
begin
  WriteName(AName);
  WriteBoolean(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteBytes(const AValue: TBytes);
begin
  WriteBinaryData(TRESTDWBsonBinaryData.Create(AValue));
end;

procedure TRESTDWBsonBaseWriter.WriteBytes(const AName: String;
  const AValue: TBytes);
begin
  WriteName(AName);
  WriteBytes(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteDateTime(const AName: String;
  const AMillisecondsSinceEpoch: Int64);
begin
  WriteName(AName);
  WriteDateTime(AMillisecondsSinceEpoch);
end;

procedure TRESTDWBsonBaseWriter.WriteDocument(
  const ADocument: TRESTDWBsonDocument._IDocument);
var
  I: Integer;
  Element: TRESTDWBsonElement;
begin
  WriteStartDocument;

  for I := 0 to ADocument.Count - 1 do
  begin
    Element := ADocument.Elements[I];
    WriteName(Element.Name);
    WriteValueIntf(Element._Impl);
  end;

  WriteEndDocument;
end;

procedure TRESTDWBsonBaseWriter.WriteDouble(const AName: String;
  const AValue: Double);
begin
  WriteName(AName);
  WriteDouble(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteInt32(const AName: String;
  const AValue: Int32);
begin
  WriteName(AName);
  WriteInt32(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteInt64(const AName: String;
  const AValue: Int64);
begin
  WriteName(AName);
  WriteInt64(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteJavaScript(const AName, ACode: String);
begin
  WriteName(AName);
  WriteJavaScript(ACode);
end;

procedure TRESTDWBsonBaseWriter.WriteJavaScriptWithScope(const AName,
  ACode: String);
begin
  WriteName(AName);
  WriteJavaScriptWithScope(ACode);
end;

procedure TRESTDWBsonBaseWriter.WriteMaxKey(const AName: String);
begin
  WriteName(AName);
  WriteMaxKey;
end;

procedure TRESTDWBsonBaseWriter.WriteMinKey(const AName: String);
begin
  WriteName(AName);
  WriteMinKey;
end;

procedure TRESTDWBsonBaseWriter.WriteName(const AName: String);
begin
  if (State <> TRESTDWBsonWriterState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FName := AName;
  FState := TRESTDWBsonWriterState.Value;
end;

procedure TRESTDWBsonBaseWriter.WriteNull(const AName: String);
begin
  WriteName(AName);
  WriteNull;
end;

procedure TRESTDWBsonBaseWriter.WriteObjectId(const AName: String;
  const AValue: TRESTDWObjectId);
begin
  WriteName(AName);
  WriteObjectId(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteRegularExpression(const AName: String;
  const AValue: TRESTDWBsonRegularExpression);
begin
  WriteName(AName);
  WriteRegularExpression(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteStartArray(const AName: String);
begin
  WriteName(AName);
  WriteStartArray;
end;

procedure TRESTDWBsonBaseWriter.WriteStartDocument(const AName: String);
begin
  WriteName(AName);
  WriteStartDocument;
end;

procedure TRESTDWBsonBaseWriter.WriteString(const AName, AValue: String);
begin
  WriteName(AName);
  WriteString(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteSymbol(const AName, AValue: String);
begin
  WriteName(AName);
  WriteSymbol(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteTimestamp(const AName: String;
  const AValue: Int64);
begin
  WriteName(AName);
  WriteTimestamp(AValue);
end;

procedure TRESTDWBsonBaseWriter.WriteUndefined(const AName: String);
begin
  WriteName(AName);
  WriteUndefined;
end;

procedure TRESTDWBsonBaseWriter.WriteValue(const AValue: TRESTDWBsonValue);
begin
  if (AValue.IsNil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  case AValue.BsonType of
    TRESTDWBsonType.EndOfDocument      : ;
    TRESTDWBsonType.Double             : WriteDouble(AValue.AsDouble);
    TRESTDWBsonType.&String            : WriteString(AValue.AsString);
    TRESTDWBsonType.Document           : WriteDocument(TRESTDWBsonDocument._IDocument(AValue._Impl));
    TRESTDWBsonType.&Array             : WriteArray(TRESTDWBsonArray._IArray(AValue._Impl));
    TRESTDWBsonType.Binary             : DoWriteBinaryData(AValue._Impl);
    TRESTDWBsonType.Undefined          : WriteUndefined;
    TRESTDWBsonType.ObjectId           : WriteObjectId(AValue.AsObjectId);
    TRESTDWBsonType.Boolean            : WriteBoolean(AValue.AsBoolean);
    TRESTDWBsonType.DateTime           : DoWriteDateTime(AValue._Impl);
    TRESTDWBsonType.Null               : WriteNull;
    TRESTDWBsonType.RegularExpression  : DoWriteRegularExpression(AValue._Impl);
    TRESTDWBsonType.JavaScript         : DoWriteJavaScript(AValue._Impl);
    TRESTDWBsonType.Symbol             : DoWriteSymbol(AValue._Impl);
    TRESTDWBsonType.JavaScriptWithScope: DoWriteJavaScriptWithScope(AValue._Impl);
    TRESTDWBsonType.Int32              : WriteInt32(AValue.AsInteger);
    TRESTDWBsonType.Timestamp          : DoWriteTimestamp(AValue._Impl);
    TRESTDWBsonType.Int64              : WriteInt64(AValue.AsInt64);
    TRESTDWBsonType.MaxKey             : WriteMaxKey;
    TRESTDWBsonType.MinKey             : WriteMinKey;
  else
    Assert(False);
  end;
end;

procedure TRESTDWBsonBaseWriter.WriteValueIntf(const AValue: TRESTDWBsonValue._IValue);
begin
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  case AValue.BsonType of
    TRESTDWBsonType.EndOfDocument      : ;
    TRESTDWBsonType.Double             : WriteDouble(AValue.AsDouble);
    TRESTDWBsonType.&String            : WriteString(AValue.AsString);
    TRESTDWBsonType.Document           : WriteDocument(TRESTDWBsonDocument._IDocument(AValue));
    TRESTDWBsonType.&Array             : WriteArray(TRESTDWBsonArray._IArray(AValue));
    TRESTDWBsonType.Binary             : DoWriteBinaryData(AValue);
    TRESTDWBsonType.Undefined          : WriteUndefined;
    TRESTDWBsonType.ObjectId           : WriteObjectId(AValue.AsObjectId);
    TRESTDWBsonType.Boolean            : WriteBoolean(AValue.AsBoolean);
    TRESTDWBsonType.DateTime           : DoWriteDateTime(AValue);
    TRESTDWBsonType.Null               : WriteNull;
    TRESTDWBsonType.RegularExpression  : DoWriteRegularExpression(AValue);
    TRESTDWBsonType.JavaScript         : DoWriteJavaScript(AValue);
    TRESTDWBsonType.Symbol             : DoWriteSymbol(AValue);
    TRESTDWBsonType.JavaScriptWithScope: DoWriteJavaScriptWithScope(AValue);
    TRESTDWBsonType.Int32              : WriteInt32(AValue.AsInteger);
    TRESTDWBsonType.Timestamp          : DoWriteTimestamp(AValue);
    TRESTDWBsonType.Int64              : WriteInt64(AValue.AsInt64);
    TRESTDWBsonType.MaxKey             : WriteMaxKey;
    TRESTDWBsonType.MinKey             : WriteMinKey;
  else
    Assert(False);
  end;
end;

{ TRESTDWBsonWriter }

procedure TRESTDWBsonWriter.BackpatchSize;
var
  Size: Integer;
begin
  Assert(Assigned(FContext));
  Size := FOutput.Position - FContext^.StartPosition;
  FOutput.WriteInt32At(FContext^.StartPosition, Size);
end;

constructor TRESTDWBsonWriter.Create;
begin
  inherited Create;
  FOutput.Initialize;
  FContextIndex := -1;
end;

function TRESTDWBsonWriter.GetNextState: TRESTDWBsonWriterState;
begin
  Assert(Assigned(FContext));
  if (FContext^.ContextType = TRESTDWBsonContextType.&Array) then
    Result := TRESTDWBsonWriterState.Value
  else
    Result := TRESTDWBsonWriterState.Name;
end;

procedure TRESTDWBsonWriter.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWBsonWriter.PushContext(const AContextType: TRESTDWBsonContextType;
  const AStartPosition: Integer);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, AStartPosition);
  FContext := @FContextStack[FContextIndex];
end;

function TRESTDWBsonWriter.ToBson: TBytes;
begin
  Result := FOutput.ToBytes;
end;

procedure TRESTDWBsonWriter.WriteBinaryData(const AValue: TRESTDWBsonBinaryData);
var
  Bytes: TBytes;
  SubType: TRESTDWBsonBinarySubType;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  Bytes := AValue.AsBytes;
  SubType := AValue.SubType;
  if (SubType = TRESTDWBsonBinarySubType.OldBinary) then
    SubType := TRESTDWBsonBinarySubType.Binary;

  FOutput.WriteBsonType(TRESTDWBsonType.Binary);
  WriteNameHelper;

  FOutput.WriteInt32(Length(Bytes));
  FOutput.WriteBinarySubType(SubType);
  if Assigned(Bytes) then
    FOutput.Write(Bytes[0], Length(Bytes));
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteBoolean(const AValue: Boolean);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.Boolean);
  WriteNameHelper;
  FOutput.WriteBoolean(AValue);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteDateTime(const AMillisecondsSinceEpoch: Int64);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.DateTime);
  WriteNameHelper;
  FOutput.WriteInt64(AMillisecondsSinceEpoch);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteDouble(const AValue: Double);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.Double);
  WriteNameHelper;
  FOutput.WriteDouble(AValue);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteEndArray;
begin
  Assert(Assigned(FContext));
  if (State <> TRESTDWBsonWriterState.Value) or (FContext^.ContextType <> TRESTDWBsonContextType.&Array) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteByte(0);
  BackpatchSize;

  PopContext;
  if (FContext = nil) then
    State := TRESTDWBsonWriterState.Done
  else
    State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteEndDocument;
begin
  Assert(Assigned(FContext));
  if (State <> TRESTDWBsonWriterState.Name) or
    (not (FContext^.ContextType in [TRESTDWBsonContextType.Document, TRESTDWBsonContextType.ScopeDocument]))
  then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteByte(0);
  BackpatchSize;

  PopContext;
  if (FContext = nil) then
    State := TRESTDWBsonWriterState.Done
  else
  begin
    if (FContext^.ContextType = TRESTDWBsonContextType.JavaScriptWithScope) then
    begin
      BackpatchSize;
      PopContext;
    end;
    State := GetNextState;
  end;
end;

procedure TRESTDWBsonWriter.WriteInt32(const AValue: Integer);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.Int32);
  WriteNameHelper;
  FOutput.WriteInt32(AValue);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteInt64(const AValue: Int64);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.Int64);
  WriteNameHelper;
  FOutput.WriteInt64(AValue);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteJavaScript(const ACode: String);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.JavaScript);
  WriteNameHelper;
  FOutput.WriteString(ACode);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteJavaScriptWithScope(const ACode: String);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.JavaScriptWithScope);
  WriteNameHelper;
  PushContext(TRESTDWBsonContextType.JavaScriptWithScope, FOutput.Position);
  FOutput.WriteInt32(0);  // Reserve space
  FOutput.WriteString(ACode);
  State := TRESTDWBsonWriterState.ScopeDocument;
end;

procedure TRESTDWBsonWriter.WriteMaxKey;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.MaxKey);
  WriteNameHelper;
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteMinKey;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.MinKey);
  WriteNameHelper;
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteNameHelper;
var
  Index: Integer;
begin
  Assert(Assigned(FContext));
  if (FContext^.ContextType = TRESTDWBsonContextType.&Array) then
  begin
    Index := FContext^.Index;
    FContext^.Index := Index + 1;
    FOutput.WriteCString(TArrayElementNameAccelerator.GetElementNameBytes(Index));
  end
  else
    FOutput.WriteCString(Name);
end;

procedure TRESTDWBsonWriter.WriteNull;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.Null);
  WriteNameHelper;
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteObjectId(const AValue: TRESTDWObjectId);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.ObjectId);
  WriteNameHelper;
  FOutput.WriteObjectId(AValue);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteRawBsonDocument(const ADocument: TBytes);
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value,
    TRESTDWBsonWriterState.ScopeDocument, TRESTDWBsonWriterState.Done]))
  then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  if (State = TRESTDWBsonWriterState.Value) then
  begin
    FOutput.WriteBsonType(TRESTDWBsonType.Document);
    WriteNameHelper;
  end;

  FOutput.Write(ADocument[0], Length(ADocument));

  if (FContext = nil) then
    State := TRESTDWBsonWriterState.Done
  else
  begin
    if (FContext^.ContextType = TRESTDWBsonContextType.JavaScriptWithScope) then
    begin
      BackpatchSize;
      PopContext;
    end;
    State := GetNextState;
  end;
end;

procedure TRESTDWBsonWriter.WriteRegularExpression(
  const AValue: TRESTDWBsonRegularExpression);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.RegularExpression);
  WriteNameHelper;

  FOutput.WriteCString(AValue.Pattern);
  FOutput.WriteCString(AValue.Options);

  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteStartArray;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  if (State = TRESTDWBsonWriterState.Value) then
  begin
    FOutput.WriteBsonType(TRESTDWBsonType.&Array);
    WriteNameHelper;
  end;

  PushContext(TRESTDWBsonContextType.&Array, FOutput.Position);
  FOutput.WriteInt32(0); // Reserve space for size
  State := TRESTDWBsonWriterState.Value;
end;

procedure TRESTDWBsonWriter.WriteStartDocument;
var
  ContextType: TRESTDWBsonContextType;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value,
    TRESTDWBsonWriterState.ScopeDocument, TRESTDWBsonWriterState.Done]))
  then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  if (State = TRESTDWBsonWriterState.Value) then
  begin
    FOutput.WriteBsonType(TRESTDWBsonType.Document);
    WriteNameHelper;
  end;

  if (State = TRESTDWBsonWriterState.ScopeDocument) then
    ContextType := TRESTDWBsonContextType.ScopeDocument
  else
    ContextType := TRESTDWBsonContextType.Document;

  PushContext(ContextType, FOutput.Position);
  FOutput.WriteInt32(0); // Reserve space for size

  State := TRESTDWBsonWriterState.Name;
end;

procedure TRESTDWBsonWriter.WriteString(const AValue: String);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.&String);
  WriteNameHelper;
  FOutput.WriteString(AValue);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteSymbol(const AValue: String);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.Symbol);
  WriteNameHelper;
  FOutput.WriteString(AValue);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteTimestamp(const AValue: Int64);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.Timestamp);
  WriteNameHelper;
  FOutput.WriteInt64(AValue);
  State := GetNextState;
end;

procedure TRESTDWBsonWriter.WriteUndefined;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TRESTDWBsonType.Undefined);
  WriteNameHelper;
  State := GetNextState;
end;

{ TRESTDWBsonWriter.TOutput }

procedure TRESTDWBsonWriter.TOutput.Initialize;
begin
  SetLength(FBuffer, 256);
  FCapacity := 256;
  FSize := 0;
  SetLength(FTempBytes, TEMP_BYTES_LENGTH);
end;

function TRESTDWBsonWriter.TOutput.ToBytes: TBytes;
begin
  SetLength(FBuffer, FSize);
  Result := FBuffer;
end;

procedure TRESTDWBsonWriter.TOutput.Write(const AValue; const ASize: Integer);
begin
  if ((FSize + ASize) > FCapacity) then
  begin
    repeat
      FCapacity := FCapacity shl 1;
    until (FCapacity >= (FSize + ASize));
    SetLength(FBuffer, FCapacity);
  end;
  if (ASize > 0) then
  begin
    Move(AValue, FBuffer[FSize], ASize);
    Inc(FSize, ASize);
  end;
end;

procedure TRESTDWBsonWriter.TOutput.WriteBinarySubType(
  const ASubType: TRESTDWBsonBinarySubType);
begin
  Write(ASubType, 1);
end;

procedure TRESTDWBsonWriter.TOutput.WriteBoolean(const AValue: Boolean);
begin
  Write(AValue, 1);
end;

procedure TRESTDWBsonWriter.TOutput.WriteBsonType(const ABsonType: TRESTDWBsonType);
begin
  Write(ABsonType, 1);
end;

procedure TRESTDWBsonWriter.TOutput.WriteByte(const AValue: Byte);
begin
  Write(AValue, 1);
end;

procedure TRESTDWBsonWriter.TOutput.WriteCString(const AValue: String);
var
  CharCount, Utf8Count: Integer;
  Bytes: TBytes;
begin
  CharCount := AValue.Length;
  if (((CharCount + 1) * 3) <= TEMP_BYTES_LENGTH) then
  begin
    Bytes := FTempBytes;
    Utf8Count := goUtf16ToUtf8(AValue, CharCount, {$IFNDEF FPC}FTempBytes{$ELSE}Pointer(FTempBytes){$ENDIF});
  end
  else
  begin
    Bytes := goUtf16ToUtf8(AValue);
    Utf8Count := Length(Bytes);
  end;
  Write(Bytes[0], Utf8Count);
  WriteByte(0);
end;

procedure TRESTDWBsonWriter.TOutput.WriteCString(const AValue: TBytes);
begin
  Write(AValue[0], Length(AValue));
  WriteByte(0);
end;

procedure TRESTDWBsonWriter.TOutput.WriteDouble(const AValue: Double);
begin
  Write(AValue, 8);
end;

procedure TRESTDWBsonWriter.TOutput.WriteInt32(const AValue: Int32);
begin
  Write(AValue, 4);
end;

procedure TRESTDWBsonWriter.TOutput.WriteInt32At(const APosition, AValue: Int32);
begin
  Move(AValue, FBuffer[APosition], 4);
end;

procedure TRESTDWBsonWriter.TOutput.WriteInt64(const AValue: Int64);
begin
  Write(AValue, 8);
end;

procedure TRESTDWBsonWriter.TOutput.WriteObjectId(const AValue: TRESTDWObjectId);
begin
  AValue.ToByteArray(FTempBytes, 0);
  Write(FTempBytes[0], 12);
end;

procedure TRESTDWBsonWriter.TOutput.WriteString(const AValue: String);
var
  CharCount, Utf8Count: Integer;
  Bytes: TBytes;
begin
  CharCount := AValue.Length;
  if (((CharCount + 1) * 3) <= TEMP_BYTES_LENGTH) then
  begin
    Bytes := FTempBytes;
    Utf8Count := goUtf16ToUtf8(AValue, CharCount, {$IFNDEF FPC}Bytes{$ELSE}Pointer(Bytes){$ENDIF});
  end
  else
  begin
    Bytes := goUtf16ToUtf8(AValue);
    Utf8Count := Length(Bytes);
  end;
  WriteInt32(Utf8Count + 1);
  Write(Bytes[0], Utf8Count);
  WriteByte(0);
end;

{ TRESTDWBsonWriter.TContext }

procedure TRESTDWBsonWriter.TContext.Initialize(const AContextType: TRESTDWBsonContextType;
  const AStartPosition: Integer);
begin
  FStartPosition := AStartPosition;
  FIndex := 0;
  FContextType := AContextType;
end;

{ TRESTDWBsonWriter.TArrayElementNameAccelerator }

class constructor TRESTDWBsonWriter.TArrayElementNameAccelerator.Create;
var
  I: Integer;
begin
  for I := 0 to Length(FCachedElementNames) - 1 do
    FCachedElementNames[I] := CreateElementNameBytes(I);
end;

class function TRESTDWBsonWriter.TArrayElementNameAccelerator.CreateElementNameBytes(
  const AIndex: Integer): TBytes;
const
  ASCII_ZERO = 48;
var
  A, B, C, D, E, N: Integer;
begin
  N := AIndex;
  A := ASCII_ZERO + (N mod 10);
  B := ASCII_ZERO;
  C := ASCII_ZERO;
  D := ASCII_ZERO;
  E := ASCII_ZERO;
  N := N div 10;
  if (N > 0) then
  begin
    Inc(B, N mod 10);
    N := N div 10;
    if (N > 0) then
    begin
      Inc(C, N mod 10);
      N := N div 10;
      if (N > 0) then
      begin
        Inc(D, N mod 10);
        N := N div 10;
        if (N > 0) then
        begin
          Inc(E, N mod 10);
          N := N div 10;
        end;
      end;
    end;
  end;

  if (N = 0) then
  begin
    if (E <> ASCII_ZERO) then
      Exit(TBytes.Create(E, D, C, B, A));

    if (D <> ASCII_ZERO) then
      Exit(TBytes.Create(D, C, B, A));

    if (C <> ASCII_ZERO) then
      Exit(TBytes.Create(C, B, A));

    if (B <> ASCII_ZERO) then
      Exit(TBytes.Create(B, A));

    Exit(TBytes.Create(A));
  end;

  Result := BytesOf(AIndex.ToString);
end;

class function TRESTDWBsonWriter.TArrayElementNameAccelerator.GetElementNameBytes(
  const AIndex: Integer): TBytes;
begin
  Assert(AIndex >= 0);
  if (AIndex < Length(FCachedElementNames)) then
    Result := FCachedElementNames[AIndex]
  else
    Result := CreateElementNameBytes(AIndex);
end;

{ TRESTDWJsonWriter }

constructor TRESTDWJsonWriter.Create;
begin
  Create(TRESTDWJsonWriterSettings.Default);
end;

constructor TRESTDWJsonWriter.Create(const ASettings: TRESTDWJsonWriterSettings);
begin
  inherited Create;
  FSettings := ASettings;
  FOutput.Initialize;
  FContextIndex := -1;
  PushContext(TRESTDWBsonContextType.TopLevel, '');
end;

destructor TRESTDWJsonWriter.Destroy;
begin
  FOutput.Finalize;
  inherited;
end;

function TRESTDWJsonWriter.GetNextState: TRESTDWBsonWriterState;
begin
  Assert(Assigned(FContext));
  if (FContext^.ContextType in [TRESTDWBsonContextType.TopLevel, TRESTDWBsonContextType.&Array]) then
    Result := TRESTDWBsonWriterState.Value
  else
    Result := TRESTDWBsonWriterState.Name;
end;

class function TRESTDWJsonWriter.GuidToString(const ABytes: TBytes;
  const ASubType: TRESTDWBsonBinarySubType): String;
var
  Guid: TGUID;
  S: String;
begin
  if (Length(ABytes) <> 16) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);

  if (ASubType = TRESTDWBsonBinarySubType.UuidLegacy) then
  begin
    // We only support output to C# legacy
    Result := 'CSUUID("';
    Guid := TGuid.Create(ABytes, TEndian.Little);
  end
  else
  begin
    Result := 'UUID("';
    Guid := TGuid.Create(ABytes, TEndian.Big);
  end;

  S := Guid.ToString.ToLower; // Include '{' and '}'
  Result := Result + S.Substring(1, S.Length - 2) + '")';
end;

procedure TRESTDWJsonWriter.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWJsonWriter.PushContext(const AContextType: TRESTDWBsonContextType;
  const AIndentString: String);
var
  ParentContext: PContext;
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);

  if (FContextIndex > 0) then
    ParentContext := @FContextStack[FContextIndex - 1]
  else
    ParentContext := nil;

  FContextStack[FContextIndex].Initialize(ParentContext, AContextType, AIndentString);
  FContext := @FContextStack[FContextIndex];
end;

function TRESTDWJsonWriter.ToJson: String;
begin
  Result := FOutput.ToString;
end;

procedure TRESTDWJsonWriter.WriteBinaryData(const AValue: TRESTDWBsonBinaryData);
var
  SubType: TRESTDWBsonBinarySubType;
  Bytes: TBytes;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  SubType := AValue.SubType;
  Bytes := AValue.AsBytes;
  WriteNameHelper(Name);

  if (FSettings.OutputMode = TRESTDWJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$binary" : "');
    FOutput.Append(TEncoding.ANSI.GetString(goBase64Encode(Bytes)));
    FOutput.AppendFormat('", "$type" : "%.2x" }', [Ord(SubType)]);
  end
  else if (SubType in [TRESTDWBsonBinarySubType.UuidLegacy, TRESTDWBsonBinarySubType.UuidStandard]) then
    FOutput.Append(GuidToString(Bytes, SubType))
  else
  begin
    FOutput.Append('new BinData(');
    FOutput.Append(Ord(SubType));
    FOutput.Append(', "');
    FOutput.Append(TEncoding.ANSI.GetString(goBase64Encode(Bytes)));
    FOutput.Append('")');
  end;

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteBoolean(const AValue: Boolean);
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  if (AValue) then
    FOutput.Append('true')
  else
    FOutput.Append('false');
  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteDateTime(const AMillisecondsSinceEpoch: Int64);
var
  DateTime: TDateTime;
  S: String;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  if (FSettings.OutputMode = TRESTDWJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$date" : ');
    FOutput.Append(AMillisecondsSinceEpoch);
    FOutput.Append(' }');
  end
  else
  begin
    if (AMillisecondsSinceEpoch >= MIN_MILLISECONDS_SINCE_EPOCH) and
       (AMillisecondsSinceEpoch <= MAX_MILLISECONDS_SINCE_EPOCH) then
    begin
      DateTime := goToDateTimeFromMillisecondsSinceEpoch(AMillisecondsSinceEpoch, True);
      FOutput.Append('ISODate("');
      S := DateToISO8601(DateTime, True);
      if (S.EndsWith('.000Z')) then
        { Only include milliseconds if not 0 }
        S := S.Remove(S.Length - 5, 4);
      FOutput.Append(S);
      FOutput.Append('")');
    end
    else
    begin
      FOutput.Append('new Date(');
      FOutput.Append(AMillisecondsSinceEpoch);
      FOutput.Append(')');
    end;
  end;

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteDouble(const AValue: Double);
var
  S: String;
  I: Int64;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  S := FloatToStr(AValue, goUSFormatSettings);
  if (S = 'NAN') then
    S := 'NaN' // JSON compliant
  else if (S = 'INF') then
    S := 'Infinity'
  else if (S = '-INF') then
    S := '-Infinity'
  else if (TryStrToInt64(S, I)) then
    { If S looks like an integer, then add ".0" }
    S := S + '.0';

  FOutput.Append(S);

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteEndArray;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.Append(']');
  PopContext;
  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteEndDocument;
begin
  if (State <> TRESTDWBsonWriterState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  Assert(Assigned(FContext));
  if (FSettings.PrettyPrint) and (FContext^.HasElements) then
  begin
    FOutput.Append(FSettings.LineBreak);
    if (FContextIndex > 0) then
      FOutput.Append(FContextStack[FContextIndex - 1].Indentation);
    FOutput.Append('}');
  end
  else
    FOutput.Append(' }');

  if (FContext^.ContextType = TRESTDWBsonContextType.ScopeDocument) then
  begin
    PopContext;
    WriteEndDocument;
  end
  else
    PopContext;

  if (FContext = nil) then
    State := TRESTDWBsonWriterState.Done
  else
    State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteEscapedString(const AValue: String);
var
  I: Integer;
  C: Char;
begin
  for I := Low(String) to Low(String) + Length(AValue) - 1 do
  begin
    C := AValue[I];
    case C of
      '"', '\':
        begin
          FOutput.Append('\');
          FOutput.Append(C);
        end;

       #8: FOutput.Append('\b');
       #9: FOutput.Append('\t');
      #10: FOutput.Append('\n');
      #12: FOutput.Append('\f');
      #13: FOutput.Append('\r');
    else
      if (C < ' ') or (C >= #$0080) then
      begin
        FOutput.Append('\u');
        FOutput.Append(LowerCase(IntToHex(Ord(C), 4)));
      end
      else
        FOutput.Append(C);
    end;
  end;
end;

procedure TRESTDWJsonWriter.WriteInt32(const AValue: Integer);
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  FOutput.Append(AValue);
  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteInt64(const AValue: Int64);
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TRESTDWJsonOutputMode.Strict) then
    FOutput.Append(AValue)
  else
  begin
    if (AValue >= Integer.MinValue) and (AValue <= Integer.MaxValue) then
    begin
      FOutput.Append('NumberLong(');
      FOutput.Append(AValue);
      FOutput.Append(')');
    end
    else
    begin
      FOutput.Append('NumberLong("');
      FOutput.Append(AValue);
      FOutput.Append('")');
    end;
  end;

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteJavaScript(const ACode: String);
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  FOutput.Append('{ "$code" : "');
  WriteEscapedString(ACode);
  FOutput.Append('" }');
  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteJavaScriptWithScope(const ACode: String);
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteStartDocument;
  WriteName('$code');
  WriteString(ACode);
  WriteName('$scope');

  State := TRESTDWBsonWriterState.ScopeDocument;
end;

procedure TRESTDWJsonWriter.WriteMaxKey;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TRESTDWJsonOutputMode.Strict) then
    FOutput.Append('{ "$maxKey" : 1 }')
  else
    FOutput.Append('MaxKey');

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteMinKey;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TRESTDWJsonOutputMode.Strict) then
    FOutput.Append('{ "$minKey" : 1 }')
  else
    FOutput.Append('MinKey');

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteNameHelper(const AName: String);
begin
  Assert(Assigned(FContext));
  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array:
      begin
        if (FContext^.HasElements) then
          FOutput.Append(', ');
      end;

    TRESTDWBsonContextType.Document,
    TRESTDWBsonContextType.ScopeDocument:
      begin
        if (FContext^.HasElements) then
          FOutput.Append(',');

        if (FSettings.PrettyPrint) then
        begin
          FOutput.Append(FSettings.LineBreak);
          FOutput.Append(FContext^.Indentation);
        end
        else
          FOutput.Append(' ');

        WriteQuotedString(AName);
        FOutput.Append(' : ');
      end;

    TRESTDWBsonContextType.TopLevel: ;
  else
    Assert(False);
  end;
  FContext^.HasElements := True;
end;

procedure TRESTDWJsonWriter.WriteNull;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  FOutput.Append('null');
  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteObjectId(const AValue: TRESTDWObjectId);
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TRESTDWJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$oid" : "');
    FOutput.Append(AValue.ToString);
    FOutput.Append('" }');
  end
  else
  begin
    FOutput.Append('ObjectId("');
    FOutput.Append(AValue.ToString);
    FOutput.Append('")');
  end;

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteQuotedString(const AValue: String);
begin
  FOutput.Append('"');
  WriteEscapedString(AValue);
  FOutput.Append('"');
end;

procedure TRESTDWJsonWriter.WriteRaw(const AValue: String);
begin
  FOutput.Append(AValue)
end;

procedure TRESTDWJsonWriter.WriteRegularExpression(
  const AValue: TRESTDWBsonRegularExpression);
var
  Pattern, Options: String;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  Pattern := AValue.Pattern;
  Options := AValue.Options;

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TRESTDWJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$regex" : "');
    WriteEscapedString(Pattern);
    FOutput.Append('", "$options" : "');
    WriteEscapedString(Options);
    FOutput.Append('" }');
  end
  else
  begin
    if (Pattern = '') then
      Pattern := '(?:)'
    else
      Pattern := Pattern.Replace('/', '\/', [rfReplaceAll]);
    FOutput.Append('/');
    FOutput.Append(Pattern);
    FOutput.Append('/');
    FOutput.Append(Options);
  end;

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteStartArray;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  FOutput.Append('[');

  PushContext(TRESTDWBsonContextType.&Array, FSettings.Indent);
  State := TRESTDWBsonWriterState.Value;
end;

procedure TRESTDWJsonWriter.WriteStartDocument;
var
  ContextType: TRESTDWBsonContextType;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value, TRESTDWBsonWriterState.ScopeDocument])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  if (State in [TRESTDWBsonWriterState.Value, TRESTDWBsonWriterState.ScopeDocument]) then
    WriteNameHelper(Name);

  FOutput.Append('{');

  if (State = TRESTDWBsonWriterState.ScopeDocument) then
    ContextType := TRESTDWBsonContextType.ScopeDocument
  else
    ContextType := TRESTDWBsonContextType.Document;

  PushContext(ContextType, FSettings.Indent);
  State := TRESTDWBsonWriterState.Name;
end;

procedure TRESTDWJsonWriter.WriteString(const AValue: String);
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  WriteQuotedString(AValue);
  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteSymbol(const AValue: String);
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  FOutput.Append('{ "$symbol" : "');
  WriteEscapedString(AValue);
  FOutput.Append('" }');

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteTimestamp(const AValue: Int64);
var
  SecondsSinceEpoch, Increment: Integer;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  SecondsSinceEpoch := AValue shr 32;
  Increment := AValue and $FFFFFFFF;

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TRESTDWJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$timestamp" : { "t" : ');
    FOutput.Append(SecondsSinceEpoch);
    FOutput.Append(', "i" : ');
    FOutput.Append(Increment);
    FOutput.Append(' } }');
  end
  else
  begin
    FOutput.Append('Timestamp(');
    FOutput.Append(SecondsSinceEpoch);
    FOutput.Append(', ');
    FOutput.Append(Increment);
    FOutput.Append(')');
  end;

  State := GetNextState;
end;

procedure TRESTDWJsonWriter.WriteUndefined;
begin
  if (not (State in [TRESTDWBsonWriterState.Initial, TRESTDWBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TRESTDWJsonOutputMode.Strict) then
    FOutput.Append('{ "$undefined" : true }')
  else
    FOutput.Append('undefined');

  State := GetNextState;
end;

{ TRESTDWJsonWriter.TContext }

procedure TRESTDWJsonWriter.TContext.Initialize(const AParentContext: PContext;
  const AContextType: TRESTDWBsonContextType;
  const AIndentString: String);
begin
  if Assigned(AParentContext) then
    FIndentation := AParentContext^.FIndentation + AIndentString
  else
    FIndentation := AIndentString;
  FContextType := AContextType;
  FHasElements := False;
end;

{ TRESTDWJsonWriter.TOutput }

procedure TRESTDWJsonWriter.TOutput.Append(const AValue: String);
begin
  if (AValue <> '') then
    Append(AValue[Low(String)], Length(AValue) * SizeOf(Char));
end;

procedure TRESTDWJsonWriter.TOutput.Append(const AValue: Integer);
begin
  Append(IntToStr(AValue));
end;

procedure TRESTDWJsonWriter.TOutput.Append(const AValue: Int64);
begin
  Append(IntToStr(AValue));
end;

procedure TRESTDWJsonWriter.TOutput.Append(const AValue; const ASize: Integer);
begin
  if ((FSize + ASize) > FCapacity) then
  begin
    repeat
      FCapacity := FCapacity shl 1;
    until (FCapacity >= (FSize + ASize));
    ReallocMem(FBuffer, FCapacity);
  end;
  if (ASize > 0) then
  begin
    Move(AValue, FBuffer[FSize], ASize);
    Inc(FSize, ASize);
  end;
end;

procedure TRESTDWJsonWriter.TOutput.Append(const AValue: Char);
begin
  Append(AValue, SizeOf(Char));
end;

procedure TRESTDWJsonWriter.TOutput.AppendFormat(const AValue: String;
  const AArgs: array of const);
begin
  Append(Format(AValue, AArgs));
end;

procedure TRESTDWJsonWriter.TOutput.Finalize;
begin
  FreeMem(FBuffer);
  FBuffer := nil;
end;

procedure TRESTDWJsonWriter.TOutput.Initialize;
begin
  GetMem(FBuffer, 512);
  FCapacity := 512;
  FSize := 0;
end;

function TRESTDWJsonWriter.TOutput.ToString: String;
begin
  SetString(Result, PChar(FBuffer), FSize shr 1);
end;

{ TRESTDWBsonDocumentWriter }

procedure TRESTDWBsonDocumentWriter.AddValue(const AValue: TRESTDWBsonValue);
begin
  Assert(Assigned(FContext));
  if (FContext^.ContextType = TRESTDWBsonContextType.&Array) then
    FContext^.&Array.Add(AValue)
  else
    FContext^.Document.Add(FContext^.Name, AValue);
end;

constructor TRESTDWBsonDocumentWriter.Create(const ADocument: TRESTDWBsonDocument);
begin
  inherited Create;
  FDocument := ADocument;
  FContextIndex := -1;
end;

function TRESTDWBsonDocumentWriter.GetDocument: TRESTDWBsonDocument;
begin
  Result := FDocument;
end;

function TRESTDWBsonDocumentWriter.GetNextState: TRESTDWBsonWriterState;
begin
  Assert(Assigned(FContext));
  if (FContext^.ContextType = TRESTDWBsonContextType.&Array) then
    Result := TRESTDWBsonWriterState.Value
  else
    Result := TRESTDWBsonWriterState.Name;
end;

procedure TRESTDWBsonDocumentWriter.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWBsonDocumentWriter.PushContext(
  const AContextType: TRESTDWBsonContextType; const ACode: String);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, ACode);
  FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWBsonDocumentWriter.PushContext(
  const AContextType: TRESTDWBsonContextType; const AArray: TRESTDWBsonArray);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, AArray);
  FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWBsonDocumentWriter.PushContext(
  const AContextType: TRESTDWBsonContextType; const ADocument: TRESTDWBsonDocument);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, ADocument);
  FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWBsonDocumentWriter.WriteBinaryData(
  const AValue: TRESTDWBsonBinaryData);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  {$IFNDEF FPC}
   AddValue(AValue);
  {$ELSE}
   AddValue(TRESTDWBsonValue(AValue));
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteBoolean(const AValue: Boolean);
{$IFDEF FPC}
Var
 vRESTDWBsonValue : TRESTDWBsonValue;
{$ENDIF}
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  {$IFNDEF FPC}
   AddValue(AValue);
  {$ELSE}
   vRESTDWBsonValue          := TRESTDWBsonValue.Create;
   Try
    AddValue(vRESTDWBsonValue.Implicit(AValue));
   Finally
    FreeAndNil(vRESTDWBsonValue);
   End;
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteDateTime(
  const AMillisecondsSinceEpoch: Int64);
{$IFDEF FPC}
Var
 vRESTDWBsonValue : TRESTDWBsonValue;
{$ENDIF}
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  {$IFNDEF FPC}
   AddValue(TRESTDWBsonDateTime.Create(AMillisecondsSinceEpoch));
  {$ELSE}
   vRESTDWBsonValue          := TRESTDWBsonValue.Create;
   Try
    AddValue(vRESTDWBsonValue.Implicit(AMillisecondsSinceEpoch));
   Finally
    FreeAndNil(vRESTDWBsonValue);
   End;
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteDouble(const AValue: Double);
{$IFDEF FPC}
Var
 vRESTDWBsonValue : TRESTDWBsonValue;
{$ENDIF}
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  {$IFNDEF FPC}
   AddValue(AValue);
  {$ELSE}
   vRESTDWBsonValue          := TRESTDWBsonValue.Create;
   Try
    AddValue(vRESTDWBsonValue.Implicit(AValue));
   Finally
    FreeAndNil(vRESTDWBsonValue);
   End;
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteEndArray;
Var
 A : TRESTDWBsonArray;
begin
  Assert(Assigned(FContext));
  if (State <> TRESTDWBsonWriterState.Value) or (FContext^.ContextType <> TRESTDWBsonContextType.&Array) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  A := FContext^.&Array;
  PopContext;
  {$IFNDEF FPC}
   AddValue(A);
  {$ELSE}
   AddValue(TRESTDWBsonValue(A));
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteEndDocument;
var
  Document: TRESTDWBsonDocument;
  Code: String;
begin
  Assert(Assigned(FContext));
  if (State <> TRESTDWBsonWriterState.Name) or (not (FContext^.ContextType in [TRESTDWBsonContextType.Document, TRESTDWBsonContextType.ScopeDocument])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  Document := FContext^.Document;
  if (FContext^.ContextType = TRESTDWBsonContextType.ScopeDocument) then
  begin
    PopContext;
    Assert(Assigned(FContext));
    Code := FContext^.Code;
    PopContext;
    AddValue({$IFDEF FPC}TRESTDWBsonValue({$ENDIF}TRESTDWBsonJavaScriptWithScope.Create(Code, Document){$IFDEF FPC}){$ENDIF});
  end
  else
  begin
    PopContext;
    if (FContext <> nil) then
      AddValue({$IFDEF FPC}TRESTDWBsonValue({$ENDIF}Document{$IFDEF FPC}){$ENDIF});
  end;

  if (FContext = nil) then
    State := TRESTDWBsonWriterState.Done
  else
    State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteInt32(const AValue: Integer);
{$IFDEF FPC}
Var
 vRESTDWBsonValue : TRESTDWBsonValue;
{$ENDIF}
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  {$IFNDEF FPC}
   AddValue(AValue);
  {$ELSE}
   vRESTDWBsonValue          := TRESTDWBsonValue.Create;
   Try
    AddValue(vRESTDWBsonValue.Implicit(AValue));
   Finally
    FreeAndNil(vRESTDWBsonValue);
   End;
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteInt64(const AValue: Int64);
{$IFDEF FPC}
Var
 vRESTDWBsonValue : TRESTDWBsonValue;
{$ENDIF}
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  {$IFNDEF FPC}
   AddValue(AValue);
  {$ELSE}
   vRESTDWBsonValue          := TRESTDWBsonValue.Create;
   Try
    AddValue(vRESTDWBsonValue.Implicit(AValue));
   Finally
    FreeAndNil(vRESTDWBsonValue);
   End;
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteJavaScript(const ACode: String);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue({$IFDEF FPC}TRESTDWBsonValue({$ENDIF}TRESTDWBsonJavaScript.Create(ACode){$IFDEF FPC}){$ENDIF});
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteJavaScriptWithScope(const ACode: String);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  PushContext(TRESTDWBsonContextType.JavaScriptWithScope, ACode);
  State := TRESTDWBsonWriterState.ScopeDocument;
end;

procedure TRESTDWBsonDocumentWriter.WriteMaxKey;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue({$IFDEF FPC}TRESTDWBsonValue({$ENDIF}TRESTDWBsonMaxKey.Value{$IFDEF FPC}){$ENDIF});
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteMinKey;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue({$IFDEF FPC}TRESTDWBsonValue({$ENDIF}TRESTDWBsonMinKey.Value{$IFDEF FPC}){$ENDIF});
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteName(const AName: String);
begin
  inherited;
  Assert(Assigned(FContext));
  FContext^.Name := AName;
end;

procedure TRESTDWBsonDocumentWriter.WriteNull;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue({$IFDEF FPC}TRESTDWBsonValue({$ENDIF}TRESTDWBsonNull.Value{$IFDEF FPC}){$ENDIF});
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteObjectId(const AValue: TRESTDWObjectId);
{$IFDEF FPC}
Var
 vRESTDWBsonValue : TRESTDWBsonValue;
{$ENDIF}
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  {$IFNDEF FPC}
   AddValue(AValue);
  {$ELSE}
   vRESTDWBsonValue          := TRESTDWBsonValue.Create;
   Try
    AddValue(vRESTDWBsonValue.Implicit(AValue));
   Finally
    FreeAndNil(vRESTDWBsonValue);
   End;
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteRegularExpression(
  const AValue: TRESTDWBsonRegularExpression);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue({$IFDEF FPC}TRESTDWBsonValue({$ENDIF}AValue{$IFDEF FPC}){$ENDIF});
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteStartArray;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  PushContext(TRESTDWBsonContextType.&Array, TRESTDWBsonArray.Create);
  State := TRESTDWBsonWriterState.Value;
end;

procedure TRESTDWBsonDocumentWriter.WriteStartDocument;
begin
  case State of
    TRESTDWBsonWriterState.Initial,
    TRESTDWBsonWriterState.Done:
      PushContext(TRESTDWBsonContextType.Document, FDocument);

    TRESTDWBsonWriterState.Value:
      PushContext(TRESTDWBsonContextType.Document, TRESTDWBsonDocument.Create);

    TRESTDWBsonWriterState.ScopeDocument:
      PushContext(TRESTDWBsonContextType.ScopeDocument, TRESTDWBsonDocument.Create);
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  end;
  State := TRESTDWBsonWriterState.Name;
end;

procedure TRESTDWBsonDocumentWriter.WriteString(const AValue: String);
{$IFDEF FPC}
Var
 vRESTDWBsonValue : TRESTDWBsonValue;
{$ENDIF}
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  {$IFNDEF FPC}
   AddValue(AValue);
  {$ELSE}
   vRESTDWBsonValue          := TRESTDWBsonValue.Create;
   Try
    AddValue(vRESTDWBsonValue.Implicit(AValue));
   Finally
    FreeAndNil(vRESTDWBsonValue);
   End;
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteSymbol(const AValue: String);
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue({$IFDEF FPC}TRESTDWBsonValue({$ENDIF}TRESTDWBsonSymbolTable.Lookup(AValue){$IFDEF FPC}){$ENDIF});
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteTimestamp(const AValue: Int64);
{$IFDEF FPC}
Var
 vRESTDWBsonValue : TRESTDWBsonValue;
{$ENDIF}
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  {$IFNDEF FPC}
   AddValue(TRESTDWBsonTimestamp.Create(AValue));
  {$ELSE}
   vRESTDWBsonValue          := TRESTDWBsonValue.Create;
   Try
    AddValue(vRESTDWBsonValue.Implicit(AValue));
   Finally
    FreeAndNil(vRESTDWBsonValue);
   End;
  {$ENDIF}
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentWriter.WriteUndefined;
begin
  if (State <> TRESTDWBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue({$IFDEF FPC}TRESTDWBsonValue({$ENDIF}TRESTDWBsonUndefined.Value{$IFDEF FPC}){$ENDIF});
  State := GetNextState;
end;

{ TRESTDWBsonDocumentWriter.TContext }

procedure TRESTDWBsonDocumentWriter.TContext.Initialize(
  const AContextType: TRESTDWBsonContextType; const ADocument: TRESTDWBsonDocument);
begin
  FContextType := AContextType;
  FDocument := ADocument;
end;

procedure TRESTDWBsonDocumentWriter.TContext.Initialize(
  const AContextType: TRESTDWBsonContextType; const AArray: TRESTDWBsonArray);
begin
  FContextType := AContextType;
  FArray := AArray;
end;

procedure TRESTDWBsonDocumentWriter.TContext.Initialize(
  const AContextType: TRESTDWBsonContextType; const ACode: String);
begin
  FContextType := AContextType;
  FCode := ACode;
end;

{ TRESTDWBsonBaseReader }

function TRESTDWBsonBaseReader.DoReadJavaScriptWithScope: TRESTDWBsonValue;
var
  Code: String;
  Scope: TRESTDWBsonDocument;
begin
  Code := ReadJavaScriptWithScope;
  Scope := ReadDocument;
  Result := {$IFDEF FPC}TRESTDWBsonValue({$ENDIF}TRESTDWBsonJavaScriptWithScope.Create(Code, Scope){$IFDEF FPC}){$ENDIF};
end;

procedure TRESTDWBsonBaseReader.EnsureBsonTypeEquals(const ABsonType: TRESTDWBsonType);
begin
  if (GetCurrentBsonType <> ABsonType) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
end;

function TRESTDWBsonBaseReader.GetCurrentBsonType: TRESTDWBsonType;
begin
  if (FState in [TRESTDWBsonReaderState.Initial, TRESTDWBsonReaderState.ScopeDocument, TRESTDWBsonReaderState.&Type]) then
    ReadBsonType;

  if (FState <> TRESTDWBsonReaderState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  Result := FCurrentBsonType;
end;

function TRESTDWBsonBaseReader.GetState: TRESTDWBsonReaderState;
begin
  Result := FState;
end;

function TRESTDWBsonBaseReader.ReadArray: TRESTDWBsonArray;
var
  Item: TRESTDWBsonValue._IValue;
  Arr: TRESTDWBsonArray._IArray;
begin
  EnsureBsonTypeEquals(TRESTDWBsonType.&Array);

  ReadStartArray;
  Result := TRESTDWBsonArray.Create;
  Arr := Result._Impl;
  while (ReadBsonType <> TRESTDWBsonType.EndOfDocument) do
  begin
    Item := ReadValueIntf;
    Arr.Add(Item);
  end;
  ReadEndArray;
end;

function TRESTDWBsonBaseReader.ReadArrayIntf: TRESTDWBsonArray._IArray;
var
  Item: TRESTDWBsonValue._IValue;
begin
  EnsureBsonTypeEquals(TRESTDWBsonType.&Array);

  ReadStartArray;
  Result := _goCreateArray;
  while (ReadBsonType <> TRESTDWBsonType.EndOfDocument) do
  begin
    Item := ReadValueIntf;
    Result.Add(Item);
  end;
  ReadEndArray;
end;

function TRESTDWBsonBaseReader.ReadBinaryDataIntf: TRESTDWBsonValue._IValue;
var
  Value: TRESTDWBsonBinaryData;
begin
  Value := ReadBinaryData;
  Result := Value._Impl;
end;

function TRESTDWBsonBaseReader.ReadDocument: TRESTDWBsonDocument;
var
  Doc: TRESTDWBsonDocument._IDocument;
  Name: String;
  Value: TRESTDWBsonValue._IValue;
begin
  EnsureBsonTypeEquals(TRESTDWBsonType.Document);

  ReadStartDocument;

  Result := TRESTDWBsonDocument.Create(FAllowDuplicateNames);

  Doc := Result._Impl;

  while (ReadBsonType <> TRESTDWBsonType.EndOfDocument) do
  begin
    Name := ReadName;
    Value := ReadValueIntf;
    Doc.Add(Name, Value);
  end;

  ReadEndDocument;
end;

function TRESTDWBsonBaseReader.ReadDocumentIntf: TRESTDWBsonDocument._IDocument;
var
  Name: String;
  Value: TRESTDWBsonValue._IValue;
begin
  EnsureBsonTypeEquals(TRESTDWBsonType.Document);

  ReadStartDocument;

  Result := _goCreateDocument;
  Result.AllowDuplicateNames := FAllowDuplicateNames;

  while (ReadBsonType <> TRESTDWBsonType.EndOfDocument) do
  begin
    Name := ReadName;
    Value := ReadValueIntf;
    Result.Add(Name, Value);
  end;

  ReadEndDocument;
end;

function TRESTDWBsonBaseReader.ReadJavaScriptIntf: TRESTDWBsonValue._IValue;
var
  Value: TRESTDWBsonJavaScript;
begin
  Value := TRESTDWBsonJavaScript.Create(ReadJavaScript);
  Result := Value._Impl;
end;

function TRESTDWBsonBaseReader.ReadJavaScriptWithScopeIntf: TRESTDWBsonValue._IValue;
var
  Value: TRESTDWBsonValue;
begin
  Value := DoReadJavaScriptWithScope;
  Result := Value._Impl;
end;

function TRESTDWBsonBaseReader.ReadRegularExpressionIntf: TRESTDWBsonValue._IValue;
var
  Value: TRESTDWBsonRegularExpression;
begin
  Value := ReadRegularExpression;
  Result := Value._Impl;
end;

function TRESTDWBsonBaseReader.ReadStringIntf: TRESTDWBsonValue._IValue;
begin
  Result := _goBsonValueFromString(ReadString);
end;

function TRESTDWBsonBaseReader.ReadSymbolIntf: TRESTDWBsonValue._IValue;
var
  Value: TRESTDWBsonSymbol;
begin
  Value := TRESTDWBsonSymbolTable.Lookup(ReadSymbol);
  Result := Value._Impl;
end;

function TRESTDWBsonBaseReader.ReadTimeStampIntf: TRESTDWBsonValue._IValue;
var
  Value: TRESTDWBsonTimestamp;
begin
  Value := TRESTDWBsonTimestamp.Create(ReadTimestamp);
  Result := Value._Impl;
end;

function TRESTDWBsonBaseReader.ReadValue: TRESTDWBsonValue;
begin
  Result._Impl := ReadValueIntf;
end;

function TRESTDWBsonBaseReader.ReadValueIntf: TRESTDWBsonValue._IValue;
begin
  case GetCurrentBsonType of
    TRESTDWBsonType.EndOfDocument: ;
    TRESTDWBsonType.Double: Result := _goBsonValueFromDouble(ReadDouble);
    TRESTDWBsonType.&String: Result := ReadStringIntf;
    TRESTDWBsonType.Document: Result := ReadDocumentIntf;
    TRESTDWBsonType.&Array: Result := ReadArrayIntf;
    TRESTDWBsonType.Binary: Result := ReadBinaryDataIntf;
    TRESTDWBsonType.Undefined: begin ReadUndefined; Result := TRESTDWBsonUndefined.Value._Value end;
    TRESTDWBsonType.ObjectId: Result := _goBsonValueFromObjectId(ReadObjectId);
    TRESTDWBsonType.Boolean: Result := _goBsonValueFromBoolean(ReadBoolean);
    TRESTDWBsonType.DateTime: Result := _goBsonValueFromDateTime(ReadDateTime);
    TRESTDWBsonType.Null: begin ReadNull; Result := TRESTDWBsonNull.Value._Value end;
    TRESTDWBsonType.RegularExpression: Result := ReadRegularExpressionIntf;
    TRESTDWBsonType.JavaScript: Result := ReadJavaScriptIntf;
    TRESTDWBsonType.Symbol: Result := ReadSymbolIntf;
    TRESTDWBsonType.JavaScriptWithScope: Result := ReadJavaScriptWithScopeIntf;
    TRESTDWBsonType.Int32: Result := _goBsonValueFromInt32(ReadInt32);
    TRESTDWBsonType.Timestamp: Result := ReadTimeStampIntf;
    TRESTDWBsonType.Int64: Result := _goBsonValueFromInt64(ReadInt64);
    TRESTDWBsonType.MaxKey: begin ReadMaxKey; Result := TRESTDWBsonMaxKey.Value._Value end;
    TRESTDWBsonType.MinKey: begin ReadMinKey; Result := TRESTDWBsonMinKey.Value._Value end;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TRESTDWBsonBaseReader.VerifyBsonType(
  const ARequiredBsonType: TRESTDWBsonType);
begin
  if (FState in [TRESTDWBsonReaderState.Initial, TRESTDWBsonReaderState.ScopeDocument, TRESTDWBsonReaderState.&Type]) then
    ReadBsonType;

  if (FState = TRESTDWBsonReaderState.Name) then
    SkipName;

  if (FState <> TRESTDWBsonReaderState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (FCurrentBsonType <> ARequiredBsonType) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
end;

{ TRESTDWBsonBaseReader.TBookmark }

constructor TRESTDWBsonBaseReader.TBookmark.Create(const AState: TRESTDWBsonReaderState;
  const ACurrentBsonType: TRESTDWBsonType; const ACurrentName: String);
begin
  inherited Create;
  FState := AState;
  FCurrentBsonType := ACurrentBsonType;
  FCurrentName := ACurrentName;
end;

function TRESTDWBsonBaseReader.TBookmark.GetCurrentBsonType: TRESTDWBsonType;
begin
  Result := FCurrentBsonType;
end;

function TRESTDWBsonBaseReader.TBookmark.GetCurrentName: String;
begin
  Result := FCurrentName;
end;

function TRESTDWBsonBaseReader.TBookmark.GetState: TRESTDWBsonReaderState;
begin
  Result := FState;
end;

{ TRESTDWBsonReader }

constructor TRESTDWBsonReader.Create(const ABson: TBytes);
begin
  inherited Create;
  FInput.Initialize(ABson);
  PushContext(TRESTDWBsonContextType.TopLevel, 0, 0);
end;

function TRESTDWBsonReader.EndOfStream: Boolean;
begin
  Result := (FInput.Position >= FInput.Size);
end;

function TRESTDWBsonReader.GetBookmark: IgoBsonReaderBookmark;
begin
  Result := TBsonBookmark.Create(State, CurrentBsonType, CurrentName,
    FContextIndex, FInput.Position);
end;

function TRESTDWBsonReader.GetNextState: TRESTDWBsonReaderState;
begin
  Assert(Assigned(FContext));
  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.Document,
    TRESTDWBsonContextType.ScopeDocument:
      Result := TRESTDWBsonReaderState.&Type;

    TRESTDWBsonContextType.TopLevel:
      Result := TRESTDWBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

class function TRESTDWBsonReader.Load(const AFilename: String): IgoBsonReader;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
  try
    Result := Load(Stream);
  finally
    Stream.Free;
  end;
end;

class function TRESTDWBsonReader.Load(const AStream: TStream): IgoBsonReader;
var
  Bson: TBytes;
begin
  SetLength(Bson, AStream.Size - AStream.Position);
  AStream.ReadBuffer(Bson[0], Length(Bson));
  Result := TRESTDWBsonReader.Create(Bson);
end;

procedure TRESTDWBsonReader.PopContext(const APosition: Integer);
var
  ActualSize: Integer;
begin
  Assert(Assigned(FContext));
  ActualSize := APosition - FContext^.FStartPosition;
  if (ActualSize <> FContext^.FSize) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);

  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWBsonReader.PushContext(const AContextType: TRESTDWBsonContextType;
  const AStartPosition, ASize: Integer);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, AStartPosition, ASize);
  FContext := @FContextStack[FContextIndex];
end;

function TRESTDWBsonReader.ReadBinaryData: TRESTDWBsonBinaryData;
var
  Size, Size2: Integer;
  SubType: TRESTDWBsonBinarySubType;
  Bytes: TBytes;
begin
  VerifyBsonType(TRESTDWBsonType.Binary);
  Size := ReadSize;

  SubType := FInput.ReadBinarySubType;
  if (SubType = TRESTDWBsonBinarySubType.OldBinary) then
  begin
    Size2 := ReadSize;
    if (Size2 <> (Size - 4)) then
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);

    Size := Size2;
    SubType := TRESTDWBsonBinarySubType.Binary;
  end;

  SetLength(Bytes, Size);
  FInput.Read(Bytes[0], Size);
  State := GetNextState;

  Result := TRESTDWBsonBinaryData.Create(Bytes, SubType);
end;

function TRESTDWBsonReader.ReadBoolean: Boolean;
begin
  VerifyBsonType(TRESTDWBsonType.Boolean);
  State := GetNextState;
  Result := FInput.ReadBoolean;
end;

function TRESTDWBsonReader.ReadBsonType: TRESTDWBsonType;
begin
  if (State in [TRESTDWBsonReaderState.Initial, TRESTDWBsonReaderState.ScopeDocument]) then
  begin
    CurrentBsonType := TRESTDWBsonType.Document;
    State := TRESTDWBsonReaderState.Value;
    Exit(CurrentBsonType);
  end;

  if (State <> TRESTDWBsonReaderState.&Type) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  Assert(Assigned(FContext));
  if (FContext^.ContextType = TRESTDWBsonContextType.&Array) then
    Inc(FContext^.FCurrentArrayIndex);

  CurrentBsonType := FInput.ReadBsonType;

  if (CurrentBsonType = TRESTDWBsonType.EndOfDocument) then
  begin
    case FContext^.ContextType of
      TRESTDWBsonContextType.&Array:
        State := TRESTDWBsonReaderState.EndOfArray;

      TRESTDWBsonContextType.Document,
      TRESTDWBsonContextType.ScopeDocument:
        State := TRESTDWBsonReaderState.EndOfDocument;
    else
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
    end;
  end
  else
  begin
    case FContext^.ContextType of
      TRESTDWBsonContextType.&Array:
        begin
          FInput.SkipCString;
          State := TRESTDWBsonReaderState.Value;
        end;

      TRESTDWBsonContextType.Document,
      TRESTDWBsonContextType.ScopeDocument:
        State := TRESTDWBsonReaderState.Name;
    else
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
    end;
  end;
  Result := CurrentBsonType;
end;

function TRESTDWBsonReader.ReadBytes: TBytes;
var
  Size: Integer;
  SubType: TRESTDWBsonBinarySubType;
begin
  VerifyBsonType(TRESTDWBsonType.Binary);

  Size := ReadSize;
  SubType := FInput.ReadBinarySubType;
  if (not (SubType in [TRESTDWBsonBinarySubType.Binary, TRESTDWBsonBinarySubType.OldBinary])) then
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);

  State := GetNextState;
  Result := FInput.ReadBytes(Size);
end;

function TRESTDWBsonReader.ReadDateTime: Int64;
begin
  VerifyBsonType(TRESTDWBsonType.DateTime);
  State := GetNextState;
  Result := FInput.ReadInt64;
end;

function TRESTDWBsonReader.ReadDouble: Double;
begin
  VerifyBsonType(TRESTDWBsonType.Double);
  State := GetNextState;
  Result := FInput.ReadDouble;
end;

procedure TRESTDWBsonReader.ReadEndArray;
begin
  Assert(Assigned(FContext));
  if (FContext^.ContextType <> TRESTDWBsonContextType.&Array) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (State = TRESTDWBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TRESTDWBsonReaderState.EndOfArray) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  PopContext(FInput.Position);
  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.Document:
      State := TRESTDWBsonReaderState.&Type;

    TRESTDWBsonContextType.TopLevel:
      State := TRESTDWBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TRESTDWBsonReader.ReadEndDocument;
begin
  Assert(Assigned(FContext));
  if (not (FContext^.ContextType in [TRESTDWBsonContextType.Document, TRESTDWBsonContextType.ScopeDocument])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (State = TRESTDWBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TRESTDWBsonReaderState.EndOfDocument) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  PopContext(FInput.Position);
  Assert(Assigned(FContext));
  if (FContext^.ContextType = TRESTDWBsonContextType.JavaScriptWithScope) then
  begin
    PopContext(FInput.Position);
    Assert(Assigned(FContext));
  end;

  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.Document:
      State := TRESTDWBsonReaderState.&Type;

    TRESTDWBsonContextType.TopLevel:
      State := TRESTDWBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

function TRESTDWBsonReader.ReadInt32: Integer;
begin
  VerifyBsonType(TRESTDWBsonType.Int32);
  State := GetNextState;
  Result := FInput.ReadInt32;
end;

function TRESTDWBsonReader.ReadInt64: Int64;
begin
  VerifyBsonType(TRESTDWBsonType.Int64);
  State := GetNextState;
  Result := FInput.ReadInt64;
end;

function TRESTDWBsonReader.ReadJavaScript: String;
begin
  VerifyBsonType(TRESTDWBsonType.JavaScript);
  State := GetNextState;
  Result := FInput.ReadString;
end;

function TRESTDWBsonReader.ReadJavaScriptWithScope: String;
var
  StartPosition, Size: Integer;
begin
  VerifyBsonType(TRESTDWBsonType.JavaScriptWithScope);

  StartPosition := FInput.Position;
  Size := ReadSize;

  PushContext(TRESTDWBsonContextType.JavaScriptWithScope, StartPosition, Size);
  Result := FInput.ReadString;

  State := TRESTDWBsonReaderState.ScopeDocument;
end;

procedure TRESTDWBsonReader.ReadMaxKey;
begin
  VerifyBsonType(TRESTDWBsonType.MaxKey);
  State := GetNextState;
end;

procedure TRESTDWBsonReader.ReadMinKey;
begin
  VerifyBsonType(TRESTDWBsonType.MinKey);
  State := GetNextState;
end;

function TRESTDWBsonReader.ReadName: String;
begin
  if (FState = TRESTDWBsonReaderState.&Type) then
    ReadBsonType;

  if (FState <> TRESTDWBsonReaderState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  CurrentName := FInput.ReadCString;
  State := TRESTDWBsonReaderState.Value;

  Assert(Assigned(FContext));
  if (FContext^.ContextType = TRESTDWBsonContextType.Document) then
    FContext^.CurrentElementName := CurrentName;

  Result := CurrentName;
end;

procedure TRESTDWBsonReader.ReadNull;
begin
  VerifyBsonType(TRESTDWBsonType.Null);
  State := GetNextState;
end;

function TRESTDWBsonReader.ReadObjectId: TRESTDWObjectId;
begin
  VerifyBsonType(TRESTDWBsonType.ObjectId);
  State := GetNextState;
  Result := FInput.ReadObjectId;
end;

function TRESTDWBsonReader.ReadRegularExpression: TRESTDWBsonRegularExpression;
var
  Pattern, Options: String;
begin
  VerifyBsonType(TRESTDWBsonType.RegularExpression);
  State := GetNextState;
  Pattern := FInput.ReadCString;
  Options := FInput.ReadCString;
  Result := TRESTDWBsonRegularExpression.Create(Pattern, Options);
end;

function TRESTDWBsonReader.ReadSize: Integer;
begin
  Result := FInput.ReadInt32;
  if (Result < 0) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
end;

procedure TRESTDWBsonReader.ReadStartArray;
var
  StartPosition, Size: Integer;
begin
  VerifyBsonType(TRESTDWBsonType.&Array);
  StartPosition := FInput.Position;
  Size := ReadSize;
  PushContext(TRESTDWBsonContextType.&Array, StartPosition, Size);
  State := TRESTDWBsonReaderState.&Type;
end;

procedure TRESTDWBsonReader.ReadStartDocument;
var
  ContextType: TRESTDWBsonContextType;
  StartPosition, Size: Integer;
begin
  VerifyBsonType(TRESTDWBsonType.Document);

  if (State = TRESTDWBsonReaderState.ScopeDocument) then
    ContextType := TRESTDWBsonContextType.ScopeDocument
  else
    ContextType := TRESTDWBsonContextType.Document;

  StartPosition := FInput.Position;
  Size := ReadSize;

  PushContext(ContextType, StartPosition, Size);
  State := TRESTDWBsonReaderState.&Type;
end;

function TRESTDWBsonReader.ReadString: String;
begin
  VerifyBsonType(TRESTDWBsonType.&String);
  State := GetNextState;
  Result := FInput.ReadString;
end;

function TRESTDWBsonReader.ReadSymbol: String;
begin
  VerifyBsonType(TRESTDWBsonType.Symbol);
  State := GetNextState;
  Result := FInput.ReadString;
end;

function TRESTDWBsonReader.ReadTimestamp: Int64;
begin
  VerifyBsonType(TRESTDWBsonType.Timestamp);
  State := GetNextState;
  Result := FInput.ReadInt64;
end;

procedure TRESTDWBsonReader.ReadUndefined;
begin
  VerifyBsonType(TRESTDWBsonType.Undefined);
  State := GetNextState;
end;

procedure TRESTDWBsonReader.ReturnToBookmark(
  const ABookmark: IgoBsonReaderBookmark);
var
  BM: TBsonBookmark;
begin
  Assert(Assigned(ABookmark));
  Assert(ABookmark is TBsonBookmark);
  BM := TBsonBookmark(ABookmark);
  State := BM.State;
  CurrentBsonType := BM.CurrentBsonType;
  CurrentName := BM.CurrentName;
  FContextIndex := BM.ContextIndex;
  Assert((FContextIndex >= 0) and (FContextIndex < Length(FContextStack)));
  FContext := @FContextStack[FContextIndex];
  FInput.Position := BM.Position;
end;

procedure TRESTDWBsonReader.SkipName;
begin
  if (FState <> TRESTDWBsonReaderState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  FInput.SkipCString;
  FCurrentName := '';
  State := TRESTDWBsonReaderState.Value;

  Assert(Assigned(FContext));
  if (FContext^.ContextType = TRESTDWBsonContextType.Document) then
    FContext^.CurrentElementName := CurrentName;
end;

procedure TRESTDWBsonReader.SkipValue;
var
  Skip: Integer;
begin
  if (FState <> TRESTDWBsonReaderState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  case CurrentBsonType of
    TRESTDWBsonType.&Array: Skip := ReadSize - 4;
    TRESTDWBsonType.Binary: Skip := ReadSize + 1;
    TRESTDWBsonType.Boolean: Skip := 1;
    TRESTDWBsonType.DateTime: Skip := 8;
    TRESTDWBsonType.Document: Skip := ReadSize - 4;
    TRESTDWBsonType.Double: Skip := 8;
    TRESTDWBsonType.Int32: Skip := 4;
    TRESTDWBsonType.Int64: Skip := 8;
    TRESTDWBsonType.JavaScript: Skip := ReadSize;
    TRESTDWBsonType.JavaScriptWithScope: Skip := ReadSize - 4;
    TRESTDWBsonType.ObjectId: Skip := 12;
    TRESTDWBsonType.RegularExpression:
      begin
        FInput.SkipCString;
        FInput.SkipCString;
        Skip := 0;
      end;
    TRESTDWBsonType.&String: Skip := ReadSize;
    TRESTDWBsonType.Symbol: Skip := ReadSize;
    TRESTDWBsonType.Timestamp: Skip := 8;
  else
    Skip := 0;
  end;
  FInput.Skip(Skip);
  State := TRESTDWBsonReaderState.&Type;
end;

{ TRESTDWBsonReader.TInput }

class constructor TRESTDWBsonReader.TInput.Create;
var
  B: Integer;
begin
  FillChar(FValidBsonTypes, SizeOf(FValidBsonTypes), False);
  for B := 0 to $12 do
    FValidBsonTypes[B] := (B <> $0C);
  FValidBsonTypes[$7F] := True;
  FValidBsonTypes[$FF] := True;
end;

procedure TRESTDWBsonReader.TInput.Initialize(const ABuffer: TBytes);
begin
  FBuffer := ABuffer;
  FSize := Length(ABuffer);
  FPosition := 0;
  SetLength(FTempBytes, TEMP_BYTES_LENGTH);
end;

procedure TRESTDWBsonReader.TInput.Read(out AData; const ASize: Integer);
begin
  if ((FPosition + ASize) > FSize) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
  Move(FBuffer[FPosition], AData, ASize);
  Inc(FPosition, ASize);
end;

function TRESTDWBsonReader.TInput.ReadBinarySubType: TRESTDWBsonBinarySubType;
var
  B: Byte absolute Result;
begin
  Read(B, 1);
end;

function TRESTDWBsonReader.TInput.ReadBoolean: Boolean;
var
  B: Byte;
begin
  Read(B, 1);
  Result := (B <> 0);
end;

function TRESTDWBsonReader.TInput.ReadBsonType: TRESTDWBsonType;
var
  B: Byte absolute Result;
begin
  Read(B, 1);
  if (not (FValidBsonTypes[B])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
end;

function TRESTDWBsonReader.TInput.ReadByte: Byte;
begin
  Read(Result, 1);
end;

function TRESTDWBsonReader.TInput.ReadBytes(const ASize: Integer): TBytes;
begin
  Assert(ASize >= 0);
  SetLength(Result, ASize);
  if (Result <> nil) then
    Read(Result[0], ASize);
end;

function TRESTDWBsonReader.TInput.ReadCString: String;
var
  Bytes: TBytes;
  B: Byte;
  Index: Integer;
begin
  Index := 0;
  Bytes := nil;
  while True do
  begin
    B := ReadByte;
    if (B = 0) then
      Break;

    if (Index >= Length(Bytes)) then
      SetLength(Bytes, Index + 32);
    Bytes[Index] := B;
    Inc(Index);
  end;
  Result := TEncoding.UTF8.GetString(Bytes, 0, Index);
end;

function TRESTDWBsonReader.TInput.ReadDouble: Double;
begin
  Read(Result, 8);
end;

function TRESTDWBsonReader.TInput.ReadInt32: Int32;
begin
  Read(Result, 4);
end;

function TRESTDWBsonReader.TInput.ReadInt64: Int64;
begin
  Read(Result, 8);
end;

function TRESTDWBsonReader.TInput.ReadObjectId: TRESTDWObjectId;
var
  Bytes: TBytes;
begin
  SetLength(Bytes, 12);
  Read(Bytes[0], 12);
  Result := TRESTDWObjectId.Create(Bytes);
end;

function TRESTDWBsonReader.TInput.ReadString: String;
var
  Len: Integer;
  Bytes: TBytes;
begin
  Len := ReadInt32;
  if (Len <= 0) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);

  if (Len <= TEMP_BYTES_LENGTH) then
    Bytes := FTempBytes
  else
    SetLength(Bytes, Len);
  Read(Bytes[0], Len);
  if (Bytes[Len - 1] <> 0) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
  Result := TEncoding.UTF8.GetString(Bytes, 0, Len - 1);
end;

procedure TRESTDWBsonReader.TInput.Skip(const ANumBytes: Integer);
begin
  if ((FPosition + ANumBytes) > FSize) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
  Inc(FPosition, ANumBytes);
end;

procedure TRESTDWBsonReader.TInput.SkipCString;
begin
  while (ReadByte <> 0) do ;
end;

{ TRESTDWBsonReader.TContext }

procedure TRESTDWBsonReader.TContext.Initialize(
  const AContextType: TRESTDWBsonContextType; const AStartPosition, ASize: Integer);
begin
  FStartPosition := AStartPosition;
  FSize := ASize;
  FCurrentArrayIndex := -1;
  FCurrentElementName := '';
  FContextType := AContextType;
end;

{ TRESTDWBsonReader.TBsonBookmark }

constructor TRESTDWBsonReader.TBsonBookmark.Create(const AState: TRESTDWBsonReaderState;
  const ACurrentBsonType: TRESTDWBsonType; const ACurrentName: String;
  const AContextIndex, APosition: Integer);
begin
  inherited Create(AState, ACurrentBsonType, ACurrentName);
  FContextIndex := AContextIndex;
  FPosition := APosition;
end;

{ TRESTDWJsonReader }

constructor TRESTDWJsonReader.Create(const AJson: String; bAllowDuplicateNames : Boolean = false);
begin
  inherited Create;
  FAllowDuplicateNames := bAllowDuplicateNames;
  FBuffer := TBuffer.Create(AJson);
  FTokenBase := TToken.Create;
  FTokenToPush := TToken.Create;
  PushContext(TRESTDWBsonContextType.TopLevel);
end;

class constructor TRESTDWJsonReader.Create;
begin
  TScanner.Initialize;
end;

destructor TRESTDWJsonReader.Destroy;
begin
  FTokenBase.Free;
  FTokenToPush.Free;
  inherited;
end;

function TRESTDWJsonReader.EndOfStream: Boolean;
var
  C: Char;
begin
  while True do
  begin
    C := FBuffer.Read;
    if (C = #0) then
      Exit(True);

    if (not TScanner.IsWhitespace(C)) then
    begin
      FBuffer.Unread(C);
      Exit(False);
    end;
  end;
end;

class function TRESTDWJsonReader.FormatJavaScriptDateTimeString(
  const ALocalDateTime: TDateTime): String;
var
  Utc, Offset: TDateTime;
  OffsetSign: String;
  H, M, S, MSec: Word;
begin
  {$IFNDEF FPC}
   Utc := TTimeZone.Local.ToUniversalTime(ALocalDateTime);
  {$ELSE}
   Utc := LocalTimeToUniversal(ALocalDateTime);
  {$ENDIF}
  Offset := ALocalDateTime - Utc;
  if (Offset < 0) then
  begin
    Offset := -Offset;
    OffsetSign := '-';
  end
  else
    OffsetSign := '+';
  DecodeTime(Offset, H, M, S, MSec);
  Result := FormatDateTime('ddd mmm dd yyyy hh:nn:ss', ALocalDateTime, goUSFormatSettings)
    + {$IFNDEF FPC}Format('GMT%s%.2d%.2d (%s)', [OffsetSign, H, M, TTimeZone.Local.DisplayName{$ELSE}Format('GMT%s%.2d%.2d', [OffsetSign, H, M{$ENDIF}]);
end;

function TRESTDWJsonReader.GetBookmark: IgoBsonReaderBookmark;
begin
  Result := TJsonBookmark.Create(State, CurrentBsonType, CurrentName,
    FContextIndex, FCurrentToken, FCurrentValue, FPushedToken,
    FBuffer.FCurrent);
end;

function TRESTDWJsonReader.GetNextState: TRESTDWBsonReaderState;
begin
  Assert(Assigned(FContext));
  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.Document:
      Result := TRESTDWBsonReaderState.&Type;

    TRESTDWBsonContextType.TopLevel:
      Result := TRESTDWBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

class function TRESTDWJsonReader.Load(const AFilename: String; bAllowDuplicateNames : Boolean = false): IgoJsonReader;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
  try
    Result := Load(Stream, bAllowDuplicateNames);
  finally
    Stream.Free;
  end;
end;

class function TRESTDWJsonReader.Load(const AStream: TStream; bAllowDuplicateNames : Boolean = false): IgoJsonReader;
var
  Reader: TStreamReader;
  Json: String;
  {$IFDEF FPC}
  Function ReadToEnd(aReader : TStreamReader) : String;
  Begin
   Result := '';
   While Not aReader.Eof Do
    Result := Result + aReader.ReadLine;
  End;
  {$ENDIF}
begin
  Reader := TStreamReader.Create(AStream{$IFNDEF FPC}, True{$ENDIF});
  try
    Json := {$IFNDEF FPC}Reader.ReadToEnd{$ELSE}ReadToEnd(Reader){$ENDIF};
  finally
    Reader.Free;
  end;
  Result := TRESTDWJsonReader.Create(Json, bAllowDuplicateNames);
end;

procedure TRESTDWJsonReader.ParseConstructorBinaryData;
{ BinData(0, "AQ==") }
var
  Token: TToken;
  Base64: TBytes;
begin
  VerifyToken('(');

  PopToken(Token);
  if (Token.TokenType <> TTokenType.Int32) then
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);
  FCurrentValue.BinarySubType := TRESTDWBsonBinarySubType(Token.Int32Value);

  VerifyToken(',');

  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  Base64 := TEncoding.ANSI.GetBytes(Token.StringValue);

  VerifyToken(')');

  FCurrentValue.Bytes := goBase64Decode(Base64);
end;

procedure TRESTDWJsonReader.ParseConstructorDateTime(
  const AWithNew: Boolean);
{ Date()
  new Date()
  new Date(9223372036854775807)
  new Date(1970, 3, 30, 11, 59, 23, 123)
  new Date("...") }
var
  Token: TToken;
  DateTime: TDateTime;
  Args: array [0..6] of Int64;
  ArgCount: Integer;
begin
  VerifyToken('(');

  if (not AWithNew) then
  begin
    VerifyToken(')');
    FCurrentValue.StrVal := FormatJavaScriptDateTimeString(Now);
    Exit;
  end;

  PopToken(Token);
  if (Token.LexemeLength = 1) and (Token.LexemeStart^ = ')') then
  begin
    FCurrentValue.Int64Val := goDateTimeToMillisecondsSinceEpoch(Now, False);
    Exit;
  end;

  if (Token.TokenType = TTokenType.&String) then
  begin
    VerifyToken(')');
    raise FBuffer.ParseError(@RS_BSON_JS_DATETIME_STRING_NOT_SUPPORTED);
  end;

  if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
  begin
    ArgCount := 0;
    FillChar(Args, SizeOf(Args), 0);
    while True do
    begin
      if (ArgCount > 6) then
        raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);
      Args[ArgCount] := Token.Int64Value;
      Inc(ArgCount);

      PopToken(Token);
      if (Token.LexemeLength = 1) and (Token.LexemeStart^ = ')') then
        Break;

      if (Token.LexemeLength <> 1) or (Token.LexemeStart^ <> ',') then
        raise FBuffer.ParseError(@RS_BSON_COMMA_EXPECTED);

      PopToken(Token);
      if (not (Token.TokenType in [TTokenType.Int32, TTokenType.Int64])) then
        raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);
    end;

    case ArgCount of
      1: FCurrentValue.Int64Val := Args[0];
      3..7:
        begin
          DateTime := EncodeDateTime(
            Args[0], Args[1] + 1, Args[2],
            Args[3], Args[3], Args[5], Args[6]);
          FCurrentValue.Int64Val := goDateTimeToMillisecondsSinceEpoch(DateTime, True);
        end
    else
      raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);
    end;
    Exit;
  end;

  raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);
end;

procedure TRESTDWJsonReader.ParseConstructorHexData;
{ HexData(0, "123") }
var
  Token: TToken;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.Int32) then
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);
  FCurrentValue.BinarySubType := TRESTDWBsonBinarySubType(Token.Int32Value);

  VerifyToken(',');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken(')');

  FCurrentValue.Bytes := goParseHexString(Token.StringValue);
end;

procedure TRESTDWJsonReader.ParseConstructorISODateTime;
{ ISODate("1970-01-01T00:00:00Z")
  ISODate("1970-01-01T00:00:00.000Z") }
var
  Token: TToken;
  DateTime: TDateTime;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);

  VerifyToken(')');

  { Note: The C# drivers supports a whole range of date/time formats.
    We only support the official ISO8601 format }
  if (not TryISO8601ToDate(Token.StringValue, DateTime, True)) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);

  FCurrentValue.Int64Val := goDateTimeToMillisecondsSinceEpoch(DateTime, True);
end;

procedure TRESTDWJsonReader.ParseConstructorNumber;
{ Number(42)
  Number("42")
  NumberInt(42)
  NumberInt("42") }
var
  Token: TToken;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    FCurrentValue.Int32Val := Token.Int32Value
  else if (Token.TokenType = TTokenType.&String) then
    FCurrentValue.Int32Val := StrToInt(Token.StringValue)
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);
  VerifyToken(')');
end;

procedure TRESTDWJsonReader.ParseConstructorNumberLong;
{ NumberLong(42)
  NumberLong("42") }
var
  Token: TToken;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    FCurrentValue.Int64Val := Token.Int64Value
  else if (Token.TokenType = TTokenType.&String) then
    FCurrentValue.Int64Val := StrToInt64(Token.StringValue)
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);
  VerifyToken(')');
end;

procedure TRESTDWJsonReader.ParseConstructorObjectId;
// ObjectId("0102030405060708090a0b0c")
var
  Token: TToken;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken(')');
  FCurrentValue.ObjectIdVal := TRESTDWObjectId.Create(Token.StringValue);
end;

procedure TRESTDWJsonReader.ParseConstructorRegularExpression;
{ RegExp("pattern")
  RegExp("pattern", "options") }
var
  Token: TToken;
  Pattern, Options: String;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  Pattern := Token.StringValue;
  Options := '';

  PopToken(Token);
  if (Token.LexemeLength = 1) and (Token.LexemeStart^ = ',') then
  begin
    PopToken(Token);
    if (Token.TokenType <> TTokenType.&String) then
      raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
    Options := Token.StringValue;
  end
  else
    PushToken(Token);

  VerifyToken(')');
  FCurrentValue.StrVal := Pattern + #1 + Options;
end;

procedure TRESTDWJsonReader.ParseConstructorTimestamp;
{ Timestamp(1, 2) }
var
  Token: TToken;
  SecondsSinceEpoch, Increment: Integer;
begin
  VerifyToken('(');

  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    SecondsSinceEpoch := Token.Int32Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);

  VerifyToken(',');

  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    Increment := Token.Int32Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);

  VerifyToken(')');
  FCurrentValue.Int64Val := (UInt64(SecondsSinceEpoch) shl 32) or UInt32(Increment);
end;

procedure TRESTDWJsonReader.ParseConstructorUUID(const ALexemeStart: Char);
var
  Token: TToken;
  HexString: String;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken(')');

  HexString := Token.StringValue.Replace('{', '').Replace('}', '');
  HexString := HexString.Replace('-', '', [rfReplaceAll]);
  FCurrentValue.Bytes := goParseHexString(HexString);
  if (Length(FCurrentValue.Bytes) <> 16) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_GUID);
  FCurrentValue.BinarySubType := TRESTDWBsonBinarySubType.UuidLegacy;

  if (ALexemeStart = 'C') then // C#
  begin
    // No conversion needed
    goReverseBytes(FCurrentValue.Bytes, 0, 4);
    goReverseBytes(FCurrentValue.Bytes, 4, 2);
    goReverseBytes(FCurrentValue.Bytes, 6, 2);
  end
  else
  begin
    if (ALexemeStart = 'J') then // Java
    begin
      goReverseBytes(FCurrentValue.Bytes, 0, 8);
      goReverseBytes(FCurrentValue.Bytes, 8, 8);
    end
    else if (ALexemeStart <> 'P') then // Python
      FCurrentValue.BinarySubType := TRESTDWBsonBinarySubType.UuidStandard;
  end;
end;

function TRESTDWJsonReader.ParseDocumentOrExtendedJson: TRESTDWBsonType;
var
  NameToken: TToken;
begin
  PopToken(NameToken);
  if (NameToken.TokenType in [TTokenType.&String, TTokenType.UnquotedString])
    and (NameToken.StringValue <> '')
  then
    Result := ParseExtendedJson(NameToken)
  else
  begin
    PushToken(NameToken);
    Result := TRESTDWBsonType.Document;
  end;
end;

function TRESTDWJsonReader.ParseExtendedJson(const ANameToken: TToken): TRESTDWBsonType;
var
  S: String;
begin
  S := ANameToken.StringValue;
  Assert(S <> '');
  if (S.Chars[0] = '$') and (S.Length > 1) then
  begin
    case S.Chars[1] of
      'b': if (S = '$binary') then
           begin
             ParseExtendedJsonBinaryData;
             Exit(TRESTDWBsonType.Binary);
           end;
      'c': if (S = '$code') then
             Exit(ParseExtendedJsonJavaScript);
      'd': if (S = '$date') then
           begin
             FCurrentValue.Int64Val := ParseExtendedJsonDateTime;
             Exit(TRESTDWBsonType.DateTime);
           end;
      'm': if (S = '$maxkey') or (S = '$maxKey') then
           begin
             ParseExtendedJsonMaxKey;
             Exit(TRESTDWBsonType.MaxKey);
           end
           else if (S = '$minkey') or (S = '$minKey') then
           begin
             ParseExtendedJsonMinKey;
             Exit(TRESTDWBsonType.MinKey);
           end;
      'n': if (S = '$numberLong') then
           begin
             FCurrentValue.Int64Val := ParseExtendedJsonNumberLong;
             Exit(TRESTDWBsonType.Int64);
           end;
      'o': if (S = '$oid') then
           begin
             FCurrentValue.ObjectIdVal := ParseExtendedJsonObjectId;
             Exit(TRESTDWBsonType.ObjectId);
           end;
      'r': if (S = '$regex') then
           begin
             ParseExtendedJsonRegularExpression;
             Exit(TRESTDWBsonType.RegularExpression);
           end;
      's': if (S = '$symbol') then
           begin
             ParseExtendedJsonSymbol;
             Exit(TRESTDWBsonType.Symbol);
           end;
      't': if (S = '$timestamp') then
           begin
             FCurrentValue.Int64Val := ParseExtendedJsonTimestamp;
             Exit(TRESTDWBsonType.Timestamp);
           end;
      'u': if (S = '$undefined') then
           begin
             ParseExtendedJsonUndefined;
             Exit(TRESTDWBsonType.Undefined);
           end;
    end;
  end;
  PushToken(ANameToken);
  Result := TRESTDWBsonType.Document;
end;

procedure TRESTDWJsonReader.ParseExtendedJsonBinaryData;
(* { $binary : "AQ==", $type : 0 }
   { $binary : "AQ==", $type : "0" }
   { $binary : "AQ==", $type : "00" } *)
var
  Token: TToken;
  Base64: TBytes;
begin
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);

  Base64 := TEncoding.ANSI.GetBytes(Token.StringValue);
  FCurrentValue.Bytes := goBase64Decode(Base64);

  VerifyToken(',');
  VerifyString('$type');
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType = TTokenType.&String) then
    FCurrentValue.BinarySubType := TRESTDWBsonBinarySubType(StrToInt('$' + Token.StringValue))
  else if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    FCurrentValue.BinarySubType := TRESTDWBsonBinarySubType(Token.Int32Value)
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);

  VerifyToken('}');
end;

function TRESTDWJsonReader.ParseExtendedJsonDateTime: Int64;
(* { $date : -9223372036854775808 }
   { $date : { $numberLong : 9223372036854775807 } }
   { $date : { $numberLong : "-9223372036854775808" } }
   { $date : "1970-01-01T00:00:00Z" }
   { $date : "1970-01-01T00:00:00.000Z" } *)
var
  Token: TToken;
  DateTime: TDateTime;
begin
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    Result := Token.Int64Value
  else if (Token.TokenType = TTokenType.&String) then
  begin
    if (not TryISO8601ToDate(Token.StringValue, DateTime, True)) then
      raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);
    Result := goDateTimeToMillisecondsSinceEpoch(DateTime, True);
  end
  else if (Token.TokenType = TTokenType.BeginObject) then
  begin
    VerifyString('$numberLong');
    VerifyToken(':');
    PopToken(Token);
    if (Token.TokenType = TTokenType.&String) then
    begin
      if (not TryStrToInt64(Token.StringValue, Result)) then
        raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);
    end
    else if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
      Result := Token.Int64Value
    else
      raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);
    VerifyToken('}');
  end
  else
    raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);

  VerifyToken('}');
end;

function TRESTDWJsonReader.ParseExtendedJsonJavaScript: TRESTDWBsonType;
(* { "$code" : "function f() { return 1; }" }
   { "$code" : "function f() { return 1; }" , "$scope" : {...} } *)
var
  Token: TToken;
  Code: String;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  Code := Token.StringValue;

  PopToken(Token);
  case Token.TokenType of
    TTokenType.Comma:
      begin
        VerifyString('$scope');
        VerifyToken(':');
        State := TRESTDWBsonReaderState.Value;
        FCurrentValue.StrVal := Code;
        Result := TRESTDWBsonType.JavaScriptWithScope;
      end;

    TTokenType.EndObject:
      begin
        FCurrentValue.StrVal := Code;
        Result := TRESTDWBsonType.JavaScript;
      end;
  else
    raise FBuffer.ParseError(@RS_BSON_COMMA_OR_CLOSE_BRACE_EXPECTED);
  end;
end;

procedure TRESTDWJsonReader.ParseExtendedJsonMaxKey;
(* { $maxKey : 1 }
   { $maxkey : 1 } *)
begin
  VerifyToken(':');
  VerifyToken('1');
  VerifyToken('}');
end;

procedure TRESTDWJsonReader.ParseExtendedJsonMinKey;
(* { $minKey : 1 }
   { $minkey : 1 } *)
begin
  VerifyToken(':');
  VerifyToken('1');
  VerifyToken('}');
end;

function TRESTDWJsonReader.ParseExtendedJsonNumberLong: Int64;
(* { $numberLong: 42 }
   { $numberLong: "42" } *)
var
  Token: TToken;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType = TTokenType.&String) then
    Result := StrToInt64(Token.StringValue)
  else if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    Result := Token.Int64Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);
  VerifyToken('}');
end;

function TRESTDWJsonReader.ParseExtendedJsonObjectId: TRESTDWObjectId;
// { $oid : "0102030405060708090a0b0c" }
var
  Token: TToken;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken('}');
  Result := TRESTDWObjectId.Create(Token.StringValue);
end;

procedure TRESTDWJsonReader.ParseExtendedJsonRegularExpression;
(* { $regex : "abc" }
   { $regex : "abc", $options : "i" } *)
var
  Token: TToken;
  Pattern, Options: String;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  Pattern := Token.StringValue;
  Options := '';

  PopToken(Token);
  if (Token.TokenType = TTokenType.Comma) then
  begin
    VerifyString('$options');
    VerifyToken(':');
    PopToken(Token);
    if (Token.TokenType <> TTokenType.&String) then
      raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
    Options := Token.StringValue;
  end
  else
    PushToken(Token);

  VerifyToken('}');
  FCurrentValue.StrVal := Pattern + #1 + Options;
end;

procedure TRESTDWJsonReader.ParseExtendedJsonSymbol;
(* { "$symbol" : "symbol" } *)
var
  Token: TToken;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.&String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken('}');
  FCurrentValue.StrVal := Token.StringValue; // Will be converted to a TRESTDWBsonSymbol later
end;

function TRESTDWJsonReader.ParseExtendedJsonTimestamp: Int64;
(* { $timestamp : { t : 1, i : 2 } } // New
   { $timestamp : 123 }              // Old
   { $timestamp : NumberLong(123) }  // Old *)
var
  Token: TToken;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType = TTokenType.BeginObject) then
    Result := ParseExtendedJsonTimestampNew
  else
    Result := ParseExtendedJsonTimestampOld(Token);
end;

function TRESTDWJsonReader.ParseExtendedJsonTimestampNew: Int64;
(* { $timestamp : { t : 1, i : 2 } } *)
var
  Token: TToken;
  SecondsSinceEpoch, Increment: Integer;
begin
  VerifyString('t');
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    SecondsSinceEpoch := Token.Int32Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);

  VerifyToken(',');
  VerifyString('i');
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    Increment := Token.Int32Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);

  VerifyToken('}');
  VerifyToken('}');
  Result := (UInt64(SecondsSinceEpoch) shl 32) or UInt32(Increment);
end;

function TRESTDWJsonReader.ParseExtendedJsonTimestampOld(
  const AValueToken: TToken): Int64;
(* { $timestamp : 123 }
   { $timestamp : NumberLong(123) } *)
begin

  if (AValueToken.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    Result := AValueToken.Int64Value
  else if (AValueToken.TokenType = TTokenType.UnquotedString)
    and (AValueToken.IsLexeme('NumberLong', 10)) then
  begin
    ParseConstructorNumberLong;
    Result := FCurrentValue.Int64Val;
  end
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);

  VerifyToken('}');
end;

procedure TRESTDWJsonReader.ParseExtendedJsonUndefined;
(* { $undefined : true } *)
begin
  VerifyToken(':');
  VerifyToken('true', 4);
  VerifyToken('}');
end;

function TRESTDWJsonReader.ParseNew: TRESTDWBsonType;
var
  Token: TToken;
begin
  PopToken(Token);
  if (Token.TokenType <> TTokenType.UnquotedString) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);

  Assert(Token.LexemeLength > 0);
  case Token.LexemeStart^ of
    'B': if (Token.IsLexeme('BinData', 7)) then
         begin
           ParseConstructorBinaryData;
           Exit(TRESTDWBsonType.Binary);
         end;

    'C': if (Token.IsLexeme('CSUUID', 6)) or (Token.IsLexeme('CSGUID', 6)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TRESTDWBsonType.DateTime);
         end;

    'D': if (Token.IsLexeme('Date', 4)) then
         begin
           ParseConstructorDateTime(True);
           Exit(TRESTDWBsonType.DateTime);
         end;

    'G': if (Token.IsLexeme('GUID', 4)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TRESTDWBsonType.DateTime);
         end;

    'H': if (Token.IsLexeme('HexData', 7)) then
         begin
           ParseConstructorHexData;
           Exit(TRESTDWBsonType.Binary);
         end;

    'I': if (Token.IsLexeme('ISODate', 7)) then
         begin
           ParseConstructorISODateTime;
           Exit(TRESTDWBsonType.DateTime);
         end;

    'J': if (Token.IsLexeme('JUUID', 5)) or (Token.IsLexeme('JGUID', 5)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TRESTDWBsonType.DateTime);
         end;

    'N': if (Token.IsLexeme('NumberInt', 9)) then
         begin
           ParseConstructorNumber;
           Exit(TRESTDWBsonType.Int32);
         end
         else if (Token.IsLexeme('NumberLong', 10)) then
         begin
           ParseConstructorNumberLong;
           Exit(TRESTDWBsonType.Int64);
         end;

    'O': if (Token.IsLexeme('ObjectId', 8)) then
         begin
           ParseConstructorObjectId;
           Exit(TRESTDWBsonType.ObjectId);
         end;

    'P': if (Token.IsLexeme('PYUUID', 6)) or (Token.IsLexeme('PYGUID', 6)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TRESTDWBsonType.DateTime);
         end;

    'T': if (Token.IsLexeme('Timestamp', 9)) then
         begin
           ParseConstructorTimestamp;
           Exit(TRESTDWBsonType.Timestamp);
         end;

    'U': if (Token.IsLexeme('UUID', 4)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TRESTDWBsonType.DateTime);
         end;
  end;

  raise FBuffer.ParseError(@RS_BSON_INVALID_NEW_STATEMENT);
end;

procedure TRESTDWJsonReader.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWJsonReader.PopToken(out AToken: TToken);
begin
  if (FPushedToken <> nil) then
  begin
    Assert(FPushedToken = FTokenToPush);
    AToken := FPushedToken;
    FPushedToken := nil;
  end
  else
  begin
    AToken := FTokenBase;
    TScanner.GetNextToken(FBuffer, AToken);
  end;
end;

procedure TRESTDWJsonReader.PushContext(const AContextType: TRESTDWBsonContextType);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType);
  FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWJsonReader.PushToken(const AToken: TToken);
begin
  if (FPushedToken <> nil) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  FTokenToPush.Assign(AToken);
  FPushedToken := FTokenToPush;
end;

function TRESTDWJsonReader.ReadBinaryData: TRESTDWBsonBinaryData;
begin
  VerifyBsonType(TRESTDWBsonType.Binary);
  State := GetNextState;
  Result := TRESTDWBsonBinaryData.Create(FCurrentValue.Bytes, FCurrentValue.BinarySubType);
end;

function TRESTDWJsonReader.ReadBoolean: Boolean;
begin
  VerifyBsonType(TRESTDWBsonType.Boolean);
  State := GetNextState;
  Result := FCurrentValue.BoolVal;
end;

function TRESTDWJsonReader.ReadBsonType: TRESTDWBsonType;
var
  Token: TToken;
  NoValueFound: Boolean;
begin
  Assert(Assigned(FContext));

  if (State in [TRESTDWBsonReaderState.Initial, TRESTDWBsonReaderState.ScopeDocument]) then
    State := TRESTDWBsonReaderState.&Type;

  if (State <> TRESTDWBsonReaderState.&Type) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (FContext^.ContextType = TRESTDWBsonContextType.Document) then
  begin
    PopToken(Token); // Name
    case Token.TokenType of
      TTokenType.&String,
      TTokenType.UnquotedString:
        CurrentName := Token.StringValue;

      TTokenType.EndObject:
        begin
          State := TRESTDWBsonReaderState.EndOfDocument;
          Exit(TRESTDWBsonType.EndOfDocument);
        end;
    else
      raise FBuffer.ParseError(@RS_BSON_STRING_OR_CLOSE_BRACE_EXPECTED);
    end;

    PopToken(Token); // Colon
    if (Token.TokenType <> TTokenType.Colon) then
      raise FBuffer.ParseError(@RS_BSON_COLON_EXPECTED);
  end;

  PopToken(Token); // Value
  if (FContext^.ContextType = TRESTDWBsonContextType.&Array)
    and (Token.TokenType = TTokenType.EndArray) then
  begin
    State := TRESTDWBsonReaderState.EndOfArray;
    Exit(TRESTDWBsonType.EndOfDocument);
  end;

  NoValueFound := False;
  case Token.TokenType of
    TTokenType.BeginArray:
      CurrentBsonType := TRESTDWBsonType.&Array;

    TTokenType.BeginObject:
      CurrentBsonType := ParseDocumentOrExtendedJson;

    TTokenType.Double:
      begin
        CurrentBsonType := TRESTDWBsonType.Double;
        FCurrentValue.DoubleVal := Token.DoubleValue;
      end;

    TTokenType.EndOfFile:
      CurrentBsonType := TRESTDWBsonType.EndOfDocument;

    TTokenType.Int32:
      begin
        CurrentBsonType := TRESTDWBsonType.Int32;
        FCurrentValue.Int32Val := Token.Int32Value;
      end;

    TTokenType.Int64:
      begin
        CurrentBsonType := TRESTDWBsonType.Int64;
        FCurrentValue.Int64Val := Token.Int64Value;
      end;

    TTokenType.RegularExpression:
      begin
        CurrentBsonType := TRESTDWBsonType.RegularExpression;
        SetCurrentValueRegEx(Token);
      end;

    TTokenType.&String:
      begin
        CurrentBsonType := TRESTDWBsonType.&String;
        FCurrentValue.StrVal := Token.StringValue;
      end;

    TTokenType.UnquotedString:
      begin
        Assert(Token.LexemeLength > 0);
        case Token.LexemeStart^ of
          'B': if (Token.IsLexeme('BinData', 7)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Binary;
                 ParseConstructorBinaryData;
               end
               else
                 NoValueFound := True;

          'C': if (Token.IsLexeme('CSUUID', 6)) or (Token.IsLexeme('CSGUID', 6)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'D': if (Token.IsLexeme('Date', 4)) then
               begin
                 { This is the Date() function (without arguments).
                   It should return the current datetime (in UTC) as a
                   JavaScript formatted datetime string. }
                 CurrentBsonType := TRESTDWBsonType.&String;
                 ParseConstructorDateTime(False);
               end
               else
                 NoValueFound := True;

          'G': if (Token.IsLexeme('GUID', 4)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'H': if (Token.IsLexeme('HexData', 7)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Binary;
                 ParseConstructorHexData;
               end
               else
                 NoValueFound := True;

          'I': if (Token.IsLexeme('Infinity', 8)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Double;
                 FCurrentValue.DoubleVal := Infinity;
               end
               else if (Token.IsLexeme('ISODate', 7)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.DateTime;
                 ParseConstructorISODateTime;
               end
               else
                 NoValueFound := True;

          'J': if (Token.IsLexeme('JUUID', 5)) or (Token.IsLexeme('JGUID', 5)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'M': if (Token.IsLexeme('MaxKey', 6)) then
                 CurrentBsonType := TRESTDWBsonType.MaxKey
               else if (Token.IsLexeme('MinKey', 6)) then
                 CurrentBsonType := TRESTDWBsonType.MinKey
               else
                 NoValueFound := True;

          'N': if (Token.IsLexeme('NaN', 3)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Double;
                 FCurrentValue.DoubleVal := NaN;
               end
               else if (Token.IsLexeme('Number', 6)) or (Token.IsLexeme('NumberInt', 9)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Int32;
                 ParseConstructorNumber;
               end
               else if (Token.IsLexeme('NumberLong', 10)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Int64;
                 ParseConstructorNumberLong;
               end
               else
                 NoValueFound := True;

          'O': if (Token.IsLexeme('ObjectId', 8)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.ObjectId;
                 ParseConstructorObjectId;
               end
               else
                 NoValueFound := True;

          'P': if (Token.IsLexeme('PYUUID', 6)) or (Token.IsLexeme('PYGUID', 6)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'R': if (Token.IsLexeme('RegExp', 6)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.RegularExpression;
                 ParseConstructorRegularExpression;
               end
               else
                 NoValueFound := True;

          'T': if (Token.IsLexeme('Timestamp', 9)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Timestamp;
                 ParseConstructorTimestamp;
               end
               else
                 NoValueFound := True;

          'U': if (Token.IsLexeme('UUID', 4)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'f': if (Token.IsLexeme('false', 5)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Boolean;
                 FCurrentValue.BoolVal := False;
               end
               else
                 NoValueFound := True;

          'n': if (Token.IsLexeme('new', 3)) then
                 CurrentBsonType := ParseNew
               else if (Token.IsLexeme('null', 4)) then
                 CurrentBsonType := TRESTDWBsonType.Null
               else
                 NoValueFound := True;

          't': if (Token.IsLexeme('true', 4)) then
               begin
                 CurrentBsonType := TRESTDWBsonType.Boolean;
                 FCurrentValue.BoolVal := True;
               end
               else
                 NoValueFound := True;

          'u': if (Token.IsLexeme('undefined', 9)) then
                 CurrentBsonType := TRESTDWBsonType.Undefined
               else
                 NoValueFound := True;
        else
          NoValueFound := True;
        end;
      end;
  else
    NoValueFound := True;
  end;

  if (NoValueFound) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_EXTENDED_JSON);

  FCurrentToken := Token;

  if (FContext^.ContextType in [TRESTDWBsonContextType.&Array, TRESTDWBsonContextType.Document]) then
  begin
    PopToken(Token); // Comma
    if (Token.TokenType <> TTokenType.Comma) then
      PushToken(Token);
  end;

  case FContext^.ContextType of
    TRESTDWBsonContextType.Document,
    TRESTDWBsonContextType.ScopeDocument:
      State := TRESTDWBsonReaderState.Name;

    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.JavaScriptWithScope,
    TRESTDWBsonContextType.TopLevel:
      State := TRESTDWBsonReaderState.Value;
  end;

  Result := CurrentBsonType;
end;

function TRESTDWJsonReader.ReadBytes: TBytes;
begin
  VerifyBsonType(TRESTDWBsonType.Binary);
  State := GetNextState;

  if (not (FCurrentValue.BinarySubType in [TRESTDWBsonBinarySubType.Binary, TRESTDWBsonBinarySubType.OldBinary])) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_BINARY_TYPE);

  Result := FCurrentValue.Bytes;
end;

function TRESTDWJsonReader.ReadDateTime: Int64;
begin
  VerifyBsonType(TRESTDWBsonType.DateTime);
  State := GetNextState;
  Result := FCurrentValue.Int64Val;
end;

function TRESTDWJsonReader.ReadDouble: Double;
begin
  VerifyBsonType(TRESTDWBsonType.Double);
  State := GetNextState;
  Result := FCurrentValue.DoubleVal;
end;

procedure TRESTDWJsonReader.ReadEndArray;
var
  CommaToken: TToken;
begin
  Assert(Assigned(FContext));
  if (FContext^.ContextType <> TRESTDWBsonContextType.&Array) then
    raise FBuffer.ParseError(@RS_BSON_CLOSE_BRACKET_EXPECTED);

  if (State = TRESTDWBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TRESTDWBsonReaderState.EndOfArray) then
    raise FBuffer.ParseError(@RS_BSON_CLOSE_BRACKET_EXPECTED);

  PopContext;
  if (FContext = nil) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.Document:
      begin
        State := TRESTDWBsonReaderState.&Type;
        PopToken(CommaToken);
        if (CommaToken.TokenType <> TTokenType.Comma) then
          PushToken(CommaToken);
      end;

    TRESTDWBsonContextType.TopLevel:
      State := TRESTDWBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TRESTDWJsonReader.ReadEndDocument;
var
  CommaToken: TToken;
begin
  Assert(Assigned(FContext));
  if (not (FContext^.ContextType in [TRESTDWBsonContextType.Document, TRESTDWBsonContextType.ScopeDocument])) then
    raise FBuffer.ParseError(@RS_BSON_CLOSE_BRACE_EXPECTED);

  if (State = TRESTDWBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TRESTDWBsonReaderState.EndOfDocument) then
    raise FBuffer.ParseError(@RS_BSON_CLOSE_BRACE_EXPECTED);

  PopContext;
  if (FContext = nil) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (FContext^.ContextType = TRESTDWBsonContextType.JavaScriptWithScope) then
  begin
    PopContext;
    if (FContext = nil) then
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
    VerifyToken('}');
  end;

  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.Document:
      begin
        State := TRESTDWBsonReaderState.&Type;
        PopToken(CommaToken);
        if (CommaToken.TokenType <> TTokenType.Comma) then
          PushToken(CommaToken);
      end;

    TRESTDWBsonContextType.TopLevel:
      State := TRESTDWBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

function TRESTDWJsonReader.ReadInt32: Integer;
begin
  VerifyBsonType(TRESTDWBsonType.Int32);
  State := GetNextState;
  Result := FCurrentValue.Int32Val;
end;

function TRESTDWJsonReader.ReadInt64: Int64;
begin
  VerifyBsonType(TRESTDWBsonType.Int64);
  State := GetNextState;
  Result := FCurrentValue.Int64Val;
end;

function TRESTDWJsonReader.ReadJavaScript: String;
begin
  VerifyBsonType(TRESTDWBsonType.JavaScript);
  State := GetNextState;
  Result := FCurrentValue.StrVal;
end;

function TRESTDWJsonReader.ReadJavaScriptWithScope: String;
begin
  VerifyBsonType(TRESTDWBsonType.JavaScriptWithScope);
  PushContext(TRESTDWBsonContextType.JavaScriptWithScope);
  State := TRESTDWBsonReaderState.ScopeDocument;
  Result := FCurrentValue.StrVal;
end;

procedure TRESTDWJsonReader.ReadMaxKey;
begin
  VerifyBsonType(TRESTDWBsonType.MaxKey);
  State := GetNextState;
end;

procedure TRESTDWJsonReader.ReadMinKey;
begin
  VerifyBsonType(TRESTDWBsonType.MinKey);
  State := GetNextState;
end;

function TRESTDWJsonReader.ReadName: String;
begin
  if (State = TRESTDWBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TRESTDWBsonReaderState.Name) then
    raise FBuffer.ParseError(@RS_BSON_QUOTE_EXPECTED);

  State := TRESTDWBsonReaderState.Value;
  Result := CurrentName;
end;

procedure TRESTDWJsonReader.ReadNull;
begin
  VerifyBsonType(TRESTDWBsonType.Null);
  State := GetNextState;
end;

function TRESTDWJsonReader.ReadObjectId: TRESTDWObjectId;
begin
  VerifyBsonType(TRESTDWBsonType.ObjectId);
  State := GetNextState;
  Result := FCurrentValue.ObjectIdVal;
end;

function TRESTDWJsonReader.ReadRegularExpression: TRESTDWBsonRegularExpression;
var
  I: Integer;
begin
  VerifyBsonType(TRESTDWBsonType.RegularExpression);
  State := GetNextState;
  I := FCurrentValue.StrVal.IndexOf(#1);
  if (I < 0) then
    Result := TRESTDWBsonRegularExpression.Create(FCurrentValue.StrVal)
  else
    Result := TRESTDWBsonRegularExpression.Create(FCurrentValue.StrVal.Substring(0, I),
      FCurrentValue.StrVal.Substring(I + 1));
end;

procedure TRESTDWJsonReader.ReadStartArray;
begin
  VerifyBsonType(TRESTDWBsonType.&Array);
  PushContext(TRESTDWBsonContextType.&Array);
  State := TRESTDWBsonReaderState.&Type;
end;

procedure TRESTDWJsonReader.ReadStartDocument;
begin
  VerifyBsonType(TRESTDWBsonType.Document);
  PushContext(TRESTDWBsonContextType.Document);
  State := TRESTDWBsonReaderState.&Type;
end;

function TRESTDWJsonReader.ReadString: String;
begin
  VerifyBsonType(TRESTDWBsonType.&String);
  State := GetNextState;
  Result := FCurrentValue.StrVal;
end;

function TRESTDWJsonReader.ReadSymbol: String;
begin
  VerifyBsonType(TRESTDWBsonType.Symbol);
  State := GetNextState;
  Result := FCurrentValue.StrVal;
end;

function TRESTDWJsonReader.ReadTimestamp: Int64;
begin
  VerifyBsonType(TRESTDWBsonType.Timestamp);
  State := GetNextState;
  Result := FCurrentValue.Int64Val;
end;

procedure TRESTDWJsonReader.ReadUndefined;
begin
  VerifyBsonType(TRESTDWBsonType.Undefined);
  State := GetNextState;
end;

procedure TRESTDWJsonReader.ReturnToBookmark(
  const ABookmark: IgoBsonReaderBookmark);
var
  BM: TJsonBookmark;
begin
  Assert(Assigned(ABookmark));
  Assert(ABookmark is TJsonBookmark);
  BM := TJsonBookmark(ABookmark);
  State := BM.State;
  CurrentBsonType := BM.CurrentBsonType;
  CurrentName := BM.CurrentName;
  FContextIndex := BM.ContextIndex;
  Assert((FContextIndex >= 0) and (FContextIndex < Length(FContextStack)));
  FContext := @FContextStack[FContextIndex];

  if Assigned(BM.CurrentToken) then
    FCurrentToken.Assign(BM.CurrentToken)
  else
    FCurrentToken := nil;

  FCurrentValue := BM.CurrentValue;

  if Assigned(BM.PushedToken) then
  begin
    FTokenToPush.Assign(BM.PushedToken);
    FPushedToken := FTokenToPush;
  end
  else
    FPushedToken := nil;

  FBuffer.Current := BM.Current;
end;

procedure TRESTDWJsonReader.SetCurrentValueRegEx(const AToken: TToken);
begin
  { Put in separate (non-inlined) method to avoid string finalization }
  FCurrentValue.StrVal := AToken.LexemeToString;
end;

procedure TRESTDWJsonReader.SkipName;
begin
  if (State <> TRESTDWBsonReaderState.Name) then
    raise FBuffer.ParseError(@RS_BSON_QUOTE_EXPECTED);

  State := TRESTDWBsonReaderState.Value;
end;

procedure TRESTDWJsonReader.SkipValue;
begin
  if (State <> TRESTDWBsonReaderState.Value) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_READER_STATE);

  case CurrentBsonType of
    TRESTDWBsonType.&Array:
      begin
        ReadStartArray;
        while (ReadBsonType <> TRESTDWBsonType.EndOfDocument) do
          SkipValue;
        ReadEndArray;
      end;

    TRESTDWBsonType.Binary: ReadBinaryData;
    TRESTDWBsonType.Boolean: ReadBoolean;
    TRESTDWBsonType.DateTime: ReadDateTime;

    TRESTDWBsonType.Document:
      begin
        ReadStartDocument;
        while (ReadBsonType <> TRESTDWBsonType.EndOfDocument) do
        begin
          SkipName;
          SkipValue;
        end;
        ReadEndDocument;
      end;

    TRESTDWBsonType.Double: ReadDouble;
    TRESTDWBsonType.Int32: ReadInt32;
    TRESTDWBsonType.Int64: ReadInt64;
    TRESTDWBsonType.JavaScript: ReadJavaScript;

    TRESTDWBsonType.JavaScriptWithScope:
      begin
        ReadJavaScriptWithScope;
        ReadStartDocument;
        while (ReadBsonType <> TRESTDWBsonType.EndOfDocument) do
        begin
          SkipName;
          SkipValue;
        end;
        ReadEndDocument;
      end;

    TRESTDWBsonType.MaxKey: ReadMaxKey;
    TRESTDWBsonType.MinKey: ReadMinKey;
    TRESTDWBsonType.Null: ReadNull;
    TRESTDWBsonType.ObjectId: ReadObjectId;
    TRESTDWBsonType.RegularExpression: ReadRegularExpression;
    TRESTDWBsonType.&String: ReadString;
    TRESTDWBsonType.Symbol: ReadSymbol;
    TRESTDWBsonType.Timestamp: ReadTimestamp;
    TRESTDWBsonType.Undefined: ReadUndefined;
  else
    raise FBuffer.ParseError(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TRESTDWJsonReader.VerifyString(const AExpectedString: String);
var
  Token: TToken;
begin
  PopToken(Token);
  if (not (Token.TokenType in [TTokenType.&String, TTokenType.UnquotedString]))
    or (Token.StringValue <> AExpectedString)
  then
    raise FBuffer.ParseError(@RS_BSON_STRING_WITH_VALUE_EXPECTED, [AExpectedString, Token.StringValue]);
end;

procedure TRESTDWJsonReader.VerifyToken(const AExpectedLexeme: Char);
var
  Token: TToken;
begin
  PopToken(Token);
  if (Token.LexemeLength <> 1) or (Token.LexemeStart^ <> AExpectedLexeme) then
    raise FBuffer.ParseError(@RS_BSON_TOKEN_EXPECTED, [String(AExpectedLexeme), Token.LexemeToString]);
end;

procedure TRESTDWJsonReader.VerifyToken(const AExpectedLexeme: PChar;
  const AExpectedLexemeLength: Integer);
var
  Token: TToken;
begin
  PopToken(Token);
  if (not Token.IsLexeme(AExpectedLexeme, AExpectedLexemeLength)) then
    raise FBuffer.ParseError(@RS_BSON_TOKEN_EXPECTED, [String(AExpectedLexeme), Token.LexemeToString]);
end;

{ TRESTDWJsonReader.TContext }

procedure TRESTDWJsonReader.TContext.Initialize(
  const AContextType: TRESTDWBsonContextType);
begin
  FContextType := AContextType;
end;

{ TRESTDWJsonReader.TBuffer }

procedure TRESTDWJsonReader.TBuffer.ClearErrorPos;
begin
  FErrorPos := nil;
end;

class function TRESTDWJsonReader.TBuffer.Create(const AJson: String): TBuffer;
begin
  Result.FJson := AJson;
  Result.FBuffer := PChar(AJson);
  Result.FCurrent := Result.FBuffer;
  Result.FLineStart := Result.FBuffer;
  Result.FPrevLineStart := Result.FBuffer;
  Result.FLineNumber := 1;
end;

function TRESTDWJsonReader.TBuffer.ParseError(
  const AMsg: PResStringRec): EgoJsonParserError;
begin
  Result := ParseError(LoadResString(AMsg));
end;

function TRESTDWJsonReader.TBuffer.ParseError(const AMsg: String): EgoJsonParserError;
var
  ColumnNumber,
  Position      : Integer;
  ErrorPos,
  TextStart     : {$IFNDEF FPC}PWideChar{$ELSE}PChar{$ENDIF};
begin
  if Assigned(FErrorPos) then
    ErrorPos := FErrorPos
  else
    ErrorPos := FCurrent;
  FErrorPos := nil;

  if (ErrorPos = nil) then
  begin
    ColumnNumber := 1;
    Position := 0;
  end
  else
  begin
    TextStart := FBuffer;
    ColumnNumber := ErrorPos - FLineStart;
    Position := ErrorPos - TextStart;
  end;
  Result := EgoJsonParserError.Create(AMsg, FLineNumber, ColumnNumber, Position);
end;

procedure TRESTDWJsonReader.TBuffer.MarkErrorPos;
begin
  FErrorPos := FCurrent;
end;

function TRESTDWJsonReader.TBuffer.ParseError(const AMsg: String;
  const AArgs: array of const): EgoJsonParserError;
begin
  Result := ParseError(Format(AMsg, AArgs));
end;

function TRESTDWJsonReader.TBuffer.ParseError(const AMsg: PResStringRec;
  const AArgs: array of const): EgoJsonParserError;
begin
  Result := ParseError(Format(LoadResString(AMsg), AArgs));
end;

function TRESTDWJsonReader.TBuffer.Read: Char;
begin
  Result := FCurrent^;
  case Result of
     #0: ;
    #10: begin
           Inc(FCurrent);
           Inc(FLineNumber);
           FPrevLineStart := FLineStart;
           FLineStart := FCurrent;
         end;
  else
    Inc(FCurrent);
  end;
end;

procedure TRESTDWJsonReader.TBuffer.Unread(const AChar: Char);
begin
  if (AChar = #0) then
    Exit;

  if (FCurrent = FBuffer) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if ((FCurrent - 1)^ <> AChar) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  Dec(FCurrent);

  if (AChar = #10) then
  begin
    Dec(FLineNumber);
    FLineStart := FPrevLineStart;
  end;
end;

{ TRESTDWJsonReader.TScanner }

var
  LEXEME_EOF         : array [0..4] of Char = '<eof>';
  LEXEME_BEGIN_OBJECT: Char = '{';
  LEXEME_END_OBJECT  : Char = '}';
  LEXEME_BEGIN_ARRAY : Char = '[';
  LEXEME_END_ARRAY   : Char = ']';
  LEXEME_LEFT_PAREN  : Char = '(';
  LEXEME_RIGHT_PAREN : Char = ')';
  LEXEME_COLON       : Char = ':';
  LEXEME_COMMA       : Char = ',';

class procedure TRESTDWJsonReader.TScanner.CharBeginArray(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.BeginArray, @LEXEME_BEGIN_ARRAY, 1);
end;

class procedure TRESTDWJsonReader.TScanner.CharBeginObject(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.BeginObject, @LEXEME_BEGIN_OBJECT, 1);
end;

class procedure TRESTDWJsonReader.TScanner.CharColon(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.Colon, @LEXEME_COLON, 1);
end;

class procedure TRESTDWJsonReader.TScanner.CharComma(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.Comma, @LEXEME_COMMA, 1);
end;

class procedure TRESTDWJsonReader.TScanner.CharEndArray(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.EndArray, @LEXEME_END_ARRAY, 1);
end;

class procedure TRESTDWJsonReader.TScanner.CharEndObject(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.EndObject, @LEXEME_END_OBJECT, 1);
end;

class procedure TRESTDWJsonReader.TScanner.CharEof(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.EndOfFile, LEXEME_EOF, 5);
end;

class procedure TRESTDWJsonReader.TScanner.CharError(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
var
  Error: EgoJsonParserError;
begin
  ABuffer.ClearErrorPos;
  Error := ABuffer.ParseError(@RS_BSON_UNEXPECTED_TOKEN);
  ABuffer.Unread(AChar);
  raise Error;
end;

class procedure TRESTDWJsonReader.TScanner.CharLeftParen(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.LeftParen, @LEXEME_LEFT_PAREN, 1);
end;

{$IFOPT Q+}
  {$DEFINE HAS_OVERFLOWCHECKS}
  {$OVERFLOWCHECKS OFF}
{$ENDIF}
class procedure TRESTDWJsonReader.TScanner.CharNumberToken(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
{ Lexical grammar:
    NumberLiteral: ['-'] DecimalLiteral
    DecimalLiteral: 'Inifinity'
                  | ['.'] DecimalDigits [ExponentPart]
                  | DecimalDigits '.' [DecimalDigits] [ExponentPart]
    DecimalDigits: ('0'..'9')+
    ExponentPart: ('e' | 'E') ['+' | '-'] DecimalDigits

  There are 3 special values: Inifinity, -Infinity and NaN.
  The values Infinity and NaN are handled elsewhere (in ReadBsonType), so here
  we only need to handle -Infinity. }
const
  NFINITY = 'nfinity';
var
  Current, Start: PChar;
  C: Byte;
  IsNegative, IsNegativeExponent: Boolean;
  I, aPower, Exponent: Integer;
  IntegerPart: Int64;
  Value: Double;
begin
  ABuffer.ClearErrorPos;
  Current := ABuffer.Current;
  Start := Current - 1;

  { NumberLiteral: ['-'] DecimalLiteral }
  if (AChar = '-') then
  begin
    IsNegative := True;
    IntegerPart := 0;
    if (Current^ = 'I') then
    begin
      { DecimalLiteral: 'Inifinity' }
      Inc(Current);
      for I := 0 to Length(NFINITY) - 1 do
      begin
        if (Current^ <> NFINITY.Chars[I]) then
        begin
          ABuffer.Current := Current;
          raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
        end;
        Inc(Current);
      end;

      ABuffer.Current := Current;
      C := Byte(Current^);
      if (C in [0..32, Ord(','), Ord('}'), Ord(']'), Ord(')')]) then
        AToken.Initialize(Start, Current - Start, NegInfinity)
      else
        raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
      Exit;
    end;
  end
  else
  begin
    IsNegative := False;
    IntegerPart := Ord(AChar) - Ord('0');
  end;

  { Parse integer part (before optional '.') }
  while True do
  begin
    C := Byte(Current^);
    if (C in [Ord('0')..Ord('9')]) then
    begin
      IntegerPart := (IntegerPart * 10) + (C - Ord('0'));
      Inc(Current);
    end
    else
      Break;
  end;

  if (C in [0..32, Ord(','), Ord('}'), Ord(']'), Ord(')')]) then
  begin
    { Integer value.
      Cannot start with a leading 0 (unless entire number is 0) }
    ABuffer.Current := Current;
    if (IntegerPart <> 0) and (Start^ = '0') then
      raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);

    if (IsNegative) then
      IntegerPart := -IntegerPart;

    if (IntegerPart < Integer.MinValue) or (IntegerPart > Integer.MaxValue) then
      AToken.Initialize(Start, Current - Start, IntegerPart)
    else
      AToken.Initialize(Start, Current - Start, Int32(IntegerPart));
    Exit;
  end;

  { Floating-point value }
  Value := IntegerPart;
  aPower := 0;

  if (C = Ord('.')) then
  begin
    { Parse fractional part }
    Inc(Current);

    { Fractional part must start with a digit... }
    C := Byte(Current^);
    if (C in [Ord('0')..Ord('9')]) then
    begin
      Value := (Value * 10.0) + (C - Ord('0'));
      Inc(Current);
      Dec(aPower);
    end
    else
    begin
      ABuffer.Current := Current;
      raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
    end;

    { ...followed by some more optional digits }
    while True do
    begin
      C := Byte(Current^);
      if (C in [Ord('0')..Ord('9')]) then
      begin
        Value := (Value * 10.0) + (C - Ord('0'));
        Inc(Current);
        Dec(aPower);
      end
      else
        Break;
    end;
  end;

  if (C in [Ord('e'), Ord('E')]) then
  begin
    { Parse exponent }
    Exponent := 0;
    Inc(Current);
    C := Byte(Current^);
    IsNegativeExponent := False;
    if (C = Ord('-')) then
    begin
      IsNegativeExponent := True;
      Inc(Current);
      C := Byte(Current^);
    end
    else if (Current^ = '+') then
    begin
      Inc(Current);
      C := Byte(Current^);
    end;

    { Exponent must start with a digit... }
    if (C in [Ord('0')..Ord('9')]) then
    begin
      Exponent := (Exponent * 10) + (C - Ord('0'));
      Inc(Current);
    end
    else
    begin
      ABuffer.Current := Current;
      raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
    end;

    { ...followed by some more optional digits }
    while True do
    begin
      C := Byte(Current^);
      if (C in [Ord('0')..Ord('9')]) then
      begin
        Exponent := (Exponent * 10) + (C - Ord('0'));
        Inc(Current);
      end
      else
        Break;
    end;

    if (IsNegativeExponent) then
      Exponent := -Exponent;

    Inc(aPower, Exponent);
  end;

  ABuffer.Current := Current;
  if (C in [0..32, Ord(','), Ord('}'), Ord(']'), Ord(')')]) then
  begin
    Value := {$IFNDEF FPC}Power10(Value, aPower){$ELSE}Power(Value, aPower){$ENDIF};//TODO XyberX
    if (IsNegative) then
      Value := -Value;
    AToken.Initialize(Start, Current - Start, Value);
  end
  else
    raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
end;
{$IFDEF HAS_OVERFLOWCHECKS}
  {$OVERFLOWCHECKS ON}
{$ENDIF}

class procedure TRESTDWJsonReader.TScanner.CharRegularExpressionToken(
  var ABuffer: TBuffer; const AChar: Char; const AToken: TToken);
var
  Start: PChar;
  State: TRegularExpressionState;
  C: Char;
begin
  ABuffer.ClearErrorPos;
  Start := ABuffer.Current - 1;
  State := TRegularExpressionState.InPattern;
  while True do
  begin
    C := ABuffer.Read;
    case State of
      TRegularExpressionState.InPattern:
        case C of
          '/': State := TRegularExpressionState.InOptions;
          '\': State := TRegularExpressionState.InEscapeSequence;
        else
          State := TRegularExpressionState.InPattern;
        end;

      TRegularExpressionState.InEscapeSequence:
        State := TRegularExpressionState.InPattern;

      TRegularExpressionState.InOptions:
        case C of
          'i', 'm', 'x', 's': State := TRegularExpressionState.InOptions;
          ',', '}', ']', ')', #0: State := TRegularExpressionState.Done;
        else
          if IsWhiteSpace(C) then
            State := TRegularExpressionState.Done
          else
            State := TRegularExpressionState.Invalid;
        end;
    end;

    case State of
      TRegularExpressionState.Done:
        begin
          ABuffer.Unread(C);
          AToken.InitializeRegEx(Start, ABuffer.Current - Start);
          Exit;
        end;

      TRegularExpressionState.Invalid:
        raise ABuffer.ParseError(@RS_BSON_INVALID_REGEX);
    end;
  end;
end;

class procedure TRESTDWJsonReader.TScanner.CharRightParen(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.RightParen, @LEXEME_RIGHT_PAREN, 1);
end;

class procedure TRESTDWJsonReader.TScanner.CharStringToken(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
var
  Current, Start: PChar;
  C: Char;
  S: String;
begin
  ABuffer.ClearErrorPos;
  Current := ABuffer.Current;
  Start := Current - 1;
  while True do
  begin
    C := Current^;
    Inc(Current);
    case C of
      #0:
        begin
          ABuffer.Current := Current;
          raise ABuffer.ParseError(@RS_BSON_INVALID_STRING);
        end;

      '\':
        begin
          SetString(S, Start + 1, Current - Start - 2);
          ABuffer.Current := Current - 1;
          CharStringTokenUnscape(ABuffer, AChar, AToken, Start, S);
          Exit;
        end;

      '''', '"':
        if (C = AChar) then
        begin
          SetString(S, Start + 1, Current - Start - 2);
          AToken.Initialize(TTokenType.&String, Start, Current - Start, S);
          ABuffer.Current := Current;
          Exit;
        end;
    end;
  end;
end;

class procedure TRESTDWJsonReader.TScanner.CharStringTokenUnscape(
  var ABuffer: TBuffer; const AQuoteChar: Char; const AToken: TToken;
  const AStart: PChar; const APrefix: String);
var
  CharBuffer: TRESTDWCharBuffer;
  Current: PChar;
  I: Integer;
  C: Char;
  S: String;
begin
  Current := ABuffer.Current;
  CharBuffer.Initialize;
  try
    while True do
    begin
      C := Current^;
      Inc(Current);
      case C of
        #0:
          begin
            ABuffer.Current := Current;
            raise ABuffer.ParseError(@RS_BSON_INVALID_STRING);
          end;

        '\':
          begin
            C := Current^;
            Inc(Current);
            case C of
              '''', '"', '\', '/': CharBuffer.Append(C);
              'b': CharBuffer.Append(#8);
              't': CharBuffer.Append(#9);
              'n': CharBuffer.Append(#10);
              'f': CharBuffer.Append(#12);
              'r': CharBuffer.Append(#13);
              'u': begin
                     ABuffer.Current := Current;
                     SetLength(S, 5);
                     S[Low(String) + 0] := '$';
                     S[Low(String) + 1] := ABuffer.Read;
                     S[Low(String) + 2] := ABuffer.Read;
                     S[Low(String) + 3] := ABuffer.Read;
                     C := ABuffer.Read;
                     S[Low(String) + 4] := C;
                     if (C <> #0) then
                     begin
                       I := StrToIntDef(S, -1);
                       if (I < 0) then
                         raise ABuffer.ParseError(@RS_BSON_INVALID_UNICODE_CODEPOINT);
                       CharBuffer.Append(Char(I));
                     end
                     else
                       raise ABuffer.ParseError(@RS_BSON_INVALID_STRING);
                     Current := ABuffer.Current;
                   end;
            else
              ABuffer.Current := Current;
              raise ABuffer.ParseError(@RS_BSON_INVALID_STRING);
            end;
          end;

        '''', '"':
          if (C = AQuoteChar) then
          begin
            AToken.Initialize(TTokenType.&String, AStart, Current - AStart,
              APrefix + CharBuffer.ToString);
            Exit;
          end
          else
            CharBuffer.Append(C);
      else
        CharBuffer.Append(C);
      end;
    end;
  finally
    CharBuffer.Release;
    ABuffer.Current := Current;
  end;
end;

class procedure TRESTDWJsonReader.TScanner.CharUnquotedStringToken(
  var ABuffer: TBuffer; const AChar: Char; const AToken: TToken);
var
  Start: PChar;
  C: Char;
  Lexeme: String;
begin
  ABuffer.MarkErrorPos;
  Start := ABuffer.Current - 1;
  C := ABuffer.Read;
  while (C = '$') or (C = '_') or
        {$IFNDEF FPC}C.IsLetterOrDigit
        {$ELSE}((TCharacter.IsDigit(C)) Or (TCharacter.IsLetter(C))){$ENDIF} do
    C := ABuffer.Read;
  ABuffer.Unread(C);
  SetString(Lexeme, Start, ABuffer.Current - Start);
  AToken.Initialize(TTokenType.UnquotedString, Start, ABuffer.Current - Start, Lexeme);
end;

class procedure TRESTDWJsonReader.TScanner.CharWhitespace(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
var
  C: Char;
begin
  C := ABuffer.Read;
  if (Ord(C) >= $80) then
    CharError(ABuffer, C, AToken)
  else
    FCharHandlers[C](ABuffer, C, AToken);
end;

class procedure TRESTDWJsonReader.TScanner.GetNextToken(var ABuffer: TBuffer;
  const AToken: TToken);
var
  C: Char;
begin
  C := ABuffer.Read;
  while (C <> #0) and (C <= ' ') do
    C := ABuffer.Read;

  if (Ord(C) >= $80) then
    CharError(ABuffer, C, AToken)
  else
    FCharHandlers[C](ABuffer, C, AToken);
end;

class procedure TRESTDWJsonReader.TScanner.Initialize;
var
  C: Char;
begin
  For C := #0 To #127 Do
   FCharHandlers[C]  := {$IFDEF FPC}@{$ENDIF}CharError;
  FCharHandlers[#0]  := {$IFDEF FPC}@{$ENDIF}CharEof;
  For C := #1 To #32  Do
   FCharHandlers[C]  := {$IFDEF FPC}@{$ENDIF}CharWhitespace;
  For C := '0' To '9' Do
   FCharHandlers[C]   := {$IFDEF FPC}@{$ENDIF}CharNumberToken;
  For C := 'a' To 'z' Do
   FCharHandlers[C]   := {$IFDEF FPC}@{$ENDIF}CharUnquotedStringToken;
  For C := 'A' To 'Z' Do
   FCharHandlers[C]   := {$IFDEF FPC}@{$ENDIF}CharUnquotedStringToken;
  FCharHandlers['{']  := {$IFDEF FPC}@{$ENDIF}CharBeginObject;
  FCharHandlers['}']  := {$IFDEF FPC}@{$ENDIF}CharEndObject;
  FCharHandlers['[']  := {$IFDEF FPC}@{$ENDIF}CharBeginArray;
  FCharHandlers[']']  := {$IFDEF FPC}@{$ENDIF}CharEndArray;
  FCharHandlers['(']  := {$IFDEF FPC}@{$ENDIF}CharLeftParen;
  FCharHandlers[')']  := {$IFDEF FPC}@{$ENDIF}CharRightParen;
  FCharHandlers[':']  := {$IFDEF FPC}@{$ENDIF}CharColon;
  FCharHandlers[',']  := {$IFDEF FPC}@{$ENDIF}CharComma;
  FCharHandlers[''''] := {$IFDEF FPC}@{$ENDIF}CharStringToken;
  FCharHandlers['"']  := {$IFDEF FPC}@{$ENDIF}CharStringToken;
  FCharHandlers['/']  := {$IFDEF FPC}@{$ENDIF}CharRegularExpressionToken;
  FCharHandlers['-']  := {$IFDEF FPC}@{$ENDIF}CharNumberToken;
  FCharHandlers['$']  := {$IFDEF FPC}@{$ENDIF}CharUnquotedStringToken;
  FCharHandlers['_']  := {$IFDEF FPC}@{$ENDIF}CharUnquotedStringToken;
end;

class function TRESTDWJsonReader.TScanner.IsWhitespace(const AChar: Char): Boolean;
begin
//  Result := AChar.IsWhitespace; // Official, but slow
  Result := (AChar <= ' ');
end;

{ TRESTDWJsonReader.TToken }

procedure TRESTDWJsonReader.TToken.Assign(const AOther: TToken);
begin
  if (AOther = Self) then
    Exit;

  FTokenType := AOther.FTokenType;
  FLexemeStart := AOther.FLexemeStart;
  FLexemeLength := AOther.FLexemeLength;
  FStringValue := AOther.FStringValue;
  FValue := AOther.FValue;
end;

procedure TRESTDWJsonReader.TToken.Initialize(const ATokenType: TTokenType;
  const ALexemeStart: PChar; const ALexemeLength: Integer);
begin
  FTokenType := ATokenType;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
end;

procedure TRESTDWJsonReader.TToken.Initialize(const ATokenType: TTokenType;
  const ALexemeStart: PChar; const ALexemeLength: Integer;
  const AStringValue: String);
begin
  FTokenType := ATokenType;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
  FStringValue := AStringValue;
end;

procedure TRESTDWJsonReader.TToken.Initialize(const ALexemeStart: PChar;
  const ALexemeLength: Integer; const ADoubleValue: Double);
begin
  FTokenType := TTokenType.Double;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
  FValue.DoubleValue := ADoubleValue;
end;

procedure TRESTDWJsonReader.TToken.Initialize(const ALexemeStart: PChar;
  const ALexemeLength: Integer; const AInt32Value: Int32);
begin
  FTokenType := TTokenType.Int32;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
  FValue.Int64Value := AInt32Value; // Clear upper 32 bits
end;

procedure TRESTDWJsonReader.TToken.Initialize(const ALexemeStart: PChar;
  const ALexemeLength: Integer; const AInt64Value: Int64);
begin
  FTokenType := TTokenType.Int64;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
  FValue.Int64Value := AInt64Value;
end;

procedure TRESTDWJsonReader.TToken.InitializeRegEx(const ALexemeStart: PChar;
  const ALexemeLength: Integer);
begin
  FTokenType := TTokenType.RegularExpression;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
end;

function TRESTDWJsonReader.TToken.IsLexeme(const AValue: PChar;
  const AValueLength: Integer): Boolean;
begin
  Result := (FLexemeLength = AValueLength)
    and CompareMem(AValue, FLexemeStart, AValueLength * SizeOf(Char));
end;

function TRESTDWJsonReader.TToken.LexemeToString: String;
begin
  SetString(Result, FLexemeStart, FLexemeLength);
end;

{ TRESTDWJsonReader.TJsonBookmark }

constructor TRESTDWJsonReader.TJsonBookmark.Create(const AState: TRESTDWBsonReaderState;
  const ACurrentBsonType: TRESTDWBsonType; const ACurrentName: String;
  const AContextIndex: Integer; const ACurrentToken: TToken;
  const ACurrentValue: TValue; const APushedToken: TToken;
  const ACurrent: PChar);
begin
  inherited Create(AState, ACurrentBsonType, ACurrentName);
  FContextIndex := AContextIndex;
  if Assigned(ACurrentToken) then
  begin
    FCurrentToken := TToken.Create;
    FCurrentToken.Assign(ACurrentToken);
  end;
  FCurrentValue := ACurrentValue;
  if Assigned(APushedToken) then
  begin
    FPushedToken := TToken.Create;
    FPushedToken.Assign(APushedToken);
  end;
  FCurrent := ACurrent;
end;

destructor TRESTDWJsonReader.TJsonBookmark.Destroy;
begin
  FCurrentToken.Free;
  FPushedToken.Free;
  inherited;
end;

{ TRESTDWBsonDocumentReader }

constructor TRESTDWBsonDocumentReader.Create(const ADocument: TRESTDWBsonDocument);
begin
  inherited Create;
  FCurrentValue := {$IFDEF FPC}TRESTDWBsonValue({$ENDIF}ADocument{$IFDEF FPC}){$ENDIF};
  FContextIndex := -1;
  PushContext(TRESTDWBsonContextType.TopLevel, ADocument);
end;

function TRESTDWBsonDocumentReader.EndOfStream: Boolean;
begin
  Result := (State = TRESTDWBsonReaderState.Done);
end;

function TRESTDWBsonDocumentReader.GetBookmark: IgoBsonReaderBookmark;
begin
  Assert(Assigned(FContext));
  Result := TDocumentBookmark.Create(State, CurrentBsonType, CurrentName,
    FContextIndex, FContext^.Index, FCurrentValue);
end;

function TRESTDWBsonDocumentReader.GetNextState: TRESTDWBsonReaderState;
begin
  Assert(Assigned(FContext));
  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.Document:
      Result := TRESTDWBsonReaderState.&Type;

    TRESTDWBsonContextType.TopLevel:
      Result := TRESTDWBsonReaderState.Done;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TRESTDWBsonDocumentReader.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWBsonDocumentReader.PushContext(
  const AContextType: TRESTDWBsonContextType; const AArray: TRESTDWBsonArray);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, AArray);
  FContext := @FContextStack[FContextIndex];
end;

procedure TRESTDWBsonDocumentReader.PushContext(
  const AContextType: TRESTDWBsonContextType; const ADocument: TRESTDWBsonDocument);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, ADocument);
  FContext := @FContextStack[FContextIndex];
end;

function TRESTDWBsonDocumentReader.ReadBinaryData: TRESTDWBsonBinaryData;
begin
  VerifyBsonType(TRESTDWBsonType.Binary);
  State := GetNextState;
  Result := FCurrentValue.AsBsonBinaryData;
end;

function TRESTDWBsonDocumentReader.ReadBoolean: Boolean;
begin
  VerifyBsonType(TRESTDWBsonType.Boolean);
  State := GetNextState;
  Result := FCurrentValue.AsBoolean;
end;

function TRESTDWBsonDocumentReader.ReadBsonType: TRESTDWBsonType;
var
  CurrentElement: TRESTDWBsonElement;
begin
  if (State in [TRESTDWBsonReaderState.Initial, TRESTDWBsonReaderState.ScopeDocument]) then
  begin
    CurrentBsonType := TRESTDWBsonType.Document;
    State := TRESTDWBsonReaderState.Value;
    Exit(CurrentBsonType);
  end;

  if (State <> TRESTDWBsonReaderState.&Type) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  Assert(Assigned(FContext));
  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array:
      begin
        if (not FContext^.TryGetNextValue(FCurrentValue)) then
        begin
          State := TRESTDWBsonReaderState.EndOfArray;
          Exit(TRESTDWBsonType.EndOfDocument);
        end;
        State := TRESTDWBsonReaderState.Value;
      end;

    TRESTDWBsonContextType.Document:
      begin
        if (not FContext^.TryGetNextElement(CurrentElement)) then
        begin
          State := TRESTDWBsonReaderState.EndOfDocument;
          Exit(TRESTDWBsonType.EndOfDocument);
        end;
        CurrentName := CurrentElement.Name;
        FCurrentValue := CurrentElement.Value;
        State := TRESTDWBsonReaderState.Name;
      end;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;

  CurrentBsonType := FCurrentValue.BsonType;
  Result := CurrentBsonType;
end;

function TRESTDWBsonDocumentReader.ReadBytes: TBytes;
var
  Binary: TRESTDWBsonBinaryData;
  SubType: TRESTDWBsonBinarySubType;
begin
  VerifyBsonType(TRESTDWBsonType.Binary);
  State := GetNextState;
  Binary := FCurrentValue.AsBsonBinaryData;
  SubType := Binary.SubType;
  if (not (SubType in [TRESTDWBsonBinarySubType.Binary, TRESTDWBsonBinarySubType.OldBinary])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
  Result := Binary.AsBytes;
end;

function TRESTDWBsonDocumentReader.ReadDateTime: Int64;
begin
  VerifyBsonType(TRESTDWBsonType.DateTime);
  State := GetNextState;
  Result := FCurrentValue.AsBsonDateTime.MillisecondsSinceEpoch;
end;

function TRESTDWBsonDocumentReader.ReadDouble: Double;
begin
  VerifyBsonType(TRESTDWBsonType.Double);
  State := GetNextState;
  Result := FCurrentValue.AsDouble;
end;

procedure TRESTDWBsonDocumentReader.ReadEndArray;
begin
  Assert(Assigned(FContext));
  if (FContext^.ContextType <> TRESTDWBsonContextType.&Array) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (State = TRESTDWBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TRESTDWBsonReaderState.EndOfArray) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  PopContext;
  Assert(Assigned(FContext));

  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.Document:
      State := TRESTDWBsonReaderState.&Type;

    TRESTDWBsonContextType.TopLevel:
      State := TRESTDWBsonReaderState.Done;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TRESTDWBsonDocumentReader.ReadEndDocument;
begin
  Assert(Assigned(FContext));
  if (not (FContext^.ContextType in [TRESTDWBsonContextType.Document, TRESTDWBsonContextType.ScopeDocument])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (State = TRESTDWBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TRESTDWBsonReaderState.EndOfDocument) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  PopContext;
  Assert(Assigned(FContext));

  case FContext^.ContextType of
    TRESTDWBsonContextType.&Array,
    TRESTDWBsonContextType.Document:
      State := TRESTDWBsonReaderState.&Type;

    TRESTDWBsonContextType.TopLevel:
      State := TRESTDWBsonReaderState.Done;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

function TRESTDWBsonDocumentReader.ReadInt32: Integer;
begin
  VerifyBsonType(TRESTDWBsonType.Int32);
  State := GetNextState;
  Result := FCurrentValue.AsInteger;
end;

function TRESTDWBsonDocumentReader.ReadInt64: Int64;
begin
  VerifyBsonType(TRESTDWBsonType.Int64);
  State := GetNextState;
  Result := FCurrentValue.AsInt64;
end;

function TRESTDWBsonDocumentReader.ReadJavaScript: String;
begin
  VerifyBsonType(TRESTDWBsonType.JavaScript);
  State := GetNextState;
  Result := FCurrentValue.AsBsonJavaScript.Code;
end;

function TRESTDWBsonDocumentReader.ReadJavaScriptWithScope: String;
begin
  VerifyBsonType(TRESTDWBsonType.JavaScriptWithScope);
  State := TRESTDWBsonReaderState.ScopeDocument;
  Result := FCurrentValue.AsBsonJavaScriptWithScope.Code;
end;

procedure TRESTDWBsonDocumentReader.ReadMaxKey;
begin
  VerifyBsonType(TRESTDWBsonType.MaxKey);
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentReader.ReadMinKey;
begin
  VerifyBsonType(TRESTDWBsonType.MinKey);
  State := GetNextState;
end;

function TRESTDWBsonDocumentReader.ReadName: String;
begin
  if (FState = TRESTDWBsonReaderState.&Type) then
    ReadBsonType;

  if (FState <> TRESTDWBsonReaderState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  State := TRESTDWBsonReaderState.Value;
  Result := CurrentName;
end;

procedure TRESTDWBsonDocumentReader.ReadNull;
begin
  VerifyBsonType(TRESTDWBsonType.Null);
  State := GetNextState;
end;

function TRESTDWBsonDocumentReader.ReadObjectId: TRESTDWObjectId;
begin
  VerifyBsonType(TRESTDWBsonType.ObjectId);
  State := GetNextState;
  Result := FCurrentValue.AsObjectId;
end;

function TRESTDWBsonDocumentReader.ReadRegularExpression: TRESTDWBsonRegularExpression;
begin
  VerifyBsonType(TRESTDWBsonType.RegularExpression);
  State := GetNextState;
  Result := FCurrentValue.AsBsonRegularExpression;
end;

procedure TRESTDWBsonDocumentReader.ReadStartArray;
var
  A: TRESTDWBsonArray;
begin
  VerifyBsonType(TRESTDWBsonType.&Array);
  A := FCurrentValue.AsBsonArray;
  PushContext(TRESTDWBsonContextType.&Array, A);
  State := TRESTDWBsonReaderState.&Type;
end;

procedure TRESTDWBsonDocumentReader.ReadStartDocument;
var
  Document: TRESTDWBsonDocument;
begin
  VerifyBsonType(TRESTDWBsonType.Document);

  if (FCurrentValue.IsBsonJavaScriptWithScope) then
    Document := FCurrentValue.AsBsonJavaScriptWithScope.Scope
  else
    Document := FCurrentValue.AsBsonDocument;

  PushContext(TRESTDWBsonContextType.Document, Document);
  State := TRESTDWBsonReaderState.&Type;
end;

function TRESTDWBsonDocumentReader.ReadString: String;
begin
  VerifyBsonType(TRESTDWBsonType.&String);
  State := GetNextState;
  Result := FCurrentValue.AsString;
end;

function TRESTDWBsonDocumentReader.ReadSymbol: String;
begin
  VerifyBsonType(TRESTDWBsonType.Symbol);
  State := GetNextState;
  Result := FCurrentValue.AsBsonSymbol.Name;
end;

function TRESTDWBsonDocumentReader.ReadTimestamp: Int64;
begin
  VerifyBsonType(TRESTDWBsonType.Timestamp);
  State := GetNextState;
  Result := FCurrentValue.AsBsonTimestamp.Value;
end;

procedure TRESTDWBsonDocumentReader.ReadUndefined;
begin
  VerifyBsonType(TRESTDWBsonType.Undefined);
  State := GetNextState;
end;

procedure TRESTDWBsonDocumentReader.ReturnToBookmark(
  const ABookmark: IgoBsonReaderBookmark);
var
  BM: TDocumentBookmark;
begin
  Assert(Assigned(ABookmark));
  Assert(ABookmark is TDocumentBookmark);
  BM := TDocumentBookmark(ABookmark);
  State := BM.State;
  CurrentBsonType := BM.CurrentBsonType;
  CurrentName := BM.CurrentName;
  FContextIndex := BM.ContextIndex;
  Assert((FContextIndex >= 0) and (FContextIndex < Length(FContextStack)));
  FContext := @FContextStack[FContextIndex];
  FContext^.Index := BM.ContextIndexIndex;
  FCurrentValue := BM.CurrentValue;
end;

procedure TRESTDWBsonDocumentReader.SkipName;
begin
  if (FState <> TRESTDWBsonReaderState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  State := TRESTDWBsonReaderState.Value;
end;

procedure TRESTDWBsonDocumentReader.SkipValue;
begin
  if (FState <> TRESTDWBsonReaderState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  State := TRESTDWBsonReaderState.&Type;
end;

{ TRESTDWBsonDocumentReader.TContext }

procedure TRESTDWBsonDocumentReader.TContext.Initialize(
  const AContextType: TRESTDWBsonContextType; const ADocument: TRESTDWBsonDocument);
begin
  FContextType := AContextType;
  FDocument := ADocument;
  FIndex := 0;
end;

procedure TRESTDWBsonDocumentReader.TContext.Initialize(
  const AContextType: TRESTDWBsonContextType; const AArray: TRESTDWBsonArray);
begin
  FContextType := AContextType;
  FArray := AArray;
  FIndex := 0;
end;

function TRESTDWBsonDocumentReader.TContext.TryGetNextElement(
  out AElement: TRESTDWBsonElement): Boolean;
begin
  if (FIndex < FDocument.Count) then
  begin
    AElement := FDocument.Elements[FIndex];
    Inc(FIndex);
    Result := True;
  end
  else
  begin
    AElement := Default(TRESTDWBsonElement);
    Result := False;
  end;
end;

function TRESTDWBsonDocumentReader.TContext.TryGetNextValue(
  out AValue: TRESTDWBsonValue): Boolean;
begin
  if (FIndex < FArray.Count) then
  begin
    AValue := FArray[FIndex];
    Inc(FIndex);
    Result := True;
  end
  else
    Result := False;
end;

{ TRESTDWBsonDocumentReader.TDocumentBookmark }

constructor TRESTDWBsonDocumentReader.TDocumentBookmark.Create(
  const AState: TRESTDWBsonReaderState; const ACurrentBsonType: TRESTDWBsonType;
  const ACurrentName: String; const AContextIndex, AContextIndexIndex: Integer;
  const ACurrentValue: TRESTDWBsonValue);
begin
  inherited Create(AState, ACurrentBsonType, ACurrentName);
  FContextIndex := AContextIndex;
  FContextIndexIndex := AContextIndexIndex;
  FCurrentValue := ACurrentValue;
end;

end.
