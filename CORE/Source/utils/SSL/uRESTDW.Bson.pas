unit uRESTDW.Bson;

{$SCOPEDENUMS ON}

(*< A light-weight and fast BSON and JSON object model, with support for
  efficiently parsing and writing in JSON and BSON format.

  The code in this unit is fully compatible with the BSON and JSON used by
  MongoDB. It supports all JSON extensions used by MongoDB.

  However, this unit does @bold(not) have any dependencies on the MongoDB units
  and can be used as a stand-alone BSON/JSON library. It is therefore also
  suitable as a general purpose JSON library.

  @bold(Quick Start)

  <source>
  var
    Doc: TRESTDWBsonDocument;
    A: TRESTDWBsonArray;
    Json: String;
    Bson: TBytes;
  begin
    Doc := TRESTDWBsonDocument.Create;
    Doc.Add('Hello', 'World');

    A := TRESTDWBsonArray.Create(['awesome', 5.05, 1986]);
    Doc.Add('BSON', A);

    Json := Doc.ToJson; // Returns:
    // { "hello" : "world",
    //   "BSON": ["awesone", 5.05, 1986] }

    Bson := Doc.ToBson; // Saves to binary BSON

    Doc := TRESTDWBsonDocument.Parse('{ "Answer" : 42 }');
    WriteLn(Doc['Answer']); // Outputs 42
    Doc['Answer'] := 'Unknown';
    Doc['Pi'] := 3.14;
    WriteLn(Doc.ToJson); // Outputs { "Answer" : "Unknown", "Pi" : 3.14 }
  end;
  </source>

  @bold(Object Model)

  The root type in the BSON object model is TRESTDWBsonValue. TRESTDWBsonValue is a
  record type which can hold any type of BSON value. Some implicit class
  operators make it easy to assign basic types:

  <source>
  var
    Value: TRESTDWBsonValue;
  begin
    Value := True;                           // Creates a Boolean value
    Value := 1;                              // Creates an Integer value
    Value := 3.14;                           // Creates a Double value
    Value := 'Foo';                          // Creates a String value
    Value := TBytes.Create(1, 2, 3);         // Creates a binary (TBytes) value
    Value := TRESTDWObjectId.GenerateNewId;      // Creates an ObjectId value
  end;
  </source>

  Note that you can change the type later by assigning a value of another type.
  You can also go the other way around:

  <source>
  var
    Value: TRESTDWBsonValue;
    FloatVal: Double;
  begin
    Value := 3.14;              // Creates a Double value
    FloatVal := Value;          // Uses implicit cast
    FloatVal := Value.AsDouble; // Or more explicit cast
    Value := 42;                // Creates an Integer value
    FloatVal := Value;          // Converts an Integer BSON value to a Double
    FloatVal := Value.AsDouble; // Raises exception because types don't match exactly

    if (Value.BsonType = TRESTDWBsonType.Double) then
      FloatVal := Value.AsDouble; // Now it is safe to cast

    // Or identical:
    if (Value.IsDouble) then
      FloatVal := Value.AsDouble;
  end;
  </source>

  Note that the implicit operators will try to convert if the types don't match
  exactly. For example, a BSON value containing an Integer value can be
  implicitly converted to a Double. If the conversion fails, it returns a zero
  value (or empty string).

  The "As*" methods however will raise an exception if the types don't match
  exactly. You should use these methods if you know that the type you request
  matches the value's type exactly. These methods are a bit more efficient than
  the implicit operators.

  You can check the value type using the BsonType-property or one of the "Is*"
  methods.

  For non-basic types, there are value types that are "derived" from
  TRESTDWBsonValue:
  * TRESTDWBsonNull: the special "null" value
  * TRESTDWBsonArray: an array of other BSON values.
  * TRESTDWBsonDocument: a document containing key/value pairs, where the key is a
    string and the value can be any BSON value. This is usually the main
    starting point in Mongo, since all database "records" are represented as
    BSON documents in Mongo. A document is similar to a dictionary in many
    programming languages, or the "object" type in JSON.
  * TRESTDWBsonBinaryData: arbitrary binary data. Is also used to store GUID's (but
    not ObjectId's).
  * TRESTDWBsonDateTime: a date/time value with support for conversion to and from
    UTC (Universal) time. Is always stored in UTC format (as the number of UTC
    milliseconds since the Unix epoch).
  * TRESTDWBsonRegularExpression: a regular expression with options.
  * TRESTDWBsonJavaScript: a piece of JavaScript code.
  * TRESTDWBsonJavaScriptWithScope: a piece of JavaScript code with a scope (a set
    of variables with values, as defined in another document).
  * TRESTDWBsonTimestamp: special internal type used by MongoDB replication and
    sharding.
  * TRESTDWBsonMaxKey: special type which compares higher than all other possible
    BSON element values.
  * TRESTDWBsonMinKey: special type which compares lower than all other possible
    BSON element values.
  * TRESTDWBsonUndefined: an undefined value (deprecated by BSON)
  * TRESTDWBsonSymbol: a symbol from a lookup table (deprecated by BSON)

  Note that these are not "real" derived types, since they are implemented as
  Delphi records (which do not support inheritance). But the implicit operators
  make it possible to treat each of these types as a TRESTDWBsonValue. For example

  <source>
  var
    MyArray: TRESTDWBsonArray;
    Value: TRESTDWBsonValue;
  begin
    MyArray := TRESTDWBsonArray.Create([1, 3.14, 'Foo', False]);
    Value := MyArray; // "subtypes" are compatible with TRESTDWBsonValue

    // Or shorter:
    Value := TRESTDWBsonArray.Create([1, 3.14, 'Foo', False]);
  end;
  </source>

  @Bold(Arrays)

  The example above also shows that arrays can be created very easily. An array
  contains a collection of BSON values of any type. Since BSON values can be
  implicitly created from basic types, you can pass multiple types in the
  array constructor. In the example above, 4 BSON values will be added to the
  array of types Integer, Double, String and Boolean.

  You can also add items using the Add or AddRange methods:

  <source>
  MyArray := TRESTDWBsonArray.Create;
  MyArray.Add(1);
  MyArray.Add(3.14);
  MyArray.Add('Foo');
  </source>

  Some methods return the array (or document) itself, so they can be used for
  chaining (aka as a "fluent interface"). The example above is equivalent to:

  <source>
  MyArray := TRESTDWBsonArray.Create;
  MyArray.Add(1).Add(3.14).Add('Foo');
  </source>

  You can change values (and types) like this:

  <source>
  // Changes entry 1 from Double to Boolean
  MyArray[1] := True;
  </source>

  @Bold(Documents)

  Documents (or dictionaries) can also be created easily:

  <source>
  var
    Doc: TRESTDWBsonDocument;
  begin
    Doc := TRESTDWBsonDocument.Create('Answer', 42);
  end;
  </source>

  This creates a document with a single entry called 'Answer' with a value of
  42. Keep in mind that the value can be any BSON type:

  <source>
  Doc := TRESTDWBsonDocument.Create('Answer', TRESTDWBsonArray.Create([42, False]));
  </source>

  You can Add, Remove and Delete (Adds can be fluent):

  <source>
  Doc := TRESTDWBsonDocument.Create;
  Doc.Add('Answer', 42);
  Doc.Add('Pi', 3.14).Add('Pie', 'Yummi');

  // Deletes second item (Pi):
  Doc.Delete(1);

  // Removes first item (Answer):
  Doc.Remove('Answer');
  </source>

  Like Delphi dictionaries, the Add method will raise an exception if an item
  with the given name already exists. Unlike Delphi dictionaries however, you
  can easily set an item using its default accessor:

  <source>
  // Adds Answer:
  Doc['Answer'] := 42;

  // Adds Pi:
  Doc['Pi'] := 3.14;

  // Updates Answer:
  Doc['Answer'] := 'Everything';
  </source>

  This adds the item if it does not yet exists, or replaces it otherwise (there
  is no (need for an) AddOrSet method).

  Also unlike Delphi dictionaries, documents maintain insertion order and you
  can also access the items by index:

  <source>
  // Returns item by name:
  V := Doc['Pi'];

  // Returns item by index:
  V := Doc.Values[1];
  </source>

  Documents can be easily parsed from JSON:

  <source>
  Doc := TRESTDWBsonDocument.Parse('{ "Answer" : 42 }');
  </source>

  The parser understands standard JSON as well as the MongoDB JSON extensions.

  You can also load a document from a BSON byte array:

  <source>
  Bytes := LoadSomeBSONData();
  Doc := TRESTDWBsonDocument.Load(Bytes);
  </source>

  These methods will raise exceptions if the JSON or BSON data is invalid.

  @bold(Memory Management)

  All memory management in this library is automatic. You never need to (and you
  never must) destroy any objects yourself.

  The object model types (TRESTDWBsonValue and friends) are all Delphi records. The
  actual implementations of these records use interfaces to manage memory.

  There is no concept of ownership in the object model. An array does @bold(not)
  own its elements and a document does @bold(not) own its elements. So you are
  free to add the same value to multiple arrays and/or documents without
  ownership concerns:

  <source>
  var
    Array1, Array2, SubArray, Doc1, Doc2: TRESTDWBsonValue;
  begin
    SubArray := TRESTDWBsonArray.Create([42, 'Foo', True]);
    Array1 := TRESTDWBsonArray.Create;
    Array2 := TRESTDWBsonArray.Create([123, 'Abc']);
    Doc1 := TRESTDWBsonDocument.Create;
    Doc2 := TRESTDWBsonDocument.Create('Pi', 3.14);

    Array1.Add(SubArray);
    Array2.Add(SubArray);      // Add same value to other container
    Doc1.Add('Bar', SubArray); // And again
    Doc2.Add('Baz', SubArray); // And again
  end;
  </source>

  Non-object model types are defined as interfaces, so their memory is managed
  automatically as well. For example JSON/BSON readers and writer are
  interfaces:

  <source>
  var
    Reader: IgoJsonReader;
    Value: TRESTDWBsonValue;
  begin
    Reader := TRESTDWJsonReader.Create('{ "Pi" : 3.14 }');
    Value := Reader.ReadValue;
    Assert(Value.IsDocument);
    Assert(Value.AsDocument['Pi'] = 3.14);
  end;
  </source>

  Just keep in mind that you must always declare your variable (Reader) as an
  interface type (IgoJsonReader), but you construct it using the class type
  (TRESTDWJsonReader).

  @bold(JSON and BSON reading and writing)

  For easy storing, all BSON values have methods called ToJson and ToBson to
  store its value into JSON or BSON format:

  <source>
  var
    A: TRESTDWBsonValue;
    B: TBytes;
  begin
    A := 42;
    WriteLn(A.ToJson); // Outputs '42'

    A := 'Foo';
    WriteLn(A.ToJson); // Outputs '"Foo"'

    A := TRESTDWBsonArray.Create([1, 'Foo', True]);
    WriteLn(A.ToJson); // Outputs '[1, "Foo", true]'

    A := TRESTDWBsonDocument.Create('Pi', 3.14);
    WriteLn(A.ToJson); // Outputs '{ "Pi" : 3.14 }'
    B := A.ToBson;     // Outputs document in BSON format
  end;
  </source>

  When outputting to JSON, you can optionally supply a settings record to
  customize the output:
  * Whether to pretty-print the output
  * What strings to use for indentation and line breaks
  * Whether to output standard JSON or use the MongoDB shell syntax extension

  If you don's supply any settings, then output will be in Strict JSON format
  without pretty printing.

  Easy loading is only supported at the Value, Document and Array level, using
  the Parse and Load methods:

  <source>
  var
    Doc: TRESTDWBsonDocument;
    Bytes: TBytes;
  begin
    Doc := TRESTDWBsonDocument.Parse('{ "Pi" : 3.14 }');
    Bytes := LoadSomeBSONData();
    Doc := TRESTDWBsonDocument.Load(Bytes);
  end;
  </source>

  You can load other types using the IgoJsonReader and IgoBsonReader
  interfaces:

  <source>
  var
    Reader: IgoBsonReader;
    Value: TRESTDWBsonValue;
    Bytes: TBytes;
  begin
    Bytes := LoadSomeBSONData();
    Reader := TRESTDWBsonReader.Create(Bytes);
    Value := Reader.ReadValue;
  end;
  </source>

  The JSON reader and writer supports both the "strict" JSON syntax, as well as
  the "Mongo Shell" syntax (see https://docs.mongodb.org/manual/reference/mongodb-extended-json/).
  Extended JSON is supported for both reading and writing. This library supports
  all the current extensions, as well as some deprecated legacy extensions.
  The JSON reader accepts both key names with double quotes (as per JSON spec)
  as without quotes.

  @bold(Manual reading and writing)

  For all situations, the methods ToJson, ToBson, Parse and Load can take care
  of reading and writing any kind of JSON and BSON data.

  However, you can use the reading and writing interfaces directly if you want
  for some reason. One reason may be that you want the fastest performance when
  creating BSON payloads, without the overhead of creating a document object
  model in memory.

  For information, see the unit RESTDW.Data.Bson.IO

  @bold(Serialization)

  For even easier reading and writing, you can use serialization to directory
  store a Delphi record or object in JSON or BSON format (or convert it to a
  TRESTDWBsonDocument).

  For information, see the unit RESTDW.Data.Bson.Serialization *)

{$INCLUDE 'uRESTDW.inc'}

interface

uses
 {$IFNDEF FPC}
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
 {$ELSE}
  Classes,
  SysUtils,
  SyncObjs,
  Generics.Collections,
 {$ENDIF}
 uRESTDWProtoTypes,
 uRESTDWTools;


{$IFDEF FPC}
 ResourceString
  SGenericDuplicateItem = 'Generic Duplicate Item...';
{$ENDIF}

type
  { Supported BSON types. As returned by TRESTDWBsonValue.BsonType.
    Tech note: Ordinal values must match BSON spec (http://bsonspec.org) }
  TRESTDWBsonType = (
    { Not a real BSON type. Used to signal the end of a document. }
    EndOfDocument       = $00,

    { A BSON double }
    Double              = $01,

    { A BSON string }
    &String             = $02,

    { A BSON document (see TRESTDWBsonDocument) }
    Document            = $03,

    { A BSON array (see TRESTDWBsonArray) }
    &Array              = $04,

    { BSON binary data (see TRESTDWBsonBinaryData) }
    Binary              = $05,

    { A BSON undefined value (see TRESTDWBsonUndefined) }
    Undefined           = $06,

    { A ObjectId, generally used with MongoDB (see TRESTDWObjectId) }
    ObjectId            = $07,

    { A BSON boolean }
    Boolean             = $08,

    { A BSON DateTime (see TRESTDWBsonDateTime) }
    DateTime            = $09,

    { A BSON null value (see TRESTDWBsonNull) }
    Null                = $0A,

    { A BSON regular expression (see TRESTDWBsonRegularExpression) }
    RegularExpression   = $0B,

    { BSON JavaScript code (see TRESTDWBsonJavaScript) }
    JavaScript          = $0D,

    { A BSON Symbol (see TRESTDWBsonSymbol, deprecated) }
    Symbol              = $0E,

    { BSON JavaScript code with a scope (see TRESTDWBsonJavaScriptWithScope) }
    JavaScriptWithScope = $0F,

    { A BSON 32-bit integer }
    Int32               = $10,

    { A BSON Timestamp (see TRESTDWBsonTimestamp) }
    Timestamp           = $11,

    { A BSON 64-bit integer }
    Int64               = $12,

    { A BSON MaxKey value (see TRESTDWBsonMaxKey) }
    MaxKey              = $7F,

    { A BSON MinKey value (see TRESTDWBsonMinKey) }
    MinKey              = $FF);

type
  { Supported BSON binary sub types.
    As returned by TRESTDWBsonBinaryData.SubType.
    Tech note: Ordinal values must match BSON spec (http://bsonspec.org) }
  TRESTDWBsonBinarySubType = (
    { Binary data in an arbitrary format }
    Binary       = $00,

    { A function }
    &Function    = $01,

    { Obsolete binary type }
    OldBinary    = $02,

    { A UUID/GUID in driver dependent legacy byte order }
    UuidLegacy   = $03,

    { A UUID/GUID in standard network byte order (big endian) }
    UuidStandard = $04,

    { A MD5 hash }
    MD5          = $05,

    { User defined type }
    UserDefined  = $80);

type
  { The output mode of a IgoJsonWriter, as set using TRESTDWJsonWriterSettings. }
  TRESTDWJsonOutputMode = (
    { Outputs strict JSON }
    Strict,

    { Outputs a format that can be used by the MongoDB shell }
    Shell);

type
  { Settings for a IgoJsonWriter }
  TRESTDWJsonWriterSettings = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private class var
    FDefault: TRESTDWJsonWriterSettings;
    FShell: TRESTDWJsonWriterSettings;
    FPretty: TRESTDWJsonWriterSettings;
  private
    FPrettyPrint: Boolean;
    FIndent: String;
    FLineBreak: String;
    FOutputMode: TRESTDWJsonOutputMode;
  public
    { @exclude }
    {$IFNDEF FPC}Class {$ENDIF}constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a settings record using the default settings:
      * PrettyPrint: False
      * OutputMode: Strict
      * Indent: 2 spaces (not used unless PrettyPrint is set to True later)
      * LineBreak: CR+LF (not used unless PrettyPrint is set to True later)

      Returns:
        The settings }
    Class function aCreate : TRESTDWJsonWriterSettings; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a settings record:

      Parameters:
        APrettyPrint: whether to use indentation (see Indent) and line breaks
          (see LineBreak).
        AOutputMode: (optional) output mode. Defaults to Strict.

      Returns:
        The settings }
    Class function aCreate(const APrettyPrint: Boolean;
      const AOutputMode: TRESTDWJsonOutputMode = TRESTDWJsonOutputMode.Strict): TRESTDWJsonWriterSettings; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a settings record:

      Parameters:
        AIndent: the string to use for indentation. Should only contain
          whitespace characters to create valid output.
        ALineBreak: the string to use for line breaks. Should only contain
          whitespace characters to create valid output.
        AOutputMode: (optional) output mode. Defaults to Strict.

      Returns:
        The settings.

      @bold(Note): this constructor sets PrettyPrint to True. }
    Class function aCreate(const AIndent, ALineBreak: String;
      const AOutputMode: TRESTDWJsonOutputMode = TRESTDWJsonOutputMode.Strict): TRESTDWJsonWriterSettings; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a settings record:

      Parameters:
        AOutputMode: output mode to use.

      Returns:
        The settings

      @bold(Note): this constructor sets PrettyPrint to False. }
    Class function aCreate(const AOutputMode: TRESTDWJsonOutputMode): TRESTDWJsonWriterSettings; overload; {$IFNDEF FPC}static;{$ENDIF}

    { The default settings:
      * PrettyPrint: False
      * OutputMode: Strict
      * Indent: 2 spaces (not used unless PrettyPrint is set to True later)
      * LineBreak: CR+LF (not used unless PrettyPrint is set to True later) }
    class property Default: TRESTDWJsonWriterSettings read FDefault;

    { "Shell" settings for outputing JSON with MongoDB shell extensions.
      * PrettyPrint: False
      * OutputMode: Shell
      * Indent: 2 spaces (not used unless PrettyPrint is set to True later)
      * LineBreak: CR+LF (not used unless PrettyPrint is set to True later) }
    class property Shell: TRESTDWJsonWriterSettings read FShell;

    { Settings for outputing JSON compliant JSON in a pretty format.
      * PrettyPrint: True
      * OutputMode: Strict
      * Indent: 2 spaces
      * LineBreak: CR+LF }
    class property Pretty: TRESTDWJsonWriterSettings read FPretty;

    { Whether to use indentation (see Indent) and line breaks (see LineBreak).
      Default False. }
    property PrettyPrint: Boolean read FPrettyPrint write FPrettyPrint;

    { String to use for indentation. Should only contain whitespace characters
      to create valid output. Not used unless PrettyPrint is True.
      Defaults to 2 spaces }
    property Indent: String read FIndent write FIndent;

    { String to use for line breaks. Should only contain whitespace characters
      to create valid output. Not used unless PrettyPrint is True.
      Defaults to CR+LF }
    property LineBreak: String read FLineBreak write FLineBreak;

    { Output mode to use.
      Defaults to Strict }
    property OutputMode: TRESTDWJsonOutputMode read FOutputMode write FOutputMode;
  end;

type
  { Represents an ObjectId. This is a 12-byte (96-bit) value that is regularly
    used for (unique) primary keys in MongoDB databases.

    Internally, an ObjectId is composed of:
    * A 4-byte value containing the number of seconds since the Unix epoch.
    * A 3-byte machine identifier
    * A 2-byte process identifier
    * A 3-byte counter, starting from a random value

    This makes ObjectId's fairly unique (but not as unique as GUID's though) }
  TRESTDWObjectId = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private class var
    FIncrement: Integer;
    FMachine: Integer;
    FPid: UInt16;
    FInitialized: Boolean;
  private
    function GetIsEmpty: Boolean;
    function GetTimestamp: Integer;
    function GetMachine: Integer;
    function GetPid: UInt16;
    function GetIncrement: Integer;
    function GetCreationTime: TDateTime;
  private
    class procedure Initialize; static;
    class function GetTimestampFromDateTime(const ATimestamp: TDateTime;
      const ATimestampIsUTC: Boolean): Integer; static;
  private
    procedure FromByteArray(const ABytes: TBytes);
  public
    { @exclude }
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an ObjectId from a byte array.

      Parameters:
        ABytes: the array of bytes to use for the ObjectId.
          Must be 12 bytes long.

      Returns:
        The ObjectId.

      Raises:
        EArgumentException if ABytes is not 12 bytes long }
    class function Create(const ABytes: TBytes): TRESTDWObjectId; overload; static;

    { Creates an ObjectId from a byte array.

      Parameters:
        ABytes: the array of bytes to use for the ObjectId.
          Must be 12 bytes long.

      Returns:
        The ObjectId.

      Raises:
        EArgumentException if ABytes is not 12 bytes long }
    class function Create(const ABytes: array of Byte): TRESTDWObjectId; overload; static;

    { Creates an ObjectId from its components.

      Parameters:
        ATimestamp: 32-bit number of seconds since Unix epoch.
        AMachine: 24-bit machine identifier. Must be >= 0 and < $01000000.
        APid: 16-bit process identifier.
        AIncrement: 24-bit counter. Must be >= 0 and < $01000000.

      Returns:
        The ObjectId.

      Raises:
        EArgumentOutOfRangeException if AMachine or AIncrement are out of range. }
    class function Create(const ATimestamp, AMachine: Integer; const APid: UInt16;
      const AIncrement: Integer): TRESTDWObjectId; overload; static;

    { Creates an ObjectId from its components.

      Parameters:
        ATimestamp: the date/time to use as a timestamp.
        ATimestampIsUTC: whether ATimestamp is in universal time.
        AMachine: 24-bit machine identifier. Must be >= 0 and < $01000000.
        APid: 16-bit process identifier.
        AIncrement: 24-bit counter. Must be >= 0 and < $01000000.

      Returns:
        The ObjectId.

      Raises:
        EArgumentOutOfRangeException if AMachine or AIncrement are out of range. }
    class function Create(const ATimestamp: TDateTime;
      const ATimestampIsUTC: Boolean; const AMachine: Integer;
      const APid: UInt16; const AIncrement: Integer): TRESTDWObjectId; overload; static;

    { Creates an ObjectId from its string representation (see ToString).

      Parameters:
        AString: the string representation of the ObjectId. Must contain 24
          hex digits.

      Returns:
        The ObjectId.

      Raises:
        EArgumentException if AString does not contain 24 hex digits.

      @bold(Note): this constructor is equal to the Parse method. }
    class function Create(const AString: String): TRESTDWObjectId; overload; static;

    { Generates a new ObjectId using the current timestamp, machine, process
      and counter settings.

      Returns:
        The newly generated ObjectId.

      @bold(Note): the returned ObjectId is guaranteed to be unique on the
      current system, even if this function is called at the same time from
      the same or other processes on the machine. However, the ObjectId is not
      neccesarily globally unique since another machine with the same hostname
      or computer name can theoretically generate the same Id. }
    class function GenerateNewId: TRESTDWObjectId; overload; static;

    { Generates a new ObjectId using a given timestamp and the current machine,
      process and counter settings.

      Parameters:
        ATimestamp: the date/time to use as a timestamp.
        ATimestampIsUTC: whether ATimestamp is in universal time.

      Returns:
        The newly generated ObjectId.

      @bold(Note): the returned ObjectId is guaranteed to be unique on the
      current system, even if this function is called at the same time from
      the same or other processes on the machine. However, the ObjectId is not
      neccesarily globally unique since another machine with the same hostname
      or computer name can theoretically generate the same Id. }
    class function GenerateNewId(const ATimestamp: TDateTime;
      const ATimestampIsUTC: Boolean): TRESTDWObjectId; overload; static;

    { Generates a new ObjectId using a given timestamp and the current machine,
      process and counter settings.

      Parameters:
        ATimestamp: 32-bit number of seconds since Unix epoch.

      Returns:
        The newly generated ObjectId.

      @bold(Note): the returned ObjectId is guaranteed to be unique on the
      current system, even if this function is called at the same time from
      the same or other processes on the machine. However, the ObjectId is not
      neccesarily globally unique since another machine with the same hostname
      or computer name can theoretically generate the same Id. }
    class function GenerateNewId(const ATimestamp: Integer): TRESTDWObjectId; overload; static;

    { Parses an ObjectId from its string representation (see ToString).

      Parameters:
        AString: the string representation of the ObjectId. Must contain 24
          hex digits.

      Returns:
        The ObjectId.

      Raises:
        EArgumentException if AString does not contain 24 hex digits }
    class function Parse(const AString: String): TRESTDWObjectId; overload; static;

    { Tries to parse an ObjectId from its string representation (see ToString).

      Parameters:
        AString: the string representation of the ObjectId. Must contain 24
          hex digits.
        AObjectId: is set to the parsed ObjectId, or all zeros if AString could
          not be parsed.

      Returns:
        True if AString could be successfully parsed. }
    class function TryParse(const AString: String;
      out AObjectId: TRESTDWObjectId): Boolean; overload; static;

    { Returns an empty ObjectId (with all zeros)

      Returns:
        The empty ObjectId. }
    class function Empty: TRESTDWObjectId; static;

    { Implicitly converts a string to an ObjectId. The string @bold(must)
      contain 24 hex digits. An EArgumentException will be raised if this is not
      the case }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF}Implicit(const A: String): TRESTDWObjectId;

    { Implicitly convers an ObjectId to a string }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF}Implicit(const A: TRESTDWObjectId): String;

    { Tests 2 ObjectId's for equality }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWObjectId):{$IFNDEF FPC}Boolean; static;{$ELSE} Boolean;{$ENDIF}

    { Tests 2 ObjectId's for inequality }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWObjectId):{$IFNDEF FPC}Boolean; static;{$ELSE} Boolean;{$ENDIF}

    { Compares 2 ObjectId's using the ">" operator }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} GreaterThan(const A, B: TRESTDWObjectId):{$IFNDEF FPC}Boolean; static;{$ELSE} Boolean;{$ENDIF}

    { Compares 2 ObjectId's using the ">=" operator }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} GreaterThanOrEqual(const A, B: TRESTDWObjectId):{$IFNDEF FPC}Boolean; static;{$ELSE} Boolean;{$ENDIF}

    { Compares 2 ObjectId's using the "<" operator }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} LessThan(const A, B: TRESTDWObjectId):{$IFNDEF FPC}Boolean; static;{$ELSE} Boolean;{$ENDIF}

    { Compares 2 ObjectId's using the "<=" operator }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} LessThanOrEqual(const A, B: TRESTDWObjectId):{$IFNDEF FPC}Boolean; static;{$ELSE} Boolean;{$ENDIF}

    { Converts the ObjectId to an array of 12 bytes.

      Returns:
        The ObjectId as 12 bytes. }
    function ToByteArray: TBytes; overload;

    { Converts the ObjectId to an array of bytes.

      Parameters:
        ADestination: byte array to store the ObjectId into.
        AOffset: starting offset in ADestination to use.

      Raises:
        EArgumentException if ADestination does not have room enough to store
        (AOffset+12) bytes. }
    procedure ToByteArray(const ADestination: TBytes; const AOffset: Integer); overload;

    { Converts the ObjectId to its string representation. This is a string
      containing 24 hex digits.

      Returns:
        The string representation of the ObjectId. }
    function ToString: String;

    { Compare this ObjectId to another one.

      Parameters:
        AOther: the other ObjectId.

      Returns:
        * -1 if Self < AOther
        * 0 if Self = AOther
        * 1 if Self > AOther }
    function CompareTo(const AOther: TRESTDWObjectId): Integer;

    { Returns True if this ObjectId is empty (all zeros) }
    property IsEmpty: Boolean read GetIsEmpty;

    { Timestamp component of the ObjectId.
      If the 32-bit number of seconds since Unix epoch. }
    property Timestamp: Integer read GetTimestamp;

    { Machine component of the ObjectId.
      Is a 24-bit machine identifier. }
    property Machine: Integer read GetMachine;

    { Process component of the ObjectId.
      Is a 16-bit process identifier. }
    property Pid: UInt16 read GetPid;

    { Counter component of the ObjectId.
      Is a 32-bit increment. }
    property Increment: Integer read GetIncrement;

    { The creation time of the ObjectId, as stored inside its Timestamp
      component. The time is in UTC. }
    property CreationTime: TDateTime read GetCreationTime;
  {$REGION 'Internal Declarations'}
  private
   {$IFNDEF FPC}
    Case Byte of
     0 : (FData  : Array [0..2]  Of UInt32);
     1 : (FBytes : Array [0..11] Of Byte);
   {$ELSE}
    FData  : Array [0..2]  Of UInt32;
    FBytes : Array [0..11] Of Byte;
   {$ENDIF}

  {$ENDREGION 'Internal Declarations'}
  end;
  PgoObjectId = ^TRESTDWObjectId;


{$IFDEF FPC}
Type
 TRESTDWBsonValue = Class;
Type
 TRESTDWArrayBsonValue = Array of TRESTDWBsonValue;
{$ENDIF}
Type
  { The base "class" for all BSON values. It is implemented as a record type
    which can hold any type of BSON value. }
  TRESTDWBsonValue = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  public type
    { @exclude }
    _IValue = interface
    ['{290B24D7-1D64-4F76-93C8-1B9D92658018}']
      function GetBsonType: TRESTDWBsonType;
      function AsBoolean: Boolean;
      function AsInteger: Integer;
      function AsInt64: Int64;
      function AsDouble: Double;
      function AsString: String;
      function AsArray: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF};
      function AsByteArray: TBytes;
      function AsGuid: TGUID;
      function AsObjectId: TRESTDWObjectId;

      function ToBoolean(const ADefault: Boolean): Boolean;
      function ToDouble(const ADefault: Double): Double;
      function ToInteger(const ADefault: Integer): Integer;
      function ToInt64(const ADefault: Int64): Int64;
      function ToString(const ADefault: String): String;
      function ToLocalTime: TDateTime;
      function ToUniversalTime: TDateTime;
      function ToByteArray: TBytes;
      function ToGuid: TGUID;
      function ToObjectId: TRESTDWObjectId;

      function Equals(const AOther: _IValue): Boolean;

      function Clone: _IValue;
      function DeepClone: _IValue;

      property BsonType: TRESTDWBsonType read GetBsonType;
    end;
  private
    FImpl: _IValue;
    function GetBsonType: TRESTDWBsonType; inline;
    function GetIsBoolean: Boolean; inline;
    function GetIsBsonArray: Boolean; inline;
    function GetIsBsonBinaryData: Boolean; inline;
    function GetIsBsonDateTime: Boolean; inline;
    function GetIsBsonDocument: Boolean; inline;
    function GetIsBsonJavaScript: Boolean; inline;
    function GetIsBsonJavaScriptWithScope: Boolean; inline;
    function GetIsBsonMaxKey: Boolean; inline;
    function GetIsBsonMinKey: Boolean; inline;
    function GetIsBsonNull: Boolean; inline;
    function GetIsBsonRegularExpression: Boolean; inline;
    function GetIsBsonSymbol: Boolean; inline;
    function GetIsBsonTimestamp: Boolean; inline;
    function GetIsBsonUndefined: Boolean; inline;
    function GetIsDateTime: Boolean; inline;
    function GetIsDouble: Boolean; inline;
    function GetIsGuid: Boolean; inline;
    function GetIsInt32: Boolean; inline;
    function GetIsInt64: Boolean; inline;
    function GetIsNumeric: Boolean; inline;
    function GetIsObjectId: Boolean; inline;
    function GetIsString: Boolean; inline;
  public
    { @exclude }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): Int8; {$IFNDEF FPC}static;{$ENDIF}
    { @exclude }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): UInt8; {$IFNDEF FPC}static;{$ENDIF}
    { @exclude }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): Int16; {$IFNDEF FPC}static;{$ENDIF}
    { @exclude }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): UInt16; {$IFNDEF FPC}static;{$ENDIF}
    { @exclude }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): UInt32; {$IFNDEF FPC}static;{$ENDIF}
    { @exclude }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): Single; {$IFNDEF FPC}static;{$ENDIF}

    { @exclude }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: UInt32): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}
    { @exclude }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: UInt64): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}
    { @exclude }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: Single): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { @exclude }
    property _Impl: _IValue read FImpl write FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON value by paring a JSON string.

      Parameters:
        AJson: the JSON string to parse.

      Returns:
        The BSON value

      Raises:
        EgoJsonParserError or EInvalidOperation on parse errors }
    class function Parse(const AJson: String): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to parse a JSON string to a BSON value.

      Parameters:
        AJson: the JSON string to parse.
        AArray: is set to the parsed JSON on success.

      Returns:
        True if the JSON string could be successfully parsed. }
    class function TryParse(const AJson: String; out AValue: TRESTDWBsonValue):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { Creates a BSON value from a BSON byte array.

      Parameters:
        ABson: the BSON byte array to load.

      Returns:
        The BSON value

      Raises:
        EInvalidOperation if BSON data is invalid }
    class function Load(const ABson: TBytes): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to load a BSON value from a BSON byte array.

      Parameters:
        ABson: the BSON byte array to load.
        AValue: is set to the loaded BSON on success.

      Returns:
        True if the BSON value could be successfully loaded. }
    class function TryLoad(const ABson: TBytes; out AValue: TRESTDWBsonValue):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { Loads a BSON value from a JSON file.

      Parameters:
        AFilename: the name of the JSON file

      Returns:
        The BSON value

      Raises:
        EgoJsonParserError or EInvalidOperation on parse errors }
    class function LoadFromJsonFile(const AFilename: String): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Loads a BSON value from a JSON stream.

      Parameters:
        AStream: the JSON stream

      Returns:
        The BSON value

      Raises:
        EgoJsonParserError or EInvalidOperation on parse errors }
    class function LoadFromJsonStream(const AStream: TStream): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Loads a BSON value from a BSON file.

      Parameters:
        AFilename: the name of the BSON file

      Returns:
        The BSON value

      Raises:
        EInvalidOperation when the BSON file is invalid }
    class function LoadFromBsonFile(const AFilename: String): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Loads a BSON value from a BSON stream.

      Parameters:
        AStream: the BSON stream

      Returns:
        The BSON value

      Raises:
        EInvalidOperation when the BSON file is invalid }
    class function LoadFromBsonStream(const AStream: TStream): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Saves the BSON value to a JSON file.

      Parameters:
        AFilename: the name of the JSON file. }
    procedure SaveToJsonFile(const AFilename: String); overload;

    { Saves the BSON value to a JSON file, using specified settings.

      Parameters:
        AFilename: the name of the JSON file.
        ASettings: the output settings to use, such as pretty-printing and
          Strict vs Shell mode. }
    procedure SaveToJsonFile(const AFilename: String;
      const ASettings: TRESTDWJsonWriterSettings); overload;

    { Saves the BSON value to a JSON stream.

      Parameters:
        AStream: the JSON stream }
    procedure SaveToJsonStream(const AStream: TStream); overload;

    { Saves the BSON value to a JSON stream.

      Parameters:
        AStream: the JSON stream
        ASettings: the output settings to use, such as pretty-printing and
          Strict vs Shell mode. }
    procedure SaveToJsonStream(const AStream: TStream;
      const ASettings: TRESTDWJsonWriterSettings); overload;

    { Saves the BSON value to a BSON file.

      Parameters:
        AFilename: the name of the BSON file. }
    procedure SaveToBsonFile(const AFilename: String);

    { Saves the BSON value to a BSON stream.

      Parameters:
        AStream: the BSON stream }
    procedure SaveToBsonStream(const AStream: TStream);

    { Implicitly converts a Boolean to a BSON value }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: Boolean): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly converts an Integer to a BSON value }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: Integer): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly converts an Int64 to a BSON value }
//    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: Int64): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly converts a Double to a BSON value }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: Double): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly converts an Extended to a BSON value }
    {$IFNDEF FPC}
     class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: Extended): TRESTDWBsonValue;{$IFNDEF FPC}static;{$ENDIF}
    {$ENDIF}

    { Implicitly converts a TDateTime a BSON value of type TRESTDWBsonDateTime.
      The TDateTime value @bold(must) be UTC format. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TDateTime): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly converts a String to a BSON value }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: String): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly converts an array of bytes to a BSON value of type
      TRESTDWBsonBinaryData with sub type Binary. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TBytes): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly converts a GUID to a BSON value of type TRESTDWBsonBinaryData with
      sub type UuidStandard. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TGUID): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly converts an ObjectId to a BSON value }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWObjectId): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to a Boolean.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: the value
      * Double: True if the value isn't 0 or NaN
      * Integer: True if the value isn't 0
      * Null: False
      * String: True if the value isn't an empty string
      * Otherwise: True }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { Tries to implicitly convert a BSON value to an Integer.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: truncated value
      * Integer: the value
      * String: String converted to Integer, if possible
      * Otherwise: 0 }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): Integer; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to an Int64.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: truncated value
      * Integer: the value
      * String: String converted to Int64, if possible
      * Otherwise: 0 }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): Int64; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to an UInt64.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: truncated value
      * Integer: the value
      * String: String converted to UInt64, if possible
      * Otherwise: 0 }
//    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): UInt64; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to an Double.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: the value
      * Integer: the value
      * String: String (in US format) converted to Double, if possible
      * Otherwise: 0 }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): Double; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to an Extended.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: the value
      * Integer: the value
      * String: String (in US format) converted to Double, if possible
      * Otherwise: 0 }
    {$IFNDEF FPC}
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): Extended; {$IFNDEF FPC}static;{$ENDIF}
    {$ENDIF}
    { Tries to implicitly convert a BSON value to a TDateTime in UTC format.
      Depending on the BsonType, one of the following will be returned:
      * DateTime: the value in UTC format
      * Otherwise: 0

      @bold(Note): see ToLocalTime and ToUniversalTime for more control over
      the output. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): TDateTime; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to a String.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 'false' or 'true'
      * Double: the value converted to a String (in US format)
      * Integer: the value converted to an Integer
      * String: the value
      * DateTime: UTC value in ISO8601 format
      * ObjectId: string representation of the ObjectId
      * Null: 'null'
      * Undefined: 'undefined'
      * MinKey: 'MinKey'
      * MaxKey: 'MaxKey'
      * Symbol: name of the symbol
      * Otherwise: '' (empty string) }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): String; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to a byte array.
      Depending on the BsonType, one of the following will be returned:
      * Binary: the value
      * Otherwise: nil (empty array) }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): TBytes; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to a GUID.
      Depending on the BsonType, one of the following will be returned:
      * Binary of sub type UuidLegacy or UuidStandard: the value
      * Otherwise: TGUID.Empty }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): TGUID; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to an ObjectId.
      Depending on the BsonType, one of the following will be returned:
      * ObjectId: the value
      * Otherwise: TRESTDWObjectId.Empty }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonValue): TRESTDWObjectId; {$IFNDEF FPC}static;{$ENDIF}

    { Tries to implicitly convert a BSON value to a TDateTime in local time.
      Depending on the BsonType, one of the following will be returned:
      * DateTime: the value in local time
      * Otherwise: 0 }
    function ToLocalTime: TDateTime; inline;

    { Tries to implicitly convert a BSON value to a TDateTime in universal time.
      Depending on the BsonType, one of the following will be returned:
      * DateTime: the value in universal time (UTC)
      * Otherwise: 0 }
    function ToUniversalTime: TDateTime; inline;

    { Tests 2 BSON values for equality. BSON values are equal if their types
      and contents match exactly. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonValue):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { Tests 2 BSON values for inequality }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonValue):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { Checks if the BSON value has been assigned.

      Returns:
        True if value hasn't been assigned yet.

      @bold(Note): does @bold(not) return True if the value is a NULL value
      (see IsBsonNull/AsBsonNull) }
    function IsNil: Boolean; inline;

    { Unassigns the BSON value (like setting an object to nil).
      IsNil will return True afterwards. }
    procedure SetNil; inline;

    { Tries to convert the value to a Boolean.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to False. }
    function ToBoolean(const ADefault: Boolean = False): Boolean; inline;

    { Tries to convert the value to a 32-bit integer.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to 0. }
    function ToInteger(const ADefault: Integer = 0): Integer; inline;

    { Tries to convert the value to a 64-bit integer.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to 0. }
    function ToInt64(const ADefault: Int64 = 0): Int64; inline;

    { Tries to convert the value to a floating-point number.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to 0.0. }
    function ToDouble(const ADefault: Double = 0): Double; inline;

    { Tries to convert the value to a string.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to ''. }
    function ToString(const ADefault: String = ''): String; inline;

    { Tries to convert the value to a GUID.
      Returns an empty GUID if the value cannot be converted. }
    function ToGuid: TGUID; inline;

    { Tries to convert the value to an ObjectId.
      Returns an empty ObjectId if the value cannot be converted. }
    function ToObjectId: TRESTDWObjectId; inline;

    { Returns the value as a Boolean.

      Raises:
        EIntfCastError if this value isn't a Boolean }
    function AsBoolean: Boolean; inline;

    { Returns the value as a 32-bit integer.

      Raises:
        EIntfCastError if this value isn't a 32-bit integer }
    function AsInteger: Integer; inline;

    { Returns the value as a 64-bit integer.

      Raises:
        EIntfCastError if this value isn't a 64-bit integer }
    function AsInt64: Int64; inline;

    { Returns the value as a Double.

      Raises:
        EIntfCastError if this value isn't a Double }
    function AsDouble: Double; inline;

    { Returns the value as a String.

      Raises:
        EIntfCastError if this value isn't a String }
    function AsString: String; inline;

    { Returns the value as a Delphi array of BSON values.

      Raises:
        EIntfCastError if this value isn't a BSON array }
    function AsArray: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}; inline;

    { Returns the value as an array of bytes.

      Raises:
        EIntfCastError if this value isn't a Binary value }
    function AsByteArray: TBytes; inline;

    { Returns the value as a GUID.

      Raises:
        EIntfCastError if this value isn't a Binary value of sub type
        UuidLegacy or UuidStandard. }
    function AsGuid: TGUID; inline;

    { Returns the value as an ObjectId.

      Raises:
        EIntfCastError if this value isn't an ObjectId }
    function AsObjectId: TRESTDWObjectId; inline;

    { Creates shallow clone of the value.

      Returns:
        The shallow clone

      @bold(Note): a shallow clone copies the value, but not any sub-values.
      For example, if the value is an array, then the array reference is copied,
      but not the individual elements. }
    function Clone: TRESTDWBsonValue; inline;

    { Creates deep clone of the value.

      Returns:
        The deep clone

      @bold(Note): a deep clone copies the value and any sub-values it may hold.
      For example, if the value is an array, then the array reference is copied,
      and its individual elements are copied as well. Any sub-values of those
      elements are also copied, etc... }
    function DeepClone: TRESTDWBsonValue; inline;

    { Saves the value to a BSON-compliant byte stream.

      Returns:
        The BSON byte stream. }
    function ToBson: TBytes; inline;

    { Saves the value to a string in JSON format.

      Returns:
        The value in JSON format.

      @bold(Note): the value is saved using the default writer settings. That
      is, without any pretty printing, and in Strict mode. Use the other overload
      of this function to specify output settings. }
    function ToJson: String; overload; inline;

    { Saves the value to a string in JSON format, using specified settings.

      Parameters:
        ASettings: the output settings to use, such as pretty-printing and
          Strict vs Shell mode.

      Returns:
        The value in JSON format. }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The type of this value. }
    property BsonType: TRESTDWBsonType read GetBsonType;

    { Whether this value represents a Boolean. }
    property IsBoolean: Boolean read GetIsBoolean;

    { Whether this value represents a BSON array. }
    property IsBsonArray: Boolean read GetIsBsonArray;

    { Whether this value represents a BSON binary value. }
    property IsBsonBinaryData: Boolean read GetIsBsonBinaryData;

    { Whether this value represents a BSON DateTime. }
    property IsBsonDateTime: Boolean read GetIsBsonDateTime;

    { Whether this value represents a BSON Document (aka Dictionary or Object). }
    property IsBsonDocument: Boolean read GetIsBsonDocument;

    { Whether this value represents a JavaScript script. }
    property IsBsonJavaScript: Boolean read GetIsBsonJavaScript;

    { Whether this value represents a JavaScript script with scope. }
    property IsBsonJavaScriptWithScope: Boolean read GetIsBsonJavaScriptWithScope;

    { Whether this value represents a BSON MaxKey value. }
    property IsBsonMaxKey: Boolean read GetIsBsonMaxKey;

    { Whether this value represents a BSON MinKey value. }
    property IsBsonMinKey: Boolean read GetIsBsonMinKey;

    { Whether this value represents a BSON Null value. }
    property IsBsonNull: Boolean read GetIsBsonNull;

    { Whether this value represents a regular expression. }
    property IsBsonRegularExpression: Boolean read GetIsBsonRegularExpression;

    { Whether this value represents a (deprectated) BSON symbol. }
    property IsBsonSymbol: Boolean read GetIsBsonSymbol;

    { Whether this value represents a BSON timestamp. }
    property IsBsonTimestamp: Boolean read GetIsBsonTimestamp;

    { Whether this value represents a BSON Undefined value. }
    property IsBsonUndefined: Boolean read GetIsBsonUndefined;

    { Whether this value represents a DateTime value. }
    property IsDateTime: Boolean read GetIsDateTime;

    { Whether this value represents a Double. }
    property IsDouble: Boolean read GetIsDouble;

    { Whether this value represents a GUID. }
    property IsGuid: Boolean read GetIsGuid;

    { Whether this value represents a 32-bit integer. }
    property IsInt32: Boolean read GetIsInt32;

    { Whether this value represents a 64-bit integer. }
    property IsInt64: Boolean read GetIsInt64;

    { Whether this value represents a numeric value (Integer or Double). }
    property IsNumeric: Boolean read GetIsNumeric;

    { Whether this value represents an ObjectId. }
    property IsObjectId: Boolean read GetIsObjectId;

    { Whether this value represents a String. }
    property IsString: Boolean read GetIsString;
  end;

type
  { An array of other BSON values }
  TRESTDWBsonArray = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  public type
    { @exclude }
    _IArray = interface(TRESTDWBsonValue._IValue)
    ['{968AA4B3-4569-4676-B85D-0DF953DC6D26}']
      function GetCount: Integer;
      procedure GetItem(const AIndex: Integer; out AValue: TRESTDWBsonValue._IValue);
      procedure SetItem(const AIndex: Integer; const AValue: TRESTDWBsonValue._IValue);

      procedure Add(const AValue: TRESTDWBsonValue._IValue);
      procedure AddRange(const AValues: array of TRESTDWBsonValue); overload;
      procedure AddRange(const AValues: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}); overload;
      procedure AddRange(const AValues: TRESTDWBsonArray); overload;
      procedure Delete(const AIndex: Integer);
      function Remove(const AValue: TRESTDWBsonValue): Boolean;
      procedure Clear;
      function Contains(const AValue: TRESTDWBsonValue): Boolean;
      function IndexOf(const AValue: TRESTDWBsonValue): Integer;

      property Count: Integer read GetCount;
    end;
  private type
    TEnumerator = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private
      FImpl: _IArray;
      FIndex: Integer;
      FHigh: Integer;
      function GetCurrent: TRESTDWBsonValue;
    public
      constructor Create(const AImpl: _IArray);
      function MoveNext: Boolean;

      property Current: TRESTDWBsonValue read GetCurrent;
    end;
  private
    FImpl: _IArray;
    function GetCount: Integer; inline;
    function GetItem(const AIndex: Integer): TRESTDWBsonValue; inline;
    procedure SetItem(const AIndex: Integer; const AValue: TRESTDWBsonValue); inline;
  public
    { @exclude }
    property _Impl: _IArray read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an empty BSON array.

      Parameters:
        ACapacity: (optional) initial capacity of the array. You can reduce
          memory reallocations if you know in advance the (approximate) number
          of values the array is going to hold.

      Returns:
        The empty BSON array }
    class function Create(const ACapacity: Integer = 0): TRESTDWBsonArray; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a BSON array an populates it with a Delphi array of values.

      Parameters:
        AValues: the Delphi array of values to populate the BSON array with.

      Returns:
        The BSON array

      Raises:
        EArgumentNilException if any of the values in the array has not been
        assigned (if their IsNil returns True for those). }
    class function Create(const AValues: array of TRESTDWBsonValue): TRESTDWBsonArray; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a BSON array an populates it with a Delphi array of values.

      Parameters:
        AValues: the Delphi array of values to populate the BSON array with.

      Returns:
        The BSON array

      Raises:
        EArgumentNilException if any of the values in the array has not been
        assigned (if their IsNil returns True for those). }
    class function Create(const AValues: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}): TRESTDWBsonArray; overload; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Parse }
    class function Parse(const AJson: String): TRESTDWBsonArray; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.TryParse }
    class function TryParse(const AJson: String; out AArray: TRESTDWBsonArray):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.Load }
    class function Load(const ABson: TBytes): TRESTDWBsonArray; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.TryLoad }
    class function TryLoad(const ABson: TBytes; out AArray: TRESTDWBsonArray):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.LoadFromJsonFile }
    class function LoadFromJsonFile(const AFilename: String): TRESTDWBsonArray; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.LoadFromJsonStream }
    class function LoadFromJsonStream(const AStream: TStream): TRESTDWBsonArray; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.LoadFromBsonFile }
    class function LoadFromBsonFile(const AFilename: String): TRESTDWBsonArray; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.LoadFromBsonStream }
    class function LoadFromBsonStream(const AStream: TStream): TRESTDWBsonArray; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.SaveToJsonFile }
    procedure SaveToJsonFile(const AFilename: String); overload;

    { See TRESTDWBsonValue.SaveToJsonFile }
    procedure SaveToJsonFile(const AFilename: String;
      const ASettings: TRESTDWJsonWriterSettings); overload;

    { See TRESTDWBsonValue.SaveToJsonStream }
    procedure SaveToJsonStream(const AStream: TStream); overload;

    { See TRESTDWBsonValue.SaveToJsonStream }
    procedure SaveToJsonStream(const AStream: TStream;
      const ASettings: TRESTDWJsonWriterSettings); overload;

    { See TRESTDWBsonValue.SaveToBsonFile }
    procedure SaveToBsonFile(const AFilename: String);

    { See TRESTDWBsonValue.SaveToBsonStream }
    procedure SaveToBsonStream(const AStream: TStream);

    { Implicitly casts a BSON array to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonArray): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonArray):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonArray):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.SetNil }
    procedure SetNil; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonArray; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonArray; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { Adds a value to the array.

      Parameters:
        AValue: the value to add.

      Returns:
        The array itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AValue has not been assigned (if IsNil returns
        True). }
    function Add(const AValue: TRESTDWBsonValue): TRESTDWBsonArray; inline;

    { Adds a range of values to the array.

      Parameters:
        AValues: the Delphi array of values to add to the array.


      Returns:
        The array itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if any of the values in the array has not been
        assigned (if their IsNil returns True for those). }
    function AddRange(const AValues: array of TRESTDWBsonValue): TRESTDWBsonArray; overload;

    { Adds a range of values to the array.

      Parameters:
        AValues: the Delphi array of values to add to the array.


      Returns:
        The array itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if any of the values in the array has not been
        assigned (if their IsNil returns True for those). }
    function AddRange(const AValues: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}): TRESTDWBsonArray; overload; inline;

    { Adds a range of values from another BSON array to this array.

      Parameters:
        AValues: the BSON array of values to add to this array.


      Returns:
        The array itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AValues has not been assigned or any of the
        values in the array has not been assigned (if their IsNil returns True
        for those). }
    function AddRange(const AValues: TRESTDWBsonArray): TRESTDWBsonArray; overload; inline;

    { Deletes a value from the array by index.

      Parameters:
        AIndex: the index of the value to delete.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds. }
    procedure Delete(const AIndex: Integer); inline;

    { Removes a value from the array.

      Parameters:
        AValue: the value to remove.

      Returns:
        True if the value was removed. False if the array does not contain the
        value.

      Raises:
        EArgumentNilException if AValue has not been assigned (if IsNil returns
        True).

      @bold(Note): the Equal operator of AValue is used to check if the value
      is in the array. }
    function Remove(const AValue: TRESTDWBsonValue): Boolean; inline;

    { Clears the array.

      Returns:
        The array itself, so you can use it for chaining. }
    function Clear: TRESTDWBsonArray; inline;

    { Checks if the array contains a given value.

      Parameters:
        AValue: the value to look for.

      Returns:
        True if the array contains the value.

      @bold(Note): the Equal operator of AValue is used to check if the value
      is in the array. }
    function Contains(const AValue: TRESTDWBsonValue): Boolean; inline;

    { Returns the index of a value in the array.

      Parameters:
        AValue: the value to look for.

      Returns:
        The index of the value in the array, or -1 if the array does not contain
        the value.

      @bold(Note): the Equal operator of AValue is used to check if the value
      is in the array. }
    function IndexOf(const AValue: TRESTDWBsonValue): Integer; inline;

    { Returns the values in the array as a Delphi array of values.

      Returns:
        The Delphi array of BSON values }
    function ToArray: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}; inline;

    { Allow <tt>for..in</tt> enumeration of the values in the array. }
    function GetEnumerator: TEnumerator; inline;

    { Number of items in the array }
    property Count: Integer read GetCount;

    { The items in the array.

      Parameters:
        AIndex: the index of the item to get or set.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds.
        EArgumentNilException when setting the item and AValue is not assigned
        (IsNil returns True) }
    property Items[const AIndex: Integer]: TRESTDWBsonValue read GetItem write SetItem; default;
  end;

type
  { An element in a TRESTDWBsonDocument }
  TRESTDWBsonElement = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FImpl: TRESTDWBsonValue._IValue;
    function GetValue: TRESTDWBsonValue; inline;
  public
    { @exclude }
    property _Impl: TRESTDWBsonValue._IValue read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a document element.

      Parameters:
        AName: the name of the element.
        AValue: the value of the element.

      Raises:
        EArgumentNilException if AValue has not been assigned (if IsNil returns
        True). }
    class function Create(const AName: String; const AValue: TRESTDWBsonValue): TRESTDWBsonElement; {$IFNDEF FPC}static;{$ENDIF}

    { Tests 2 document elements for equality. Elements are equal if both their
      names (case-sensitive) and values are equal. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonElement):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { Tests 2 document elements for inequality. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonElement): Boolean; inline; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a shallow clone of the element. The returned element will contain
      a reference to the existing value.

      Returns:
        The clone }
    function Clone: TRESTDWBsonElement;

    { Creates a deep clone of the element. The returned element will contain
      a deep clone of the existing value.

      Returns:
        The deep clone }
    function DeepClone: TRESTDWBsonElement;

    { Name of the element }
    property Name: String read FName;

    { Value of the element }
    property Value: TRESTDWBsonValue read GetValue;
  end;

Type
{$IFDEF FPC}
 TRESTDWArrayBsonElement = Array of TRESTDWBsonElement;
{$ELSE}
 TRESTDWArrayBsonElement = TArray<TRESTDWBsonElement>;
{$ENDIF}

type
  { A BSON document. A BSON document contains key/value pairs, where the key is
    a String and the value can be any BSON value. It is similar to a Delphi
    dictionary or a JSON object. However, unlike Delphi dictionaries, a
    documents maintains insertion order and you can access values both by name
    and by index. }
  TRESTDWBsonDocument = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  public type
    { @exclude }
    _IDocument = interface(TRESTDWBsonValue._IValue)
    ['{9E13B024-904D-44F6-BE16-33D81A0F057F}']
      function GetCount: Integer;
      function GetAllowDuplicateNames: Boolean;
      procedure SetAllowDuplicateNames(const Value: Boolean);
      function GetElement(const AIndex: Integer): TRESTDWBsonElement;
      procedure GetValue(const AIndex: Integer; out AValue: TRESTDWBsonValue._IValue);
      procedure SetValue(const AIndex: Integer; const AValue: TRESTDWBsonValue._IValue);
      procedure GetValueByName(const AName: String; out AValue: TRESTDWBsonValue._IValue);
      procedure SetValueByName(const AName: String; const AValue: TRESTDWBsonValue._IValue);

      procedure Add(const AName: String; const AValue: TRESTDWBsonValue._IValue);
      procedure Get(const AName: String; const ADefault: TRESTDWBsonValue._IValue;
        out AValue: TRESTDWBsonValue._IValue);
      function IndexOfName(const AName: String): Integer;
      function Contains(const AName: String): Boolean;
      function ContainsValue(const AValue: TRESTDWBsonValue): Boolean;
      function TryGetElement(const AName: String; out AElement: TRESTDWBsonElement): Boolean;
      function TryGetValue(const AName: String; out AValue: TRESTDWBsonValue._IValue): Boolean;
      procedure Remove(const AName: String);
      procedure Delete(const AIndex: Integer);
      procedure Clear;
      procedure Merge(const AOtherDocument: TRESTDWBsonDocument;
        const AOverwriteExistingElements: Boolean);
      function ToArray: TRESTDWArrayBsonElement;

      property AllowDuplicateNames: Boolean read GetAllowDuplicateNames write SetAllowDuplicateNames;
      property Count: Integer read GetCount;
      property Elements[const AIndex: Integer]: TRESTDWBsonElement read GetElement;
    end;
  private type
    TEnumerator = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private
      FImpl: _IDocument;
      FIndex: Integer;
      FHigh: Integer;
      function GetCurrent: TRESTDWBsonElement;
    public
      constructor Create(const AImpl: _IDocument);
      function MoveNext: Boolean;

      property Current: TRESTDWBsonElement read GetCurrent;
    end;
  private
    FImpl: _IDocument;
    function GetCount: Integer; inline;
    function GetElement(const AIndex: Integer): TRESTDWBsonElement; inline;
    function GetValue(const AIndex: Integer): TRESTDWBsonValue; inline;
    procedure SetValue(const AIndex: Integer; const AValue: TRESTDWBsonValue); inline;
    function GetValueByName(const AName: String): TRESTDWBsonValue; inline;
    procedure SetValueByName(const AName: String; const AValue: TRESTDWBsonValue); inline;
    function GetAllowDuplicateNames: Boolean; inline;
    procedure SetAllowDuplicateNames(const AValue: Boolean); inline;
  public
    { @exclude }
    property _Impl: _IDocument read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an empty BSON document.

      Returns:
        The empty BSON document }
    class function Create: TRESTDWBsonDocument; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates an empty BSON document.

      Parameters:
        AAllowDuplicateNames: whether to allow duplicate names in the document.
          This should generally be False.

      Returns:
        The empty BSON document }
    class function Create(const AAllowDuplicateNames: Boolean): TRESTDWBsonDocument; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a BSON document with a single element.

      Parameters:
        AElement: the element to add to the document.

      Returns:
        The BSON document

      Raises:
        EArgumentNilException if AElement.Value has not been assigned (if IsNil
        returns True) }
    class function Create(const AElement: TRESTDWBsonElement): TRESTDWBsonDocument; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a BSON document with a single element.

      Parameters:
        AName: the name of the element to add to the document.
        AValue: the value of the element.

      Returns:
        The BSON document

      Raises:
        EArgumentNilException if AValue has not been assigned (if IsNil returns
        True) }
    class function Create(const AName: String; const AValue: TRESTDWBsonValue): TRESTDWBsonDocument; overload; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Parse }
    class function Parse(const AJson: String; AllowDuplicateNames : Boolean = false): TRESTDWBsonDocument; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.TryParse }
    class function TryParse(const AJson: String; out ADocument: TRESTDWBsonDocument; AllowDuplicateNames : Boolean = false):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.Load }
    class function Load(const ABson: TBytes): TRESTDWBsonDocument; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.TryLoad }
    class function TryLoad(const ABson: TBytes; out ADocument: TRESTDWBsonDocument):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.LoadFromJsonFile }
    class function LoadFromJsonFile(const AFilename: String): TRESTDWBsonDocument; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.LoadFromJsonStream }
    class function LoadFromJsonStream(const AStream: TStream): TRESTDWBsonDocument; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.LoadFromBsonFile }
    class function LoadFromBsonFile(const AFilename: String): TRESTDWBsonDocument; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.LoadFromBsonStream }
    class function LoadFromBsonStream(const AStream: TStream): TRESTDWBsonDocument; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.SaveToJsonFile }
    procedure SaveToJsonFile(const AFilename: String); overload;

    { See TRESTDWBsonValue.SaveToJsonFile }
    procedure SaveToJsonFile(const AFilename: String;
      const ASettings: TRESTDWJsonWriterSettings); overload;

    { See TRESTDWBsonValue.SaveToJsonStream }
    procedure SaveToJsonStream(const AStream: TStream); overload;

    { See TRESTDWBsonValue.SaveToJsonStream }
    procedure SaveToJsonStream(const AStream: TStream;
      const ASettings: TRESTDWJsonWriterSettings); overload;

    { See TRESTDWBsonValue.SaveToBsonFile }
    procedure SaveToBsonFile(const AFilename: String);

    { See TRESTDWBsonValue.SaveToBsonStream }
    procedure SaveToBsonStream(const AStream: TStream);

    { Implicitly casts a BSON document to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonDocument): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonDocument):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonDocument):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.SetNil }
    procedure SetNil; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonDocument; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonDocument; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { Adds an element to the document.

      Parameters:
        AName: the name of the element to add to the document.
        AValue: the value of the element.

      Returns:
        The document itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
          True).
        EInvalidOperation if AllowDuplicateNames = False and document already
          contains element with given name.

      @bold(Note): Names are case-sensitive }
    function Add(const AName: String; const AValue: TRESTDWBsonValue): TRESTDWBsonDocument; overload; inline;

    { Adds an element to the document.

      Parameters:
        AElement: the element to add to the document.

      Returns:
        The document itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AElement.Value has not been assigned (IsNil
          returns True).
        EInvalidOperation if AllowDuplicateNames = False and document already
          contains element with given name.

      @bold(Note): Names are case-sensitive }
    function Add(const AElement: TRESTDWBsonElement): TRESTDWBsonDocument; overload; inline;

    { Gets a value from the document by name, or a default value if the document
      does not contain an element with the given name.

      Parameters:
        AName: the name of the value to get.
        ADefault: the default value to return in case the document does not
          contain an element named AName.

      Returns:
        The value associated with AName, or ADefault in case the document does
        not contain an element named AName. }
    function Get(const AName: String; const ADefault: TRESTDWBsonValue): TRESTDWBsonValue;

    { Returns the index of the element with a given name.

      Parameters:
        AName: the name of the element to find.

      Returns:
        The index of the element, or -1 of the document does not contain an
        element with the given name.

      @bold(Note): Names are case-sensitive }
    function IndexOfName(const AName: String): Integer; inline;

    { Checks whether the document contains an element with a given name.

      Parameters:
        AName: the name of the element to find.

      Returns:
        True if the document contains an element with the given name.

      @bold(Note): Names are case-sensitive }
    function Contains(const AName: String): Boolean; inline;

    { Checks whether the document contains an element with a given value.

      Parameters:
        AValue: the value of the element to find.

      Returns:
        True if the document contains an element with the given value.

      @bold(Note): the Equal operator of AValue is used to check if the value
      is in the document. }
    function ContainsValue(const AValue: TRESTDWBsonValue): Boolean; inline;

    { Tries to retrieve an element by name.

      Parameters:
        AName: the name of the element to find.
        AELement: is set to the corresponding element if found.

      Returns:
        True if the document contains an element with the given name. }
    function TryGetElement(const AName: String; out AElement: TRESTDWBsonElement): Boolean; inline;

    { Tries to retrieve a value by name.

      Parameters:
        AName: the name of the value to find.
        AValue: is set to the corresponding value if found.

      Returns:
        True if the document contains an element with the given name. }
    function TryGetValue(const AName: String; out AValue: TRESTDWBsonValue): Boolean; inline;

    { Removes an element by name.

      Parameters:
        AName: the name of the element to remove.

      @bold(Note):
        In case AllowDuplicateNames = True, then all elements with this name are
        removed. The method does nothing if the document does not contain an
        element with the given name. }
    procedure Remove(const AName: String); inline;

    { Deletes an element by index.

      Parameters:
        AIndex: the index of the element to delete.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds. }
    procedure Delete(const AIndex: Integer); inline;

    { Clears the document }
    procedure Clear; inline;

    { Merges another document into this one.

      Parameters:
        AOtherDocument: the other document to merge with this one.
        AOverwriteExistingElements: whether to overwrite existing element.

      Returns:
        The document itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AOtherDocument has not been assigned (IsNil
          returns True). }
    function Merge(const AOtherDocument: TRESTDWBsonDocument;
      const AOverwriteExistingElements: Boolean): TRESTDWBsonDocument;

    { Returns the elements in then document as an array.

      Returns:
        The array of elements }
    function ToArray: TRESTDWArrayBsonElement; inline;

    { Allow <tt>for..in</tt> enumeration of the elements in the document. }
    function GetEnumerator: TEnumerator; inline;

    { Whether duplicate element names are allowed.
      Should generally be False (the default). }
    property AllowDuplicateNames: Boolean read GetAllowDuplicateNames write SetAllowDuplicateNames;

    { Number of elements in the document.
      Could be larger than the number of names in the document in case
      AllowDuplicateNames = True }
    property Count: Integer read GetCount;

    { The elements in the document by index.

      Parameters:
        AIndex: the index of the element to get.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds. }
    property Elements[const AIndex: Integer]: TRESTDWBsonElement read GetElement;

    { The values in the document by index.

      Parameters:
        AIndex: the index of the value to get or set.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds.
        EArgumentNilException when setting the value and AValue is not assigned
        (IsNil returns True) }
    property Values[const AIndex: Integer]: TRESTDWBsonValue read GetValue write SetValue;

    { The values in the document by name.

      Parameters:
        AName: the name of the value to get or set.

      Raises:
        EArgumentNilException when setting the value and AValue is not assigned
        (IsNil returns True)

      @bold(Note): when getting a value and the name is not found, a TRESTDWBsonNull
      value is returned.

      @bold(Note): when setting a value, it will replace an existing value with
      the same name if found, or otherwise add it. }
    property ValuesByName[const AName: String]: TRESTDWBsonValue read GetValueByName write SetValueByName; default;
  end;

type
  { A blob of binary data }
  TRESTDWBsonBinaryData = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IBinaryData = interface(TRESTDWBsonValue._IValue)
    ['{8C7D00D2-6C0F-444F-A4A8-79F366BBA9A1}']
      function GetSubType: TRESTDWBsonBinarySubType;
      function GetCount: Integer;
      function GetByte(const AIndex: Integer): Byte;
      procedure SetByte(const AIndex: Integer; const AValue: Byte);
      function GetAsBytes: TBytes;

      property SubType: TRESTDWBsonBinarySubType read GetSubType;
      property Count: Integer read GetCount;
      property Bytes[const AIndex: Integer]: Byte read GetByte write SetByte; default;
      property AsBytes: TBytes read GetAsBytes;
    end;
  private
    FImpl: _IBinaryData;
    function GetSubType: TRESTDWBsonBinarySubType; inline;
    function GetCount: Integer; inline;
    function GetByte(const AIndex: Integer): Byte; inline;
    procedure SetByte(const AIndex: Integer; const AValue: Byte); inline;
    function GetAsBytes: TBytes; inline;
  public
    { @exclude }
    property _Impl: _IBinaryData read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an empty BSON binary.

      Returns:
        The empty BSON binary }
    class function Create: TRESTDWBsonBinaryData; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a BSON binary from a byte array.

      Parameters:
        AData: the bytes to populate the binary with.

      Returns:
        The BSON binary }
    class function Create(const AData: TBytes): TRESTDWBsonBinaryData; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a BSON binary from a byte array.

      Parameters:
        AData: the bytes to populate the binary with.
        ASubType: the type of binary data in AData.

      Returns:
        The BSON binary }
    class function Create(const AData: TBytes;
      const ASubType: TRESTDWBsonBinarySubType): TRESTDWBsonBinaryData; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly casts a BSON binary to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonBinaryData): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonBinaryData):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonBinaryData):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.SetNil }
    procedure SetNil; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonBinaryData; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonBinaryData; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The type of binary data this object contains }
    property SubType: TRESTDWBsonBinarySubType read GetSubType;

    { Number of bytes in the binary data }
    property Count: Integer read GetCount;

    { The bytes in the binary data.

      Parameters:
        AIndex: the index of the byte to get or set.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds. }
    property Bytes[const AIndex: Integer]: Byte read GetByte write SetByte; default;

    { Returns the binary as a byte array }
    property AsBytes: TBytes read GetAsBytes;
  end;

type
  { Represents the BSON Null value }
  TRESTDWBsonNull = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    _INull = interface(TRESTDWBsonValue._IValue)
    ['{112081EC-BB01-4974-948C-59CE64077420}']
    end;
  private class var
    FImpl: TRESTDWBsonNull;
  private
    FValue: _INull;
  public
    { @exclude }
    {$IFNDEF FPC}class {$ENDIF}constructor Create;
    { @exclude }
    property _Value: _INull read FValue;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON Null to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonNull): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonNull):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonNull):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonNull; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonNull; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The Null value singleton }
    class property Value: TRESTDWBsonNull read FImpl;
  end;

type
  { Represents the BSON Undefined value }
  TRESTDWBsonUndefined = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IUndefined = interface(TRESTDWBsonValue._IValue)
    ['{7410572B-2559-4036-B79A-A6237C0B2679}']
    end;
  private class var
    FImpl: TRESTDWBsonUndefined;
  private
    FValue: _IUndefined;
  public
    { @exclude }
    {$IFNDEF FPC}class {$ENDIF}constructor Create;

    { @exclude }
    property _Value: _IUndefined read FValue;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON Undefined to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonUndefined): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonUndefined):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonUndefined):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonUndefined; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonUndefined; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The Undefined value singleton }
    class property Value: TRESTDWBsonUndefined read FImpl;
  end;

type
  { A BSON DateTime value }
  TRESTDWBsonDateTime = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    _IDateTime = interface(TRESTDWBsonValue._IValue)
      ['{87332312-C7B7-4E45-B778-569166ACA2D2}']
      function GetMillisecondsSinceEpoch: Int64;

      property MillisecondsSinceEpoch: Int64 read GetMillisecondsSinceEpoch;
    end;
  private
    FImpl: _IDateTime;
    function GetMillisecondsSinceEpoch: Int64; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON DateTime value from a Delphi DateTime value.

      Parameters:
        ADateTime: the (Delphi) date time value
        ADateTimeIsUTC: whether ADateTime is in universal time

      Returns:
        The BSON DateTime value }
    class function Create(const ADateTime: TDateTime; const ADateTimeIsUTC: Boolean): TRESTDWBsonDateTime; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a BSON DateTime value.

      Parameters:
        AMillisecondsSinceEpoch: the number of milliseconds since the Unix epoch.

      Returns:
        The BSON DateTime value }
    class function Create(const AMillisecondsSinceEpoch: Int64): TRESTDWBsonDateTime; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly casts a BSON DateTime value to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonDateTime): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonDateTime):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonDateTime):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.SetNil }
    procedure SetNil; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonDateTime; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonDateTime; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { Converts the DateTime value to a Delphi DateTime value in local time }
    function ToLocalTime: TDateTime; inline;

    { Converts the DateTime value to a Delphi DateTime value in universal time }
    function ToUniversalTime: TDateTime; inline;

    { The number of milliseconds since the Unix epoch }
    property MillisecondsSinceEpoch: Int64 read GetMillisecondsSinceEpoch;
  end;

type
  { A BSON Timestamp. Mostly used internally for MongoDB replication and
    sharding. }
  TRESTDWBsonTimestamp = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _ITimestamp = interface(TRESTDWBsonValue._IValue)
    ['{212644B0-BF5F-4F16-AF96-50437C404DCA}']
      function GetIncrement: Integer;
      function GetTimestamp: Integer;
      function GetValue: Int64;

      property Value: Int64 read GetValue;
      property Timestamp: Integer read GetTimestamp;
      property Increment: Integer read GetIncrement;
    end;
  private
    FImpl: _ITimestamp;
    function GetIncrement: Integer; inline;
    function GetTimestamp: Integer; inline;
    function GetValue: Int64; inline;
  public
    { @exclude }
    property _Impl: _ITimestamp read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON Timestamp.

      Parameters:
        ATimestamp: the timestamp
        AIncrement: the increment

      Returns:
        The BSON Timestamp }
    class function Create(const ATimestamp, AIncrement: Integer): TRESTDWBsonTimestamp; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a BSON Timestamp.

      Parameters:
        AValue: the combined timestamp/increment value

      Returns:
        The BSON Timestamp }
    class function Create(const AValue: Int64): TRESTDWBsonTimestamp; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly casts a BSON Timestamp to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonTimestamp): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonTimestamp):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonTimestamp):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.SetNil }
    procedure SetNil; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonTimestamp; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonTimestamp; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The timestamp }
    property Timestamp: Integer read GetTimestamp;

    { The increment }
    property Increment: Integer read GetIncrement;

    { The combined timestamp/increment value }
    property Value: Int64 read GetValue;
  end;

type
  { A BSON Regular Expression }
  TRESTDWBsonRegularExpression = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IRegularExpression = interface(TRESTDWBsonValue._IValue)
    ['{C1283C00-6071-4DB7-82CD-5A53A00A7399}']
      function GetOptions: String;
      function GetPattern: String;

      property Pattern: String read GetPattern;
      property Options: String read GetOptions;
    end;
  private
    FImpl: _IRegularExpression;
    function GetOptions: String; inline;
    function GetPattern: String; inline;
  public
    { @exclude }
    property _Impl: _IRegularExpression read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON Regular Expression.

      Parameters:
        APattern: the regex pattern

      Returns:
        The BSON Regular Expression }
    class function Create(const APattern: String): TRESTDWBsonRegularExpression; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Creates a BSON Regular Expression.

      Parameters:
        APattern: the regex pattern
        AOptions: the regex options

      Returns:
        The BSON Regular Expression }
    class function Create(const APattern, AOptions: String): TRESTDWBsonRegularExpression; overload; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly converts a regex pattern String to a BSON Regular Expression }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: String): TRESTDWBsonRegularExpression; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly casts a BSON Regular Expression to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonRegularExpression): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonRegularExpression):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonRegularExpression):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.SetNil }
    procedure SetNil; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonRegularExpression; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonRegularExpression; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The regex pattern }
    property Pattern: String read GetPattern;

    { The regex options }
    property Options: String read GetOptions;
  end;

type
  { A piece of JavaScript code }
  TRESTDWBsonJavaScript = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IJavaScript = interface(TRESTDWBsonValue._IValue)
    ['{8659A4B1-171B-4C44-BBFC-109E14DE27FC}']
      function GetCode: String;

      property Code: String read GetCode;
    end;
  private
    FImpl: _IJavaScript;
    function GetCode: String; inline;
  public
    { @exclude }
    property _Impl: _IJavaScript read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON JavaScript.

      Parameters:
        ACode: the JavaScript code.

      Returns:
        The BSON JavaScript }
    class function Create(const ACode: String): TRESTDWBsonJavaScript; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly casts a BSON JavaScript to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonJavaScript): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonJavaScript):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonJavaScript):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.SetNil }
    procedure SetNil; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonJavaScript; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonJavaScript; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The JavaScript code }
    property Code: String read GetCode;
  end;

type
  { A piece of JavaScript code with a scope (a set of variables with values, as
    defined in another document).}
  TRESTDWBsonJavaScriptWithScope = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IJavaScriptWithScope = interface(TRESTDWBsonJavaScript._IJavaScript)
    ['{17B4EFE0-6FEE-4972-A2E5-1CAC276649D4}']
      function GetScope: TRESTDWBsonDocument;

      property Scope: TRESTDWBsonDocument read GetScope;
    end;
  private
    FImpl: _IJavaScriptWithScope;
    function GetCode: String; inline;
    function GetScope: TRESTDWBsonDocument; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON JavaScript w/scope.

      Parameters:
        ACode: the JavaScript code.
        AScope: the scope document containing the variables with values.

      Returns:
        The BSON JavaScript w/scope

      Raises:
        EArgumentNilException if AScope has not been assigned (IsNil returns True) }
    class function Create(const ACode: String;
      const AScope: TRESTDWBsonDocument): TRESTDWBsonJavaScriptWithScope; {$IFNDEF FPC}static;{$ENDIF}

    { Implicitly casts a BSON JavaScript w/scope to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonJavaScriptWithScope): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonJavaScriptWithScope):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonJavaScriptWithScope):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.SetNil }
    procedure SetNil; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonJavaScriptWithScope; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonJavaScriptWithScope; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The JavaScript code }
    property Code: String read GetCode;

    { The scope document containing the variables with values. }
    property Scope: TRESTDWBsonDocument read GetScope;
  end;

type
  { A symbol from a lookup table (deprecated by BSON).
    You create symbols using TRESTDWBsonSymbolTable.Lookup. }
  TRESTDWBsonSymbol = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _ISymbol = interface(TRESTDWBsonValue._IValue)
    ['{B63F0297-6A95-4A74-98DF-6E355E8E83B4}']
      function GetName: String;

      property Name: String read GetName;
    end;
  private
    FImpl: _ISymbol;
    function GetName: String; inline;
  public
    { @exclude }
    property _Impl: _ISymbol read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON Symbol to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonSymbol): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonSymbol):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonSymbol):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.SetNil }
    procedure SetNil; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonSymbol; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonSymbol; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The name of the symbol }
    property Name: String read GetName;
  end;

type
  { A table used to lookup TRESTDWBsonSymbol values }
  TRESTDWBsonSymbolTable = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private class var
    FTable: {$IFDEF FPC} specialize {$ENDIF} TDictionary<String, TRESTDWBsonSymbol>;
    FLock: TCriticalSection;
  public
    { @exclude }
    class constructor Create;

    { @exclude }
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public
    { Looks up a symbol.

      Parameters:
        AName: the name of the symbol the lookup.

      Returns:
        A symbol with the given name.

      If the table already contains a symbol with the given name, then that
      symbol is returned. Otherwise, a new symbol is added to the table. }
    class function Lookup(const AName: String): TRESTDWBsonSymbol; {$IFNDEF FPC}static;{$ENDIF}
  end;

type
  { Represents the BSON MaxKey value }
  TRESTDWBsonMaxKey = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IMaxKey = interface(TRESTDWBsonValue._IValue)
    ['{A6013802-3E77-4A53-B167-9EC4F0EDE896}']
    end;
  private class var
    FImpl: TRESTDWBsonMaxKey;
  private
    FValue: _IMaxKey;
  public
    { @exclude }
    {$IFNDEF FPC}class {$ENDIF}constructor Create;

    { @exclude }
    property _Value: _IMaxKey read FValue;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON MaxKey to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonMaxKey): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonMaxKey):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonMaxKey):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonMaxKey; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonMaxKey; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The MaxKey value singleton }
    class property Value: TRESTDWBsonMaxKey read FImpl;
  end;

type
  { Represents the BSON MinKey value }
  TRESTDWBsonMinKey = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IMinKey = interface(TRESTDWBsonValue._IValue)
    ['{539D88D8-5E9F-4FA0-8304-A81FA89D8934}']
    end;
  private class var
    FImpl: TRESTDWBsonMinKey;
  private
    FValue: _IMinKey;
  public
    { @exclude }
    {$IFNDEF FPC}class {$ENDIF}constructor Create;

    { @exclude }
    property _Value: _IMinKey read FValue;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON MinKey to a BSON value. }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Implicit(const A: TRESTDWBsonMinKey): TRESTDWBsonValue; {$IFNDEF FPC}static;{$ENDIF}

    { See TRESTDWBsonValue.Equal }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} Equal(const A, B: TRESTDWBsonMinKey):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.NotEqual }
    class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} NotEqual(const A, B: TRESTDWBsonMinKey):{$IFNDEF FPC}Boolean; {$IFNDEF FPC}static;{$ENDIF}{$ELSE} Boolean;{$ENDIF}

    { See TRESTDWBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TRESTDWBsonValue.Clone }
    function Clone: TRESTDWBsonMinKey; inline;

    { See TRESTDWBsonValue.DeepClone }
    function DeepClone: TRESTDWBsonMinKey; inline;

    { See TRESTDWBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TRESTDWBsonValue.ToJson }
    function ToJson(const ASettings: TRESTDWJsonWriterSettings): String; overload; inline;

    { The MinKey value singleton }
    class property Value: TRESTDWBsonMinKey read FImpl;
  end;

type
  { Adds methods to TRESTDWBsonValue }
  TRESTDWBsonValueHelper = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} helper for TRESTDWBsonValue
  public
    { Returns the value as a BSON array.
      Returns an empty array of the value isn't a BSON array }
    function ToBsonArray: TRESTDWBsonArray; inline;

    { Returns the value as a BSON array.

      Raises:
        EIntfCastError if this value isn't a BSON array }
    function AsBsonArray: TRESTDWBsonArray; inline;

    { Returns the value as a BSON binary.

      Raises:
        EIntfCastError if this value isn't a BSON binary }
    function AsBsonBinaryData: TRESTDWBsonBinaryData; inline;

    { Returns the value as a BSON document.
      Returns an empty document of the value isn't a BSON document }
    function ToBsonDocument: TRESTDWBsonDocument; inline;

    { Returns the value as a BSON document.

      Raises:
        EIntfCastError if this value isn't a BSON document }
    function AsBsonDocument: TRESTDWBsonDocument; inline;

    { Returns the value as a BSON JavaScript object.

      Raises:
        EIntfCastError if this value isn't a BSON JavaScript object }
    function AsBsonJavaScript: TRESTDWBsonJavaScript; inline;

    { Returns the value as a BSON JavaScript-with-scope object.

      Raises:
        EIntfCastError if this value isn't a BSON JavaScript-with-scope object }
    function AsBsonJavaScriptWithScope: TRESTDWBsonJavaScriptWithScope; inline;

    { Returns the value as a BSON MaxKey.

      Raises:
        EIntfCastError if this value isn't a BSON MaxKey }
    function AsBsonMaxKey: TRESTDWBsonMaxKey; inline;

    { Returns the value as a BSON MinKey.

      Raises:
        EIntfCastError if this value isn't a BSON MinKey }
    function AsBsonMinKey: TRESTDWBsonMinKey; inline;

    { Returns the value as a BSON Null.

      Raises:
        EIntfCastError if this value isn't a BSON Null }
    function AsBsonNull: TRESTDWBsonNull; inline;

    { Returns the value as a BSON Undefined.

      Raises:
        EIntfCastError if this value isn't a BSON Undefined }
    function AsBsonUndefined: TRESTDWBsonUndefined; inline;

    { Returns the value as a BSON Regular Expression.

      Raises:
        EIntfCastError if this value isn't a BSON Regular Expression }
    function AsBsonRegularExpression: TRESTDWBsonRegularExpression; inline;

    { Returns the value as a BSON Symbol.

      Raises:
        EIntfCastError if this value isn't a BSON Symbol }
    function AsBsonSymbol: TRESTDWBsonSymbol; inline;

    { Returns the value as a BSON DateTime.

      Raises:
        EIntfCastError if this value isn't a BSON DateTime }
    function AsBsonDateTime: TRESTDWBsonDateTime; inline;

    { Returns the value as a BSON Timestamp.

      Raises:
        EIntfCastError if this value isn't a BSON Timestamp }
    function AsBsonTimestamp: TRESTDWBsonTimestamp; inline;
  end;

{$REGION 'Internal Declarations'}
{ @exclude }
function _goBsonValueFromDouble(const AValue: Double): TRESTDWBsonValue._IValue;

{ @exclude }
function _goBsonValueFromString(const AValue: String): TRESTDWBsonValue._IValue;

{ @exclude }
function _goBsonValueFromObjectId(const AValue: TRESTDWObjectId): TRESTDWBsonValue._IValue;

{ @exclude }
function _goBsonValueFromBoolean(const AValue: Boolean): TRESTDWBsonValue._IValue;

{ @exclude }
function _goBsonValueFromDateTime(const AValue: Int64): TRESTDWBsonValue._IValue;

{ @exclude }
function _goBsonValueFromInt32(const AValue: Int32): TRESTDWBsonValue._IValue;

{ @exclude }
function _goBsonValueFromInt64(const AValue: Int64): TRESTDWBsonValue._IValue;

{ @exclude }
function _goCreateArray: TRESTDWBsonArray._IArray;

{ @exclude }
function _goCreateDocument: TRESTDWBsonDocument._IDocument;

{ @exclude }
procedure _goGetBinaryData(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonBinaryData);

{ @exclude }
procedure _goGetDateTime(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonDateTime);

{ @exclude }
procedure _goGetRegularExpression(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonRegularExpression);

{ @exclude }
procedure _goGetJavaScript(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonJavaScript);

{ @exclude }
procedure _goGetJavaScriptWithScope(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonJavaScriptWithScope);

{ @exclude }
procedure _goGetSymbol(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonSymbol);

{ @exclude }
procedure _goGetTimestamp(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonTimestamp);
{$ENDREGION 'Internal Declarations'}

implementation

uses
{$IFNDEF FPC}
 System.Types,
 System.SysConst,
 System.RTLConsts,
 System.DateUtils,
{$ELSE}
 Types,
 SysConst,
 RTLConsts,
 DateUtils,
{$ENDIF}
 uRESTDW.SysUtils,
 uRESTDW.DateUtils,
 uRESTDW.Bson.IO;

type
  TNonRefCountedInterface = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {IInterface}
  private
    FVTable: Pointer;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult;{$IFNDEF FPC}stdcall;{$ENDIF}
    function Addref : Integer; {$IFNDEF FPC}stdcall;{$ENDIF}
    function Release: Integer; {$IFNDEF FPC}stdcall;{$ENDIF}
  end;

type
  TRefCountedInterface = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {IInterface}
  private
    FVTable: Pointer;
    FRefCount: Integer;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult;{$IFNDEF FPC}stdcall;{$ENDIF}
    function Addref : Integer;{$IFNDEF FPC}stdcall;{$ENDIF}
    function Release: Integer;{$IFNDEF FPC}stdcall;{$ENDIF}
  end;

type
  TValue = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TInterfacedRecord, TRESTDWBsonValue._IValue}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsBoolean: Boolean;
    function AsInteger: Integer;
    function AsInt64: Int64;
    function AsDouble: Double;
    function AsString: String;
    function AsArray: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF};
    function AsByteArray: TBytes;
    function AsGuid: TGUID;
    function AsObjectId: TRESTDWObjectId;

    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function ToLocalTime: TDateTime;
    function ToUniversalTime: TDateTime;
    function ToByteArray: TBytes;
    function ToGuid: TGUID;
    function ToObjectId: TRESTDWObjectId;

    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;

    function Clone: TRESTDWBsonValue._IValue;
    function DeepClone: TRESTDWBsonValue._IValue;
  end;
  PValue = ^TValue;

type
  TInterfaceVTable = Record
    QueryInterface: Pointer;
    Addref: Pointer;
    Release: Pointer;
  end;

type
  TVTableValue = Record
    Intf: TInterfaceVTable;
    GetBsonType: Pointer;
    AsBoolean: Pointer;
    AsInteger: Pointer;
    AsInt64: Pointer;
    AsDouble: Pointer;
    AsString: Pointer;
    AsArray: Pointer;
    AsByteArray: Pointer;
    AsGuid: Pointer;
    AsObjectId: Pointer;
    ToBoolean: Pointer;
    ToDouble: Pointer;
    ToInteger: Pointer;
    ToInt64: Pointer;
    ToString: Pointer;
    ToLocalTime: Pointer;
    ToUniversalTime: Pointer;
    ToByteArray: Pointer;
    ToGuid: Pointer;
    ToObjectId: Pointer;
    Equals: Pointer;
    Clone: Pointer;
    DeepClone: Pointer;
  end;

type
  TValueFalse = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private class var
    FValue: TRESTDWBsonValue._IValue;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsBoolean: Boolean;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    class constructor Create;
  end;

const
  VTABLE_FALSE : TVTableValue = (
   {$IFNDEF FPC}
    Intf        : (QueryInterface: @TNonRefCountedInterface.QueryInterface;
    AddRef      : @TNonRefCountedInterface.AddRef;
    Release     : @TNonRefCountedInterface.Release);
    GetBsonType : @TValueFalse.GetBsonType;
    AsBoolean   : @TValueFalse.AsBoolean;
    AsInteger   : @TValue.AsInteger;
    AsInt64     : @TValue.AsInt64;
    AsDouble    : @TValue.AsDouble;
    AsString    : @TValue.AsString;
    AsArray     : @TValue.AsArray;
    AsByteArray : @TValue.AsByteArray;
    AsGuid      : @TValue.AsGuid;
    AsObjectId  : @TValue.AsObjectId;
    ToBoolean   : @TValueFalse.ToBoolean;
    ToDouble    : @TValueFalse.ToDouble;
    ToInteger   : @TValueFalse.ToInteger;
    ToInt64     : @TValueFalse.ToInt64;
    ToString    : @TValueFalse.ToString;
    ToLocalTime : @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray : @TValue.ToByteArray;
    ToGuid      : @TValue.ToGuid;
    ToObjectId  : @TValue.ToObjectId;
    Equals      : @TValueFalse.Equals;
    Clone       : @TValue.Clone;
    DeepClone   : @TValue.DeepClone
   {$ELSE}//TODO XyberX
    Intf        : (QueryInterface : @TNonRefCountedInterface.QueryInterface;
                   AddRef         : @TNonRefCountedInterface.AddRef;
                   Release        : @TNonRefCountedInterface.Release);
    GetBsonType : @TValueFalse.GetBsonType;
    AsBoolean   : @TValueFalse.AsBoolean;
    AsInteger   : @TValue.AsInteger;
    AsInt64     : @TValue.AsInt64;
    AsDouble    : @TValue.AsDouble;
    AsString    : @TValue.AsString;
    AsArray     : @TValue.AsArray;
    AsByteArray : @TValue.AsByteArray;
    AsGuid      : @TValue.AsGuid;
    AsObjectId  : @TValue.AsObjectId;
    ToBoolean   : @TValueFalse.ToBoolean;
    ToDouble    : @TValueFalse.ToDouble;
    ToInteger   : @TValueFalse.ToInteger;
    ToInt64     : @TValue.ToInt64;
    ToString    : @TValue.ToString;
    ToLocalTime : @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray : @TValue.ToByteArray;
    ToGuid      : @TValue.ToGuid;
    ToObjectId  : @TValue.ToObjectId;
    Equals      : @TValueFalse.Equals;
    Clone       : @TValue.Clone;
    DeepClone   : @TValue.DeepClone
   {$ENDIF});
const
  VALUE_BOOLEAN_FALSE: Pointer = @VTABLE_FALSE;

type
  TValueTrue = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private class var
    FValue: TRESTDWBsonValue._IValue;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsBoolean: Boolean;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    class constructor Create;
  end;

const
  VTABLE_TRUE: TVTableValue = (
   {$IFNDEF FPC}
    Intf: (QueryInterface : @TNonRefCountedInterface.QueryInterface;
           AddRef         : @TNonRefCountedInterface.AddRef;
           Release        : @TNonRefCountedInterface.Release);
    GetBsonType : @TValueTrue.GetBsonType;
    AsBoolean   : @TValueTrue.AsBoolean;
    AsInteger   : @TValue.AsInteger;
    AsInt64     : @TValue.AsInt64;
    AsDouble    : @TValue.AsDouble;
    AsString    : @TValue.AsString;
    AsArray     : @TValue.AsArray;
    AsByteArray : @TValue.AsByteArray;
    AsGuid      : @TValue.AsGuid;
    AsObjectId  : @TValue.AsObjectId;
    ToBoolean   : @TValueTrue.ToBoolean;
    ToDouble    : @TValueTrue.ToDouble;
    ToInteger   : @TValueTrue.ToInteger;
    ToInt64     : @TValueTrue.ToInt64;
    ToString    : @TValueTrue.ToString;
    ToLocalTime : @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray : @TValue.ToByteArray;
    ToGuid      : @TValue.ToGuid;
    ToObjectId  : @TValue.ToObjectId;
    Equals      : @TValueTrue.Equals;
    Clone       : @TValue.Clone;
    DeepClone   : @TValue.DeepClone
  {$ELSE}//TODO XyberX
   Intf        : (QueryInterface : @TNonRefCountedInterface.QueryInterface;
                  AddRef         : @TNonRefCountedInterface.AddRef;
                  Release        : @TNonRefCountedInterface.Release);
   GetBsonType : @TValueTrue.GetBsonType;
   AsBoolean   : @TValueTrue.AsBoolean;
   AsInteger   : @TValue.AsInteger;
   AsInt64     : @TValue.AsInt64;
   AsDouble    : @TValue.AsDouble;
   AsString    : @TValue.AsString;
   AsArray     : @TValue.AsArray;
   AsByteArray : @TValue.AsByteArray;
   AsGuid      : @TValue.AsGuid;
   AsObjectId  : @TValue.AsObjectId;
   ToBoolean   : @TValueTrue.ToBoolean;
   ToDouble    : @TValueTrue.ToDouble;
   ToInteger   : @TValueTrue.ToInteger;
   ToInt64     : @TValueTrue.ToInt64;
   ToString    : @TValueTrue.ToString;
   ToLocalTime : @TValue.ToLocalTime;
   ToUniversalTime: @TValue.ToUniversalTime;
   ToByteArray : @TValue.ToByteArray;
   ToGuid      : @TValue.ToGuid;
   ToObjectId  : @TValue.ToObjectId;
   Equals      : @TValueTrue.Equals;
   Clone       : @TValue.Clone;
   DeepClone   : @TValue.DeepClone
  {$ENDIF});

const
  VALUE_BOOLEAN_TRUE: Pointer = @VTABLE_TRUE;

type
  TValueInteger = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: Integer;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsInteger: Integer;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: Integer): TRESTDWBsonValue._IValue; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueInteger = ^TValueInteger;

const
  VTABLE_INTEGER: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueInteger.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValueInteger.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueInteger.ToBoolean;
    ToDouble: @TValueInteger.ToDouble;
    ToInteger: @TValueInteger.ToInteger;
    ToInt64: @TValueInteger.ToInt64;
    ToString: @TValueInteger.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueInteger.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueIntegerConst = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private const
    MIN_PRECREATED_VALUE = -100;
    MAX_PRECREATED_VALUE = 100;
  private class var
    FPrecreatedValues: array [MIN_PRECREATED_VALUE..MAX_PRECREATED_VALUE] of TRESTDWBsonValue._IValue;
    FPrecreatedData: Pointer;
  private
    FBase: TNonRefCountedInterface;
    FValue: Integer;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsInteger: Integer;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    {$IFNDEF FPC}class {$ENDIF}constructor Create;
    {$IFNDEF FPC}class {$ENDIF}destructor Destroy;
  end;
  PValueIntegerConst = ^TValueIntegerConst;

const
  VTABLE_INTEGER_CONST: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueIntegerConst.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValueIntegerConst.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueIntegerConst.ToBoolean;
    ToDouble: @TValueIntegerConst.ToDouble;
    ToInteger: @TValueIntegerConst.ToInteger;
    ToInt64: @TValueIntegerConst.ToInt64;
    ToString: @TValueIntegerConst.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueIntegerConst.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueInt64 = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: Int64;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsInt64: Int64;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: Int64): TRESTDWBsonValue._IValue; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueInt64 = ^TValueInt64;

const
  VTABLE_INT64: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueInt64.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValueInt64.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueInt64.ToBoolean;
    ToDouble: @TValueInt64.ToDouble;
    ToInteger: @TValueInt64.ToInteger;
    ToInt64: @TValueInt64.ToInt64;
    ToString: @TValueInt64.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueInt64.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueInt64Const = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private const
    MIN_PRECREATED_VALUE = -100;
    MAX_PRECREATED_VALUE = 100;
  private class var
    FPrecreatedValues: array [MIN_PRECREATED_VALUE..MAX_PRECREATED_VALUE] of TRESTDWBsonValue._IValue;
    FPrecreatedData: Pointer;
  private
    FBase: TNonRefCountedInterface;
    FValue: Int64;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsInt64: Int64;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    {$IFNDEF FPC}class {$ENDIF}constructor Create;
    {$IFNDEF FPC}class {$ENDIF}destructor Destroy;
  end;
  PValueInt64Const = ^TValueInt64Const;

const
  VTABLE_INT64_CONST: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueInt64Const.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValueInt64Const.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueInt64Const.ToBoolean;
    ToDouble: @TValueInt64Const.ToDouble;
    ToInteger: @TValueInt64Const.ToInteger;
    ToInt64: @TValueInt64Const.ToInt64;
    ToString: @TValueInt64Const.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueInt64Const.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueDouble = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: Double;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsDouble: Double;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: Double): TRESTDWBsonValue._IValue; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueDouble = ^TValueDouble;

const
  VTABLE_DOUBLE: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueDouble.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValueDouble.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueDouble.ToBoolean;
    ToDouble: @TValueDouble.ToDouble;
    ToInteger: @TValueDouble.ToInteger;
    ToInt64: @TValueDouble.ToInt64;
    ToString: @TValueDouble.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueDouble.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueDoubleZero = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private class var
    FValue: TRESTDWBsonValue._IValue;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsDouble: Double;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    {$IFNDEF FPC}class {$ENDIF}constructor Create;
  end;

const
  VTABLE_DOUBLE_ZERO: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueDoubleZero.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValueDoubleZero.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueDoubleZero.ToBoolean;
    ToDouble: @TValueDoubleZero.ToDouble;
    ToInteger: @TValueDoubleZero.ToInteger;
    ToInt64: @TValueDoubleZero.ToInt64;
    ToString: @TValueDoubleZero.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueDoubleZero.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

const
  VALUE_DOUBLE_ZERO: Pointer = @VTABLE_DOUBLE_ZERO;

type
  TValueDateTime = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonDateTime._IDateTime}
  private
    FBase: TRefCountedInterface;
    FMillisecondsSinceEpoch: Int64;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function ToLocalTime: TDateTime;
    function ToUniversalTime: TDateTime;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    { TRESTDWBsonDateTime._IDateTime }
    function GetMillisecondsSinceEpoch: Int64;
  public
    class function Create(const ADateTime: TDateTime; const ADateTimeIsUTC: Boolean): TRESTDWBsonDateTime._IDateTime; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
    class function Create(const AMillisecondsSinceEpoch: Int64): TRESTDWBsonDateTime._IDateTime; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueDateTime = ^TValueDateTime;

type
  TVTableValueDateTime = Record
    Base: TVTableValue;
    GetMillisecondsSinceEpoch: Pointer;
  end;

const
  VTABLE_DATE_TIME: TVTableValueDateTime = (
    Base:
     (Intf:
       (QueryInterface: @TValueDateTime.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TRefCountedInterface.Release);
      GetBsonType: @TValueDateTime.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValueDateTime.ToString;
      ToLocalTime: @TValueDateTime.ToLocalTime;
      ToUniversalTime: @TValueDateTime.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueDateTime.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);
    GetMillisecondsSinceEpoch: @TValueDateTime.GetMillisecondsSinceEpoch);

type
  TValueString = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private
    FBase: TRefCountedInterface;
    FLength: Integer;
    { Data: array of Char }
  private
    function Value: String; inline;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsString: String;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: String): TRESTDWBsonValue._IValue; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueString = ^TValueString;

const
  VTABLE_STRING: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueString.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValueString.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueString.ToBoolean;
    ToDouble: @TValueString.ToDouble;
    ToInteger: @TValueString.ToInteger;
    ToInt64: @TValueString.ToInt64;
    ToString: @TValueString.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueString.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueStringEmpty = {$IFNDEF FPC}Packed Record{$ELSE}Class{$ENDIF} {TValue}
  private class var
    FValue: TRESTDWBsonValue._IValue;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsString: String;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    {$IFNDEF FPC}class {$ENDIF}constructor Create;
  end;

const
  VTABLE_STRING_EMPTY: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueStringEmpty.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValueStringEmpty.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueStringEmpty.ToBoolean;
    ToDouble: @TValueStringEmpty.ToDouble;
    ToInteger: @TValueStringEmpty.ToInteger;
    ToInt64: @TValueStringEmpty.ToInt64;
    ToString: @TValueStringEmpty.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueStringEmpty.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

const
  VALUE_STRING_EMPTY: Pointer = @VTABLE_STRING_EMPTY;

type
  TValueStringConstant = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: Pointer;
  private
    function Value: String; inline;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsString: String;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: String): TRESTDWBsonValue._IValue; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueStringConstant = ^TValueStringConstant;

const
  VTABLE_STRING_CONSTANT: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueStringConstant.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValueStringConstant.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueStringConstant.ToBoolean;
    ToDouble: @TValueStringConstant.ToDouble;
    ToInteger: @TValueStringConstant.ToInteger;
    ToInt64: @TValueStringConstant.ToInt64;
    ToString: @TValueStringConstant.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueStringConstant.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueArray = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonArray._IArray}
  private
    FBase: TRefCountedInterface;
    FItems: {$IFDEF FPC}specialize {$ENDIF}TArray<TRESTDWBsonValue._IValue>;
    FCount: Integer;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsArray: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF};
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
    function Clone: TRESTDWBsonValue._IValue;
    function DeepClone: TRESTDWBsonValue._IValue;
  public
    { TRESTDWBsonArray._IArray }
    function GetCount: Integer;
    procedure GetItem(const AIndex: Integer; out AValue: TRESTDWBsonValue._IValue);
    procedure SetItem(const AIndex: Integer; const AValue: TRESTDWBsonValue._IValue);
    procedure Add(const AValue: TRESTDWBsonValue._IValue); overload;
    procedure AddRangeOpenArray(const AValues: array of TRESTDWBsonValue); overload;
    procedure AddRangeGenArray(const AValues: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}); overload;
    procedure AddRangeBsonArray(const AValues: TRESTDWBsonArray); overload;
    procedure Delete(const AIndex: Integer);
    function Remove(const AValue: TRESTDWBsonValue): Boolean;
    procedure Clear;
    function Contains(const AValue: TRESTDWBsonValue): Boolean;
    function IndexOf(const AValue: TRESTDWBsonValue): Integer;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
    function Release: Integer; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    class function Create(const ACapacity: Integer = 0): TRESTDWBsonArray._IArray; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
    class function Create(const AValues: array of TRESTDWBsonValue): TRESTDWBsonArray._IArray; overload; {$IFNDEF FPC}static;{$ENDIF}
    class function Create(const AValues: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}): TRESTDWBsonArray._IArray; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueArray = ^TValueArray;

type
  TVTableValueArray = Record
    Base: TVTableValue;
    GetCount: Pointer;
    GetItem: Pointer;
    SetItem: Pointer;
    Add: Pointer;
    AddRangeOpenArray: Pointer;
    AddRangeGenArray: Pointer;
    AddRangeBsonArray: Pointer;
    Delete: Pointer;
    Remove: Pointer;
    Clear: Pointer;
    Contains: Pointer;
    IndexOf: Pointer;
  end;

const
  VTABLE_ARRAY: TVTableValueArray = (
    Base:
     (Intf:
       (QueryInterface: @TValueArray.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueArray.Release);
      GetBsonType: @TValueArray.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValueArray.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueArray.Equals;

      Clone: @TValueArray.Clone;
      DeepClone: @TValueArray.DeepClone);
    GetCount: @TValueArray.GetCount;
    GetItem: @TValueArray.GetItem;
    SetItem: @TValueArray.SetItem;
    Add: @TValueArray.Add;
    AddRangeOpenArray: @TValueArray.AddRangeOpenArray;
    AddRangeGenArray: @TValueArray.AddRangeGenArray;
    AddRangeBsonArray: @TValueArray.AddRangeBsonArray;
    Delete: @TValueArray.Delete;
    Remove: @TValueArray.Remove;
    Clear: @TValueArray.Clear;
    Contains: @TValueArray.Contains;
    IndexOf: @TValueArray.IndexOf);

type
  TValueBinaryData = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonBinaryData._IBinaryData}
  private
    FBase: TRefCountedInterface;
    FValue: TBytes;
    FSubType: TRESTDWBsonBinarySubType;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsByteArray: TBytes;
    function AsGuid: TGUID;
    function ToGuid: TGUID;
    function ToByteArray: TBytes;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    { TRESTDWBsonBinaryData._IBinaryData }
    function GetSubType: TRESTDWBsonBinarySubType;
    function GetCount: Integer;
    function GetByte(const AIndex: Integer): Byte;
    procedure SetByte(const AIndex: Integer; const AValue: Byte);
    function GetAsBytes: TBytes;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
    function Release: Integer; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    class function Create: TRESTDWBsonBinaryData._IBinaryData; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
    class function Create(const AValue: TBytes;
      const ASubType: TRESTDWBsonBinarySubType = TRESTDWBsonBinarySubType.Binary): TRESTDWBsonBinaryData._IBinaryData; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
    class function Create(const AValue: TGUID): TRESTDWBsonBinaryData._IBinaryData; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueBinaryData = ^TValueBinaryData;

type
  TVTableValueBinaryData = Record
    Base: TVTableValue;
    GetSubType: Pointer;
    GetCount: Pointer;
    GetByte: Pointer;
    SetByte: Pointer;
    GetAsBytes: Pointer;
  end;

const
  VTABLE_BINARY_DATA: TVTableValueBinaryData = (
    Base:
     (Intf:
       (QueryInterface: @TValueBinaryData.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueBinaryData.Release);
      GetBsonType: @TValueBinaryData.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValueBinaryData.AsByteArray;
      AsGuid: @TValueBinaryData.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValueBinaryData.ToByteArray;
      ToGuid: @TValueBinaryData.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueBinaryData.Equals);
    GetSubType: @TValueBinaryData.GetSubType;
    GetCount: @TValueBinaryData.GetCount;
    GetByte: @TValueBinaryData.GetByte;
    SetByte: @TValueBinaryData.SetByte;
    GetAsBytes: @TValueBinaryData.GetAsBytes);

type
  TValueDocument = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonDocument._IDocument}
  private const
    { We use an FIndices dictionary to map names to indices.
      However, for small dictionaries it is faster and more memory efficient
      to just perform a linear search.
      So we only use the dictionary if the number of items reaches this value. }
    INDICES_COUNT_THRESHOLD = 12;
  private type
    TMapEntry = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
      HashCode: Integer;
      Name: String;
      Index: Integer;
    end;
    TMapEntries = {$IFDEF FPC}specialize {$ENDIF}TArray<TMapEntry>;
  private type
    TIndexMap = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF}
    private const
      EMPTY_HASH = -1;
    private
      FEntries: TMapEntries;
      FCount: Integer;
      FGrowThreshold: Integer;
    private
      procedure Resize(ANewSize: Integer);
    public
      procedure Release; inline;
      procedure Clear;
      procedure Add(const AName: String; const AIndex: Integer);
      function Get(const AName: String): Integer;
    end;
    PIndexMap = ^TIndexMap;
  private
    FBase: TRefCountedInterface;
    FAllowDuplicateNames: Boolean;
    FElements: TRESTDWArrayBsonElement;
    FIndices: PIndexMap;
    FCount: Integer;
  private
    procedure RebuildIndices;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
    function Clone: TRESTDWBsonValue._IValue;
    function DeepClone: TRESTDWBsonValue._IValue;
  public
    { TRESTDWBsonDocument._IDocument }
    function GetCount: Integer;
    function GetAllowDuplicateNames: Boolean;
    procedure SetAllowDuplicateNames(const AValue: Boolean);
    function GetElement(const AIndex: Integer): TRESTDWBsonElement;
    procedure GetValue(const AIndex: Integer; out AValue: TRESTDWBsonValue._IValue);
    procedure SetValue(const AIndex: Integer; const AValue: TRESTDWBsonValue._IValue);
    procedure GetValueByName(const AName: String; out AValue: TRESTDWBsonValue._IValue);
    procedure SetValueByName(const AName: String; const AValue: TRESTDWBsonValue._IValue);
    procedure Add(const AName: String; const AValue: TRESTDWBsonValue._IValue);
    procedure Get(const AName: String; const ADefault: TRESTDWBsonValue._IValue;
      out AValue: TRESTDWBsonValue._IValue);
    function IndexOfName(const AName: String): Integer;
    function Contains(const AName: String): Boolean;
    function ContainsValue(const AValue: TRESTDWBsonValue): Boolean;
    function TryGetElement(const AName: String; out AElement: TRESTDWBsonElement): Boolean;
    function TryGetValue(const AName: String; out AValue: TRESTDWBsonValue._IValue): Boolean;
    procedure Remove(const AName: String);
    procedure Delete(const AIndex: Integer);
    procedure Clear;
    procedure Merge(const AOtherDocument: TRESTDWBsonDocument;
      const AOverwriteExistingElements: Boolean);
    function ToArray: TRESTDWArrayBsonElement;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
    function Release: Integer; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    class function Create(const AAllowDuplicateNames: Boolean = False): TRESTDWBsonDocument._IDocument; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
    class function Create(const AElement: TRESTDWBsonElement): TRESTDWBsonDocument._IDocument; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
    class function Create(const AName: String; const AValue: TRESTDWBsonValue): TRESTDWBsonDocument._IDocument; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueDocument = ^TValueDocument;

type
  TVTableValueDocument = Record
    Base: TVTableValue;

    GetCount: Pointer;
    GetAllowDuplicateNames: Pointer;
    SetAllowDuplicateNames: Pointer;
    GetElement: Pointer;
    GetValue: Pointer;
    SetValue: Pointer;
    GetValueByName: Pointer;
    SetValueByName: Pointer;

    Add: Pointer;
    Get: Pointer;
    IndexOfName: Pointer;
    Contains: Pointer;
    ContainsValue: Pointer;
    TryGetElement: Pointer;
    TryGetValue: Pointer;
    Remove: Pointer;
    Delete: Pointer;
    Clear: Pointer;
    Merge: Pointer;
    ToArray: Pointer;
  end;

const
  VTABLE_DOCUMENT: TVTableValueDocument = (
    Base:
     (Intf:
       (QueryInterface: @TValueDocument.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueDocument.Release);
      GetBsonType: @TValueDocument.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueDocument.Equals;

      Clone: @TValueDocument.Clone;
      DeepClone: @TValueDocument.DeepClone);

    GetCount: @TValueDocument.GetCount;
    GetAllowDuplicateNames: @TValueDocument.GetAllowDuplicateNames;
    SetAllowDuplicateNames: @TValueDocument.SetAllowDuplicateNames;
    GetElement: @TValueDocument.GetElement;
    GetValue: @TValueDocument.GetValue;
    SetValue: @TValueDocument.SetValue;
    GetValueByName: @TValueDocument.GetValueByName;
    SetValueByName: @TValueDocument.SetValueByName;

    Add: @TValueDocument.Add;
    Get: @TValueDocument.Get;
    IndexOfName: @TValueDocument.IndexOfName;
    Contains: @TValueDocument.Contains;
    ContainsValue: @TValueDocument.ContainsValue;
    TryGetElement: @TValueDocument.TryGetElement;
    TryGetValue: @TValueDocument.TryGetValue;
    Remove: @TValueDocument.Remove;
    Delete: @TValueDocument.Delete;
    Clear: @TValueDocument.Clear;
    Merge: @TValueDocument.Merge;
    ToArray: @TValueDocument.ToArray);

type
  TValueNull = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonNull._INull}
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  end;

const
  VTABLE_NULL: TVTableValue = (
    Intf:
      (QueryInterface: @TValueNull.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueNull.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueNull.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueNull.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueNull.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.Clone);

const
  VALUE_NULL: Pointer = @VTABLE_NULL;

type
  TValueUndefined = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonUndefined._IUndefined}
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  end;

const
  VTABLE_UNDEFINED: TVTableValue = (
    Intf:
      (QueryInterface: @TValueUndefined.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueUndefined.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueUndefined.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueUndefined.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueUndefined.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.Clone);

const
  VALUE_UNDEFINED: Pointer = @VTABLE_UNDEFINED;

type
  TValueObjectId = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: TRESTDWObjectId;
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function AsObjectId: TRESTDWObjectId;
    function ToObjectId: TRESTDWObjectId;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: TRESTDWObjectId): TRESTDWBsonValue._IValue; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueObjectId = ^TValueObjectId;

const
  VTABLE_OBJECT_ID: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueObjectId.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValueObjectId.AsObjectId;

    ToBoolean: @TValue.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueObjectId.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValueObjectId.ToObjectId;

    Equals: @TValueObjectId.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueRegularExpression = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonRegularExpression._IRegularExpression}
  private
    FBase: TRefCountedInterface;
    FPattern: String;
    FOptions: String;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
    function Release: Integer; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    { TRESTDWBsonRegularExpression._IRegularExpression }
    function GetOptions: String;
    function GetPattern: String;
  public
    class function Create(const APattern: String): TRESTDWBsonRegularExpression._IRegularExpression; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
    class function Create(const APattern, AOptions: String): TRESTDWBsonRegularExpression._IRegularExpression; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueRegularExpression = ^TValueRegularExpression;

type
  TVTableValueRegularExpression = Record
    Base: TVTableValue;
    GetOptions: Pointer;
    GetPattern: Pointer;
  end;

const
  VTABLE_REGULAR_EXPRESSION: TVTableValueRegularExpression = (
    Base:
     (Intf:
       (QueryInterface: @TValueRegularExpression.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueRegularExpression.Release);
      GetBsonType: @TValueRegularExpression.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueRegularExpression.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);

    GetOptions: @TValueRegularExpression.GetOptions;
    GetPattern: @TValueRegularExpression.GetPattern);

type
  TValueJavaScript = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonJavaScript._IJavaScript}
  private
    FBase: TRefCountedInterface;
    FCode: String;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
    function Release: Integer; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    { TRESTDWBsonJavaScript._IJavaScript }
    function GetCode: String;
  public
    class function Create(const ACode: String): TRESTDWBsonJavaScript._IJavaScript; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueJavaScript = ^TValueJavaScript;

type
  TVTableValueJavaScript = Record
    Base: TVTableValue;
    GetCode: Pointer;
  end;

const
  VTABLE_JAVA_SCRIPT: TVTableValueJavaScript = (
    Base:
     (Intf:
       (QueryInterface: @TValueJavaScript.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueJavaScript.Release);
      GetBsonType: @TValueJavaScript.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueJavaScript.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);

    GetCode: @TValueJavaScript.GetCode);

type
  TValueJavaScriptWithScope = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValueJavaScript, TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope}
  private
    FBase: TValueJavaScript;
    FScope: TRESTDWBsonDocument;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
    function Release: Integer; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
    function Clone: TRESTDWBsonValue._IValue;
    function DeepClone: TRESTDWBsonValue._IValue;
  public
    { TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope }
    function GetScope: TRESTDWBsonDocument;
  public
    class function Create(const ACode: String; const AScope: TRESTDWBsonDocument): TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueJavaScriptWithScope = ^TValueJavaScriptWithScope;

type
  TVTableValueJavaScriptWithScope = Record
    Base: TVTableValueJavaScript;
    GetScope: Pointer;
  end;

const
  VTABLE_JAVA_SCRIPT_WITH_SCOPE: TVTableValueJavaScriptWithScope = (
    Base:
     (Base:
       (Intf:
         (QueryInterface: @TValueJavaScriptWithScope.QueryInterface;
          AddRef: @TRefCountedInterface.AddRef;
          Release: @TValueJavaScriptWithScope.Release);
        GetBsonType: @TValueJavaScriptWithScope.GetBsonType;
        AsBoolean: @TValue.AsBoolean;
        AsInteger: @TValue.AsInteger;
        AsInt64: @TValue.AsInt64;
        AsDouble: @TValue.AsDouble;
        AsString: @TValue.AsString;
        AsArray: @TValue.AsArray;
        AsByteArray: @TValue.AsByteArray;
        AsGuid: @TValue.AsGuid;
        AsObjectId: @TValue.AsObjectId;

        ToBoolean: @TValue.ToBoolean;
        ToDouble: @TValue.ToDouble;
        ToInteger: @TValue.ToInteger;
        ToInt64: @TValue.ToInt64;
        ToString: @TValue.ToString;
        ToLocalTime: @TValue.ToLocalTime;
        ToUniversalTime: @TValue.ToUniversalTime;
        ToByteArray: @TValue.ToByteArray;
        ToGuid: @TValue.ToGuid;
        ToObjectId: @TValue.ToObjectId;

        Equals: @TValueJavaScriptWithScope.Equals;

        Clone: @TValueJavaScriptWithScope.Clone;
        DeepClone: @TValueJavaScriptWithScope.DeepClone);

      GetCode: @TValueJavaScript.GetCode);

    GetScope: @TValueJavaScriptWithScope.GetScope);

type
  TValueSymbol = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonSymbol._ISymbol}
  private
    FBase: TRefCountedInterface;
    FName: String;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
    function Release: Integer; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
    function ToString(const ADefault: String): String;
  public
    { TRESTDWBsonSymbol._ISymbol }
    function GetName: String;
  public
    class function Create(const AName: String): TRESTDWBsonSymbol._ISymbol; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueSymbol = ^TValueSymbol;

type
  TVTableValueSymbol = Record
    Base: TVTableValue;
    GetName: Pointer;
  end;

const
  VTABLE_SYMBOL: TVTableValueSymbol = (
    Base:
     (Intf:
       (QueryInterface: @TValueSymbol.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueSymbol.Release);
      GetBsonType: @TValueSymbol.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValueSymbol.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueSymbol.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);

    GetName: @TValueSymbol.GetName);

type
  TValueTimestamp = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonTimestamp._ITimestamp}
  private
    FBase: TRefCountedInterface;
    FValue: Int64;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  public
    { TRESTDWBsonTimestamp._ITimestamp }
    function GetIncrement: Integer;
    function GetTimestamp: Integer;
    function GetValue: Int64;
  public
    class function Create(const AValue: Int64): TRESTDWBsonTimestamp._ITimestamp; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
    class function Create(const ATimestamp, AIncrement: Integer): TRESTDWBsonTimestamp._ITimestamp; overload; inline; {$IFNDEF FPC}static;{$ENDIF}
  end;
  PValueTimestamp = ^TValueTimestamp;

type
  TVTableValueTimestamp = Record
    Base: TVTableValue;
    GetIncrement: Pointer;
    GetTimestamp: Pointer;
    GetValue: Pointer;
  end;

const
  VTABLE_TIMESTAMP: TVTableValueTimestamp = (
    Base:
     (Intf:
       (QueryInterface: @TValueTimestamp.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TRefCountedInterface.Release);
      GetBsonType: @TValueTimestamp.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueTimestamp.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);

    GetIncrement: @TValueTimestamp.GetIncrement;
    GetTimestamp: @TValueTimestamp.GetTimestamp;
    GetValue: @TValueTimestamp.GetValue);

type
  TValueMaxKey = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonMaxKey._IMaxKey}
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  end;

const
  VTABLE_MAX_KEY: TVTableValue = (
    Intf:
      (QueryInterface: @TValueMaxKey.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueMaxKey.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValue.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueMaxKey.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueMaxKey.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.Clone);

const
  VALUE_MAX_KEY: Pointer = @VTABLE_MAX_KEY;

type
  TValueMinKey = {$IFNDEF FPC}Record{$ELSE}Class{$ENDIF} {TValue, TRESTDWBsonMinKey._IMinKey}
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {$IFNDEF FPC}stdcall;{$ENDIF}
  public
    { TRESTDWBsonValue._IValue }
    function GetBsonType: TRESTDWBsonType;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
  end;

const
  VTABLE_MIN_KEY: TVTableValue = (
    Intf:
      (QueryInterface: @TValueMinKey.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueMinKey.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValue.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueMinKey.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueMinKey.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.Clone);

const
  VALUE_MIN_KEY: Pointer = @VTABLE_MIN_KEY;

function _goBsonValueFromDouble(const AValue: Double): TRESTDWBsonValue._IValue;
begin
  if (not AValue.IsNan) and (AValue = 0) then
    Result := TValueDoubleZero.FValue
  else
    Result := TValueDouble.Create(AValue);
end;

function _goBsonValueFromString(const AValue: String): TRESTDWBsonValue._IValue;
begin
  if (AValue = '') then
    Result := TValueStringEmpty.FValue
  else if (StringRefCount(AValue) < 0) then
    Result := TValueStringConstant.Create(AValue)
  else
    Result := TValueString.Create(AValue);
end;

function _goBsonValueFromObjectId(const AValue: TRESTDWObjectId): TRESTDWBsonValue._IValue;
begin
  Result := TValueObjectId.Create(AValue);
end;

function _goBsonValueFromBoolean(const AValue: Boolean): TRESTDWBsonValue._IValue;
begin
  if (AValue) then
    Result := TValueTrue.FValue
  else
    Result := TValueFalse.FValue;
end;

function _goBsonValueFromDateTime(const AValue: Int64): TRESTDWBsonValue._IValue;
begin
  Result := TValueDateTime.Create(AValue);
end;

function _goBsonValueFromInt32(const AValue: Int32): TRESTDWBsonValue._IValue;
begin
  if (AValue >= TValueIntegerConst.MIN_PRECREATED_VALUE) and (AValue <= TValueIntegerConst.MAX_PRECREATED_VALUE) then
    Result := TValueIntegerConst.FPrecreatedValues[AValue]
  else
    Result := TValueInteger.Create(AValue);
end;

function _goBsonValueFromInt64(const AValue: Int64): TRESTDWBsonValue._IValue;
begin
  if (AValue >= TValueInt64Const.MIN_PRECREATED_VALUE) and (AValue <= TValueInt64Const.MAX_PRECREATED_VALUE) then
    Result := TValueInt64Const.FPrecreatedValues[AValue]
  else
    Result := TValueInt64.Create(AValue);
end;

function _goCreateArray: TRESTDWBsonArray._IArray;
begin
  Result := TValueArray.Create;
end;

function _goCreateDocument: TRESTDWBsonDocument._IDocument;
begin
  Result := TValueDocument.Create;
end;

procedure _goGetBinaryData(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonBinaryData);
begin
  ASrc.QueryInterface(TRESTDWBsonBinaryData._IBinaryData, ADst.FImpl);
end;

procedure _goGetDateTime(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonDateTime);
begin
  ASrc.QueryInterface(TRESTDWBsonDateTime._IDateTime, ADst.FImpl);
end;

procedure _goGetRegularExpression(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonRegularExpression);
begin
  ASrc.QueryInterface(TRESTDWBsonRegularExpression._IRegularExpression, ADst.FImpl);
end;

procedure _goGetJavaScript(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonJavaScript);
begin
  ASrc.QueryInterface(TRESTDWBsonJavaScript._IJavaScript, ADst.FImpl);
end;

procedure _goGetJavaScriptWithScope(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonJavaScriptWithScope);
begin
  ASrc.QueryInterface(TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope, ADst.FImpl);
end;

procedure _goGetSymbol(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonSymbol);
begin
  ASrc.QueryInterface(TRESTDWBsonSymbol._ISymbol, ADst.FImpl);
end;

procedure _goGetTimestamp(const ASrc: TRESTDWBsonValue._IValue;
  out ADst: TRESTDWBsonTimestamp);
begin
  ASrc.QueryInterface(TRESTDWBsonTimestamp._ITimestamp, ADst.FImpl);
end;

{ TRESTDWJsonWriterSettings }

{$IFNDEF FPC}Class {$ENDIF}constructor TRESTDWJsonWriterSettings.Create;
begin
  {$IFDEF FPC}FDefault := TRESTDWJsonWriterSettings.Create;{$ENDIF}
  FShell := TRESTDWJsonWriterSettings.aCreate(TRESTDWJsonOutputMode.Shell);
  FPretty := TRESTDWJsonWriterSettings.aCreate('  ', #13#10, TRESTDWJsonOutputMode.Strict);
end;

Class function TRESTDWJsonWriterSettings.aCreate: TRESTDWJsonWriterSettings;
begin
 {$IFDEF FPC}Create;{$ENDIF}
 Result.FPrettyPrint := False;
 Result.FIndent := '  ';
 Result.FLineBreak := #13#10;
 Result.FOutputMode := TRESTDWJsonOutputMode.Strict;
end;

Class function TRESTDWJsonWriterSettings.aCreate(const AIndent, ALineBreak: String;
  const AOutputMode: TRESTDWJsonOutputMode): TRESTDWJsonWriterSettings;
begin
 {$IFDEF FPC}Create;{$ENDIF}
 Result.FPrettyPrint := True;
  Result.FIndent := AIndent;
  Result.FLineBreak := ALineBreak;
  Result.FOutputMode := AOutputMode;
end;

Class function TRESTDWJsonWriterSettings.aCreate(const AOutputMode: TRESTDWJsonOutputMode): TRESTDWJsonWriterSettings;
begin
 {$IFDEF FPC}Create;{$ENDIF}
 Result.FPrettyPrint := False;
 Result.FIndent := '  ';
 Result.FLineBreak := #13#10;
 Result.FOutputMode := AOutputMode;
end;

Class function TRESTDWJsonWriterSettings.aCreate(const APrettyPrint: Boolean;
  const AOutputMode: TRESTDWJsonOutputMode): TRESTDWJsonWriterSettings;
begin
 {$IFDEF FPC}Create;{$ENDIF}
 Result.FPrettyPrint := APrettyPrint;
 Result.FIndent := '  ';
 Result.FLineBreak := #13#10;
 Result.FOutputMode := AOutputMode;
end;

{ TRESTDWObjectId }

class function TRESTDWObjectId.Create(const ABytes: TBytes): TRESTDWObjectId;
begin
  if (Length(ABytes) <> 12) then
    EArgumentException.CreateRes(@sArgumentInvalid);
  Result.FromByteArray(ABytes);
end;

class function TRESTDWObjectId.Create(const ABytes: array of Byte): TRESTDWObjectId;
var
  Bytes: TBytes;
begin
  if (Length(ABytes) <> 12) then
    EArgumentException.CreateRes(@sArgumentInvalid);
  SetLength(Bytes, 12);
  Move(ABytes[0], Bytes[0], 12);
  Result := Create(Bytes);
end;

class function TRESTDWObjectId.Create(const ATimestamp, AMachine: Integer;
  const APid: UInt16; const AIncrement: Integer): TRESTDWObjectId;
begin
  if ((AMachine and $FF000000) <> 0) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  if ((AIncrement and $FF000000) <> 0) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  Result.FData[0] := UInt32(ATimestamp);
  Result.FData[1] := UInt32((AMachine shl 8) or (APid shr 8));
  Result.FData[2] := UInt32((APid shl 24) or AIncrement);
end;

procedure TRESTDWObjectId.FromByteArray(const ABytes: TBytes);
begin
  FBytes[00] := ABytes[03];
  FBytes[01] := ABytes[02];
  FBytes[02] := ABytes[01];
  FBytes[03] := ABytes[00];
  FBytes[04] := ABytes[07];
  FBytes[05] := ABytes[06];
  FBytes[06] := ABytes[05];
  FBytes[07] := ABytes[04];
  FBytes[08] := ABytes[11];
  FBytes[09] := ABytes[10];
  FBytes[10] := ABytes[09];
  FBytes[11] := ABytes[08];
end;

class function TRESTDWObjectId.GenerateNewId: TRESTDWObjectId;
begin
  Result := GenerateNewId(GetTimestampFromDateTime(Now, False));
end;

class function TRESTDWObjectId.GenerateNewId(const ATimestamp: TDateTime;
  const ATimestampIsUTC: Boolean): TRESTDWObjectId;
begin
  Result := GenerateNewId(GetTimestampFromDateTime(ATimestamp, ATimestampIsUTC));
end;

{$IFDEF FPC}
Function AtomicIncrement(Var A : Integer) : Integer;
Begin
 Inc(A);
 Result := A;
End;
Function AtomicDecrement(Var A : Integer) : Integer;
Begin
 Dec(A);
 Result := A;
End;
{$ENDIF}

class function TRESTDWObjectId.GenerateNewId(
  const ATimestamp: Integer): TRESTDWObjectId;
var
  aIncrement: Integer;
begin
  if (not FInitialized) then
    Initialize;

  aIncrement := AtomicIncrement(FIncrement) and $00FFFFFF;
  Result := TRESTDWObjectId.Create(ATimestamp, FMachine, FPid, aIncrement);
end;

function TRESTDWObjectId.GetCreationTime: TDateTime;
begin
  Result := IncSecond(UnixDateDelta, Timestamp);
end;

function TRESTDWObjectId.GetIncrement: Integer;
begin
  Result := FData[2] and $FFFFFF;
end;

function TRESTDWObjectId.GetIsEmpty: Boolean;
begin
  Result := (FData[0] = 0) and (FData[1] = 0) and (FData[2] = 0);
end;

function TRESTDWObjectId.GetMachine: Integer;
begin
  Result := FData[1] shr 8;
end;

function TRESTDWObjectId.GetPid: UInt16;
begin
  Result := UInt16((FData[1] shl 8) or (FData[2] shr 24));
end;

function TRESTDWObjectId.GetTimestamp: Integer;
begin
  Result := Int32(FData[0]);
end;

class function TRESTDWObjectId.GetTimestampFromDateTime(
  const ATimestamp: TDateTime; const ATimestampIsUTC: Boolean): Integer;
var
  DateTime: TDateTime;
  SecondsSinceEpoch: Int64;
begin
  if (ATimestampIsUTC) then
    DateTime := ATimestamp
  else
   {$IFNDEF FPC}
    DateTime := TTimeZone.Local.ToUniversalTime(ATimestamp);
   {$ELSE}
    DateTime := LocalTimeToUniversal(ATimestamp);
   {$ENDIF}
  SecondsSinceEpoch := SecondsBetween(DateTime, UnixDateDelta);
  if (DateTime < UnixDateDelta) then
    SecondsSinceEpoch := -SecondsSinceEpoch;

  if (SecondsSinceEpoch < Integer.MinValue) or (SecondsSinceEpoch > Integer.MaxValue) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  Result := SecondsSinceEpoch;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWObjectId.GreaterThan(const A,
  B: TRESTDWObjectId): Boolean;
begin
  Result := (A.CompareTo(B) > 0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWObjectId.GreaterThanOrEqual(const A,
  B: TRESTDWObjectId): Boolean;
begin
  Result := (A.CompareTo(B) >= 0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWObjectId.Implicit(const A: String): TRESTDWObjectId;
begin
  Result := TRESTDWObjectId.Create(A);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWObjectId.Implicit(const A: TRESTDWObjectId): String;
begin
  Result := A.ToString;
end;

class procedure TRESTDWObjectId.Initialize;
var
  MachineName: String;
begin
  FIncrement := Random($1000000);

  MachineName := goGetMachineName;
  FMachine := goMurmurHash2(MachineName[Low(String)], Length(MachineName) * SizeOf(Char)) and $00FFFFFF;
  FPid := goGetCurrentProcessId;

  FInitialized := True;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWObjectId.LessThan(const A, B: TRESTDWObjectId): Boolean;
begin
  Result := (A.CompareTo(B) < 0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWObjectId.LessThanOrEqual(const A,
  B: TRESTDWObjectId): Boolean;
begin
  Result := (A.CompareTo(B) <= 0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWObjectId.NotEqual(const A, B: TRESTDWObjectId): Boolean;
begin
  Result := (A.FData[0] <> B.FData[0])
         or (A.FData[1] <> B.FData[1])
         or (A.FData[2] <> B.FData[2])
end;

class function TRESTDWObjectId.Parse(const AString: String): TRESTDWObjectId;
begin
  Result := TRESTDWObjectId.Create(AString);
end;

function TRESTDWObjectId.ToByteArray: TBytes;
begin
  SetLength(Result, 12);
  ToByteArray(Result, 0);
end;

procedure TRESTDWObjectId.ToByteArray(const ADestination: TBytes;
  const AOffset: Integer);
begin
  if ((AOffset + 12) > Length(ADestination)) then
    EArgumentException.Create('Not enough room in ADestination');

  ADestination[AOffset + 00] := FBytes[03];
  ADestination[AOffset + 01] := FBytes[02];
  ADestination[AOffset + 02] := FBytes[01];
  ADestination[AOffset + 03] := FBytes[00];
  ADestination[AOffset + 04] := FBytes[07];
  ADestination[AOffset + 05] := FBytes[06];
  ADestination[AOffset + 06] := FBytes[05];
  ADestination[AOffset + 07] := FBytes[04];
  ADestination[AOffset + 08] := FBytes[11];
  ADestination[AOffset + 09] := FBytes[10];
  ADestination[AOffset + 10] := FBytes[09];
  ADestination[AOffset + 11] := FBytes[08];
end;

function TRESTDWObjectId.ToString: String;
begin
  Result := goToHexString(ToByteArray);
end;

class function TRESTDWObjectId.TryParse(const AString: String;
  out AObjectId: TRESTDWObjectId): Boolean;
var
  Bytes: TBytes;
begin
  Result := (Length(AString) = 24) and goTryParseHexString(AString, Bytes);
  if (Result) then
    AObjectId := TRESTDWObjectId.Create(Bytes)
  else
    AObjectId := Default(TRESTDWObjectId);
end;

class function TRESTDWObjectId.Create(const ATimestamp: TDateTime;
  const ATimestampIsUTC: Boolean; const AMachine: Integer; const APid: UInt16;
  const AIncrement: Integer): TRESTDWObjectId;
begin
  Result := Create(GetTimestampFromDateTime(ATimestamp, ATimestampIsUTC),
    AMachine, APId, AIncrement);
end;

class function TRESTDWObjectId.Create(const AString: String): TRESTDWObjectId;
var
  Bytes: TBytes;
begin
  if (Length(AString) <> 24) then
    raise EArgumentException.CreateRes(@SArgumentOutOfRange);
  Bytes := goParseHexString(AString);
  Result.FromByteArray(Bytes);
end;

function TRESTDWObjectId.CompareTo(const AOther: TRESTDWObjectId): Integer;
begin
  if (FData[0] < AOther.FData[0]) then
    Exit(-1);
  if (FData[0] > AOther.FData[0]) then
    Exit(1);

  if (FData[1] < AOther.FData[1]) then
    Exit(-1);
  if (FData[1] > AOther.FData[1]) then
    Exit(1);

  if (FData[2] < AOther.FData[2]) then
    Exit(-1);
  if (FData[2] > AOther.FData[2]) then
    Exit(1);

  Result := 0;
end;

class function TRESTDWObjectId.Empty: TRESTDWObjectId;
begin
  FillChar(Result, SizeOf(Result), 0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWObjectId.Equal(const A, B: TRESTDWObjectId): Boolean;
begin
  Result := (A.FData[0] = B.FData[0])
        and (A.FData[1] = B.FData[1])
        and (A.FData[2] = B.FData[2])
end;

class constructor TRESTDWObjectId.Create;
begin
  FInitialized := False;
end;

{ TRESTDWBsonValue }

function TRESTDWBsonValue.AsArray: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF};
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsArray;
end;

function TRESTDWBsonValue.AsBoolean: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsBoolean;
end;

function TRESTDWBsonValue.AsByteArray: TBytes;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsByteArray;
end;

function TRESTDWBsonValue.AsDouble: Double;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsDouble;
end;

function TRESTDWBsonValue.AsGuid: TGUID;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsGuid;
end;

function TRESTDWBsonValue.AsInt64: Int64;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsInt64;
end;

function TRESTDWBsonValue.AsInteger: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsInteger;
end;

function TRESTDWBsonValue.AsObjectId: TRESTDWObjectId;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsObjectId;
end;

function TRESTDWBsonValue.AsString: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsString;
end;

function TRESTDWBsonValue.Clone: TRESTDWBsonValue;
begin
  Assert(Assigned(FImpl));
  Result.FImpl := FImpl.Clone;
end;

function TRESTDWBsonValue.DeepClone: TRESTDWBsonValue;
begin
  Assert(Assigned(FImpl));
  Result.FImpl := FImpl.DeepClone;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Equal(const A, B: TRESTDWBsonValue): Boolean;
begin
  if (A.FImpl = nil) then
    Result := (B.FImpl = nil)
  else if (B.FImpl = nil) then
    Result := False
  else
    Result := A.FImpl.Equals(B.FImpl);
end;

function TRESTDWBsonValue.GetBsonType: TRESTDWBsonType;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.BsonType;
end;

function TRESTDWBsonValue.GetIsBoolean: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Boolean);
end;

function TRESTDWBsonValue.GetIsBsonArray: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.&Array);
end;

function TRESTDWBsonValue.GetIsBsonBinaryData: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Binary);
end;

function TRESTDWBsonValue.GetIsBsonDateTime: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.DateTime);
end;

function TRESTDWBsonValue.GetIsBsonDocument: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Document);
end;

function TRESTDWBsonValue.GetIsBsonJavaScript: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType in [TRESTDWBsonType.JavaScript, TRESTDWBsonType.JavaScriptWithScope]);
end;

function TRESTDWBsonValue.GetIsBsonJavaScriptWithScope: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.JavaScriptWithScope);
end;

function TRESTDWBsonValue.GetIsBsonMaxKey: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.MaxKey);
end;

function TRESTDWBsonValue.GetIsBsonMinKey: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.MinKey);
end;

function TRESTDWBsonValue.GetIsBsonNull: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Null);
end;

function TRESTDWBsonValue.GetIsBsonRegularExpression: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.RegularExpression);
end;

function TRESTDWBsonValue.GetIsBsonSymbol: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Symbol);
end;

function TRESTDWBsonValue.GetIsBsonTimestamp: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Timestamp);
end;

function TRESTDWBsonValue.GetIsBsonUndefined: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Undefined);
end;

function TRESTDWBsonValue.GetIsDateTime: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.DateTime);
end;

function TRESTDWBsonValue.GetIsDouble: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Double);
end;

function TRESTDWBsonValue.GetIsGuid: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Binary)
    and (AsBsonBinaryData.SubType in [TRESTDWBsonBinarySubType.UuidLegacy, TRESTDWBsonBinarySubType.UuidStandard]);
end;

function TRESTDWBsonValue.GetIsInt32: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Int32);
end;

function TRESTDWBsonValue.GetIsInt64: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.Int64);
end;

function TRESTDWBsonValue.GetIsNumeric: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType in [TRESTDWBsonType.Int32, TRESTDWBsonType.Int64, TRESTDWBsonType.Double]);
end;

function TRESTDWBsonValue.GetIsObjectId: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.ObjectId);
end;

function TRESTDWBsonValue.GetIsString: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TRESTDWBsonType.&String);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): Int64;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInt64(0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): Double;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToDouble(0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): Boolean;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToBoolean(False);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): Integer;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

{$IFNDEF FPC}class operator TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): Extended;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToDouble(0);
end;
{$ENDIF}

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): TBytes;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToByteArray;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): TGUID;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToGuid;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): TDateTime;
begin
  Assert(Assigned(A.FImpl));
  Result := A.ToUniversalTime;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): String;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToString('');
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): TRESTDWObjectId;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToObjectId;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): Single;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToDouble(0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: Single): TRESTDWBsonValue;
begin
  if (not A.IsNan) and (A = 0) then
    Result.FImpl := TValueDoubleZero.FValue
  else
    Result.FImpl := TValueDouble.Create(A);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): UInt32;
begin
  Assert(Assigned(A.FImpl));
  Result := UInt32(A.FImpl.ToInteger(0));
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: UInt32): TRESTDWBsonValue;
begin
  if (A <= TValueIntegerConst.MAX_PRECREATED_VALUE) then
    Result.FImpl := TValueIntegerConst.FPrecreatedValues[A]
  else
    Result.FImpl := TValueInteger.Create(Int32(A));
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): UInt16;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): Int16;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): UInt8;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): Int8;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: UInt64): TRESTDWBsonValue;
begin
  if (A <= TValueInt64Const.MAX_PRECREATED_VALUE) then
    Result.FImpl := TValueInt64Const.FPrecreatedValues[A]
  else
    Result.FImpl := TValueInt64.Create(A);
end;

//class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWBsonValue): UInt64;
//begin
//  Assert(Assigned(A.FImpl));
//  Result := UInt64(A.FImpl.ToInt64(0));
//end;

function TRESTDWBsonValue.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class function TRESTDWBsonValue.Load(const ABson: TBytes): TRESTDWBsonValue;
var
  Reader: IgoBsonReader;
begin
  Reader := TRESTDWBsonReader.Create(ABson);
  Result := Reader.ReadValue;
end;

class function TRESTDWBsonValue.LoadFromBsonFile(
  const AFilename: String): TRESTDWBsonValue;
var
  Reader: IgoBsonReader;
begin
  Reader := TRESTDWBsonReader.Load(AFilename);
  Result := Reader.ReadValue;
end;

class function TRESTDWBsonValue.LoadFromBsonStream(
  const AStream: TStream): TRESTDWBsonValue;
var
  Reader: IgoBsonReader;
begin
  Reader := TRESTDWBsonReader.Load(AStream);
  Result := Reader.ReadValue;
end;

class function TRESTDWBsonValue.LoadFromJsonFile(
  const AFilename: String): TRESTDWBsonValue;
var
  Reader: IgoJsonReader;
begin
  Reader := TRESTDWJsonReader.Load(AFilename);
  Result := Reader.ReadValue;
end;

class function TRESTDWBsonValue.LoadFromJsonStream(
  const AStream: TStream): TRESTDWBsonValue;
var
  Reader: IgoJsonReader;
begin
  Reader := TRESTDWJsonReader.Load(AStream);
  Result := Reader.ReadValue;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: Boolean): TRESTDWBsonValue;
begin
  if (A) then
    Result.FImpl := TValueTrue.FValue
  else
    Result.FImpl := TValueFalse.FValue;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: Double): TRESTDWBsonValue;
begin
  if (not A.IsNan) and (A = 0) then
    Result.FImpl := TValueDoubleZero.FValue
  else
    Result.FImpl := TValueDouble.Create(A);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: Integer): TRESTDWBsonValue;
begin
  if (A >= TValueIntegerConst.MIN_PRECREATED_VALUE) and (A <= TValueIntegerConst.MAX_PRECREATED_VALUE) then
    Result.FImpl := TValueIntegerConst.FPrecreatedValues[A]
  else
    Result.FImpl := TValueInteger.Create(A);
end;

//class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: Int64): TRESTDWBsonValue;
//begin
//  if (A >= TValueInt64Const.MIN_PRECREATED_VALUE) and (A <= TValueInt64Const.MAX_PRECREATED_VALUE) then
//    Result.FImpl := TValueInt64Const.FPrecreatedValues[A]
//  else
//    Result.FImpl := TValueInt64.Create(A);
//end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: String): TRESTDWBsonValue;
begin
  if (A = '') then
    Result.FImpl := TValueStringEmpty.FValue
  else if (StringRefCount(A) < 0) then
    Result.FImpl := TValueStringConstant.Create(A)
  else
    Result.FImpl := TValueString.Create(A);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TBytes): TRESTDWBsonValue;
begin
  Result.FImpl := TValueBinaryData.Create(A);
end;

{$IFNDEF FPC}class operator TRESTDWBsonValue.Implicit(const A: Extended): TRESTDWBsonValue;
var
  D: Double;
begin
  D := A;
  Result := D;
end;
{$ENDIF}

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TDateTime): TRESTDWBsonValue;
begin
  Result.FImpl := TValueDateTime.Create(A, True);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TGUID): TRESTDWBsonValue;
begin
  Result.FImpl := TValueBinaryData.Create(A);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.Implicit(const A: TRESTDWObjectId): TRESTDWBsonValue;
begin
  Result.FImpl := TValueObjectId.Create(A);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonValue.NotEqual(const A, B: TRESTDWBsonValue): Boolean;
begin
  Result := not (A = B);
end;

class function TRESTDWBsonValue.Parse(const AJson: String): TRESTDWBsonValue;
var
  Reader: IgoJsonReader;
begin
  Reader := TRESTDWJsonReader.Create(AJson);
  Result := Reader.ReadValue;
end;

procedure TRESTDWBsonValue.SaveToBsonFile(const AFilename: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToBsonStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TRESTDWBsonValue.SaveToBsonStream(const AStream: TStream);
var
  Bson: TBytes;
begin
  Bson := ToBson;
  AStream.Write(Bson, Length(Bson));
end;

procedure TRESTDWBsonValue.SaveToJsonFile(const AFilename: String;
  const ASettings: TRESTDWJsonWriterSettings);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToJsonStream(Stream, ASettings);
  finally
    Stream.Free;
  end;
end;

procedure TRESTDWBsonValue.SaveToJsonFile(const AFilename: String);
begin
  SaveToJsonFile(AFilename, TRESTDWJsonWriterSettings.Default);
end;

procedure TRESTDWBsonValue.SaveToJsonStream(const AStream: TStream);
begin
  SaveToJsonStream(AStream, TRESTDWJsonWriterSettings.Default);
end;

Procedure StreamWWrite(Const aLine   : String;
                       Const AStream : TStream);
Var
 fBytesData : TRESTDWBytes;
Begin
 fBytesData := StringToBytes(aLine);
 AStream.Write(fBytesData, Length(fBytesData));
End;

procedure TRESTDWBsonValue.SaveToJsonStream(const AStream: TStream;
  const ASettings: TRESTDWJsonWriterSettings);
var
 Json : String;
begin
  Json := ToJson(ASettings);
  StreamWWrite(Json, AStream);
end;

procedure TRESTDWBsonValue.SetNil;
begin
  FImpl := nil;
end;

function TRESTDWBsonValue.ToJson: String;
begin
  Result := ToJson(TRESTDWJsonWriterSettings.Default);
end;

function TRESTDWBsonValue.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToBoolean(ADefault);
end;

function TRESTDWBsonValue.ToBson: TBytes;
var
  Writer: IgoBsonWriter;
begin
  Assert(Assigned(FImpl));
  Writer := TRESTDWBsonWriter.Create;
  Writer.WriteValue(Self);
  Result := Writer.ToBson;
end;

function TRESTDWBsonValue.ToDouble(const ADefault: Double): Double;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToDouble(ADefault);
end;

function TRESTDWBsonValue.ToGuid: TGUID;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToGuid;
end;

function TRESTDWBsonValue.ToInt64(const ADefault: Int64): Int64;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToInt64(ADefault);
end;

function TRESTDWBsonValue.ToInteger(const ADefault: Integer): Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToInteger(ADefault);
end;

function TRESTDWBsonValue.ToJson(const ASettings: TRESTDWJsonWriterSettings): String;
var
  Writer: IgoJsonWriter;
begin
  Assert(Assigned(FImpl));
  Writer := TRESTDWJsonWriter.Create(ASettings);
  Writer.WriteValue(Self);
  Result := Writer.ToJson;
end;

function TRESTDWBsonValue.ToLocalTime: TDateTime;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToLocalTime;
end;

function TRESTDWBsonValue.ToObjectId: TRESTDWObjectId;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToObjectId;
end;

function TRESTDWBsonValue.ToString(const ADefault: String): String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToString(ADefault);
end;

function TRESTDWBsonValue.ToUniversalTime: TDateTime;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToUniversalTime;
end;

class function TRESTDWBsonValue.TryLoad(const ABson: TBytes;
  out AValue: TRESTDWBsonValue): Boolean;
var
  Reader: IgoBsonReader;
begin
  try
    Reader := TRESTDWBsonReader.Create(ABson);
    AValue := Reader.ReadValue;
    Result := True;
  except
    AValue.FImpl := nil;
    Result := False;
  end;
end;

class function TRESTDWBsonValue.TryParse(const AJson: String;
  out AValue: TRESTDWBsonValue): Boolean;
var
  Reader: IgoJsonReader;
begin
  try
    Reader := TRESTDWJsonReader.Create(AJson);
    AValue := Reader.ReadValue;
    Result := True;
  except
    AValue.FImpl := nil;
    Result := False;
  end;
end;

{ TRESTDWBsonValueHelper }

function TRESTDWBsonValueHelper.AsBsonBinaryData: TRESTDWBsonBinaryData;
begin
  if (FImpl.QueryInterface(TRESTDWBsonBinaryData._IBinaryData, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonBinaryData)');
end;

function TRESTDWBsonValueHelper.AsBsonArray: TRESTDWBsonArray;
begin
  if (FImpl.QueryInterface(TRESTDWBsonArray._IArray, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonArray)');
end;

function TRESTDWBsonValueHelper.AsBsonDateTime: TRESTDWBsonDateTime;
begin
  if (FImpl.QueryInterface(TRESTDWBsonDateTime._IDateTime, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonDateTime)');
end;

function TRESTDWBsonValueHelper.AsBsonDocument: TRESTDWBsonDocument;
begin
  if (FImpl.QueryInterface(TRESTDWBsonDocument._IDocument, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonDocument)');
end;

function TRESTDWBsonValueHelper.AsBsonJavaScript: TRESTDWBsonJavaScript;
begin
  if (FImpl.QueryInterface(TRESTDWBsonJavaScript._IJavaScript, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonJavaScript)');
end;

function TRESTDWBsonValueHelper.AsBsonJavaScriptWithScope: TRESTDWBsonJavaScriptWithScope;
begin
  if (FImpl.QueryInterface(TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonJavaScriptWithScope)');
end;

function TRESTDWBsonValueHelper.AsBsonMaxKey: TRESTDWBsonMaxKey;
begin
  if (FImpl.QueryInterface(TRESTDWBsonMaxKey._IMaxKey, Result.FValue) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonMaxKey)');
end;

function TRESTDWBsonValueHelper.AsBsonMinKey: TRESTDWBsonMinKey;
begin
  if (FImpl.QueryInterface(TRESTDWBsonMinKey._IMinKey, Result.FValue) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonMinKey)');
end;

function TRESTDWBsonValueHelper.AsBsonNull: TRESTDWBsonNull;
begin
  if (FImpl.QueryInterface(TRESTDWBsonNull._INull, Result.FValue) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonNull)');
end;

function TRESTDWBsonValueHelper.AsBsonRegularExpression: TRESTDWBsonRegularExpression;
begin
  if (FImpl.QueryInterface(TRESTDWBsonRegularExpression._IRegularExpression, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonRegularExpression)');
end;

function TRESTDWBsonValueHelper.AsBsonSymbol: TRESTDWBsonSymbol;
begin
  if (FImpl.QueryInterface(TRESTDWBsonSymbol._ISymbol, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonSymbol)');
end;

function TRESTDWBsonValueHelper.AsBsonTimestamp: TRESTDWBsonTimestamp;
begin
  if (FImpl.QueryInterface(TRESTDWBsonTimestamp._ITimestamp, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonTimestamp)');
end;

function TRESTDWBsonValueHelper.AsBsonUndefined: TRESTDWBsonUndefined;
begin
  if (FImpl.QueryInterface(TRESTDWBsonUndefined._IUndefined, Result.FValue) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonValue.AsBsonUndefined)');
end;

function TRESTDWBsonValueHelper.ToBsonArray: TRESTDWBsonArray;
begin
  if (FImpl.QueryInterface(TRESTDWBsonArray._IArray, Result.FImpl) <> S_OK) then
    Result := TRESTDWBsonArray.Create;
end;

function TRESTDWBsonValueHelper.ToBsonDocument: TRESTDWBsonDocument;
begin
  if (FImpl.QueryInterface(TRESTDWBsonDocument._IDocument, Result.FImpl) <> S_OK) then
    Result := TRESTDWBsonDocument.Create;
end;

{ TRESTDWBsonArray }

function TRESTDWBsonArray.Add(const AValue: TRESTDWBsonValue): TRESTDWBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.Add(AValue.FImpl);
  Result.FImpl := FImpl;
end;

function TRESTDWBsonArray.AddRange(
  const AValues: array of TRESTDWBsonValue): TRESTDWBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.AddRange(AValues);
  Result.FImpl := FImpl;
end;

function TRESTDWBsonArray.AddRange(
  const AValues: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}): TRESTDWBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.AddRange(AValues);
  Result.FImpl := FImpl;
end;

function TRESTDWBsonArray.AddRange(const AValues: TRESTDWBsonArray): TRESTDWBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.AddRange(AValues);
  Result.FImpl := FImpl;
end;

class function TRESTDWBsonArray.Create(const ACapacity: Integer): TRESTDWBsonArray;
begin
  Result.FImpl := TValueArray.Create(ACapacity);
end;

class function TRESTDWBsonArray.Create(const AValues: array of TRESTDWBsonValue): TRESTDWBsonArray;
begin
  Result.FImpl := TValueArray.Create(AValues);
end;

function TRESTDWBsonArray.Clear: TRESTDWBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.Clear;
  Result.FImpl := FImpl;
end;

function TRESTDWBsonArray.Clone: TRESTDWBsonArray;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TRESTDWBsonArray._IArray, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonArray.Clone)');
end;

function TRESTDWBsonArray.Contains(const AValue: TRESTDWBsonValue): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Contains(AValue);
end;

class function TRESTDWBsonArray.Create(const AValues: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}): TRESTDWBsonArray;
begin
  Result.FImpl := TValueArray.Create(AValues);
end;

function TRESTDWBsonArray.DeepClone: TRESTDWBsonArray;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TRESTDWBsonArray._IArray, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonArray.DeepClone)');
end;

procedure TRESTDWBsonArray.Delete(const AIndex: Integer);
begin
  Assert(Assigned(FImpl));
  FImpl.Delete(AIndex);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonArray.Equal(const A, B: TRESTDWBsonArray): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

function TRESTDWBsonArray.GetCount: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Count;
end;

function TRESTDWBsonArray.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(FImpl);
end;

function TRESTDWBsonArray.GetItem(const AIndex: Integer): TRESTDWBsonValue;
begin
  FImpl.GetItem(AIndex, Result.FImpl);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonArray.Implicit(const A: TRESTDWBsonArray): TRESTDWBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TRESTDWBsonArray.IndexOf(const AValue: TRESTDWBsonValue): Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.IndexOf(AValue);
end;

function TRESTDWBsonArray.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class function TRESTDWBsonArray.Load(const ABson: TBytes): TRESTDWBsonArray;
var
  Reader: IgoBsonReader;
begin
  Reader := TRESTDWBsonReader.Create(ABson);
  Result := Reader.ReadArray;
end;

class function TRESTDWBsonArray.LoadFromBsonFile(
  const AFilename: String): TRESTDWBsonArray;
var
  Reader: IgoBsonReader;
begin
  Reader := TRESTDWBsonReader.Load(AFilename);
  Result := Reader.ReadArray;
end;

class function TRESTDWBsonArray.LoadFromBsonStream(
  const AStream: TStream): TRESTDWBsonArray;
var
  Reader: IgoBsonReader;
begin
  Reader := TRESTDWBsonReader.Load(AStream);
  Result := Reader.ReadArray;
end;

class function TRESTDWBsonArray.LoadFromJsonFile(
  const AFilename: String): TRESTDWBsonArray;
var
  Reader: IgoJsonReader;
begin
  Reader := TRESTDWJsonReader.Load(AFilename);
  Result := Reader.ReadArray;
end;

class function TRESTDWBsonArray.LoadFromJsonStream(
  const AStream: TStream): TRESTDWBsonArray;
var
  Reader: IgoJsonReader;
begin
  Reader := TRESTDWJsonReader.Load(AStream);
  Result := Reader.ReadArray;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonArray.NotEqual(const A, B: TRESTDWBsonArray): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

class function TRESTDWBsonArray.Parse(const AJson: String): TRESTDWBsonArray;
var
  Reader: IgoJsonReader;
begin
  Reader := TRESTDWJsonReader.Create(AJson);
  Result := Reader.ReadArray;
end;

function TRESTDWBsonArray.Remove(const AValue: TRESTDWBsonValue): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Remove(AValue);
end;

procedure TRESTDWBsonArray.SaveToBsonFile(const AFilename: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToBsonStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TRESTDWBsonArray.SaveToBsonStream(const AStream: TStream);
var
  Bson: TBytes;
begin
  Bson := ToBson;
  AStream.Write(Bson, Length(Bson));
end;

procedure TRESTDWBsonArray.SaveToJsonFile(const AFilename: String;
  const ASettings: TRESTDWJsonWriterSettings);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToJsonStream(Stream, ASettings);
  finally
    Stream.Free;
  end;
end;

procedure TRESTDWBsonArray.SaveToJsonFile(const AFilename: String);
begin
  SaveToJsonFile(AFilename, TRESTDWJsonWriterSettings.Default);
end;

procedure TRESTDWBsonArray.SaveToJsonStream(const AStream: TStream);
begin
  SaveToJsonStream(AStream, TRESTDWJsonWriterSettings.Default);
end;

procedure TRESTDWBsonArray.SaveToJsonStream(const AStream: TStream;
  const ASettings: TRESTDWJsonWriterSettings);
var
  Json: String;
begin
  Json := ToJson(ASettings);
  StreamWWrite(Json, AStream);
end;

procedure TRESTDWBsonArray.SetItem(const AIndex: Integer;
  const AValue: TRESTDWBsonValue);
begin
  FImpl.SetItem(AIndex, AValue.FImpl);
end;

procedure TRESTDWBsonArray.SetNil;
begin
  FImpl := nil;
end;

function TRESTDWBsonArray.ToArray: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF};
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsArray;
end;

function TRESTDWBsonArray.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonArray.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonArray.ToJson(const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

class function TRESTDWBsonArray.TryLoad(const ABson: TBytes;
  out AArray: TRESTDWBsonArray): Boolean;
var
  Reader: IgoBsonReader;
begin
  try
    Reader := TRESTDWBsonReader.Create(ABson);
    AArray := Reader.ReadArray;
    Result := True;
  except
    AArray.FImpl := nil;
    Result := False;
  end;
end;

class function TRESTDWBsonArray.TryParse(const AJson: String;
  out AArray: TRESTDWBsonArray): Boolean;
var
  Reader: IgoJsonReader;
begin
  try
    Reader := TRESTDWJsonReader.Create(AJson);
    AArray := Reader.ReadArray;
    Result := True;
  except
    AArray.FImpl := nil;
    Result := False;
  end;
end;

{ TRESTDWBsonElement }

function TRESTDWBsonElement.Clone: TRESTDWBsonElement;
begin
  Result.FName := FName;
  Result.FImpl := FImpl;
end;

class function TRESTDWBsonElement.Create(const AName: String;
  const AValue: TRESTDWBsonValue): TRESTDWBsonElement;
begin
  if (AValue.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);
  Result.FName := AName;
  Result.FImpl := AValue.FImpl;
end;

function TRESTDWBsonElement.DeepClone: TRESTDWBsonElement;
begin
  Result.FName := FName;
  Result.FImpl := FImpl.DeepClone;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonElement.Equal(const A, B: TRESTDWBsonElement): Boolean;
begin
  Result := (A.FName = B.FName);
  if (Result) then
  begin
    if (A.FImpl = nil) then
      Result := (B.FImpl = nil)
    else if (B.FImpl = nil) then
      Result := False
    else
      Result := A.FImpl.Equals(B.FImpl);
  end;
end;

function TRESTDWBsonElement.GetValue: TRESTDWBsonValue;
begin
  Result.FImpl := FImpl;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonElement.NotEqual(const A, B: TRESTDWBsonElement): Boolean;
begin
  Result := not (A = B);
end;

{ TRESTDWBsonArray.TEnumerator }

constructor TRESTDWBsonArray.TEnumerator.Create(const AImpl: _IArray);
begin
  Assert(Assigned(AImpl));
  FImpl := AImpl;
  FHigh := AImpl.Count - 1;
  FIndex := -1;
end;

function TRESTDWBsonArray.TEnumerator.GetCurrent: TRESTDWBsonValue;
begin
  FImpl.GetItem(FIndex, Result.FImpl);
end;

function TRESTDWBsonArray.TEnumerator.MoveNext: Boolean;
begin
  Result := (FIndex < FHigh);
  if Result then
    Inc(FIndex);
end;

{ TRESTDWBsonDocument }

function TRESTDWBsonDocument.Add(const AName: String; const AValue: TRESTDWBsonValue): TRESTDWBsonDocument;
begin
  Assert(Assigned(FImpl));
  FImpl.Add(AName, AValue.FImpl);
  Result.FImpl := FImpl;
end;

function TRESTDWBsonDocument.Add(const AElement: TRESTDWBsonElement): TRESTDWBsonDocument;
begin
  Assert(Assigned(FImpl));
  FImpl.Add(AElement.FName, AElement.FImpl);
  Result.FImpl := FImpl;
end;

procedure TRESTDWBsonDocument.Clear;
begin
  Assert(Assigned(FImpl));
  FImpl.Clear;
end;

function TRESTDWBsonDocument.Clone: TRESTDWBsonDocument;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TRESTDWBsonDocument._IDocument, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonDocument.Clone)');
end;

class function TRESTDWBsonDocument.Create: TRESTDWBsonDocument;
begin
  Result.FImpl := TValueDocument.Create;
end;

class function TRESTDWBsonDocument.Create(
  const AElement: TRESTDWBsonElement): TRESTDWBsonDocument;
begin
  Result.FImpl := TValueDocument.Create(AElement);
end;

class function TRESTDWBsonDocument.Create(
  const AAllowDuplicateNames: Boolean): TRESTDWBsonDocument;
begin
  Result.FImpl := TValueDocument.Create(AAllowDuplicateNames);
end;

class function TRESTDWBsonDocument.Create(const AName: String;
  const AValue: TRESTDWBsonValue): TRESTDWBsonDocument;
begin
  Result.FImpl := TValueDocument.Create(AName, AValue);
end;

function TRESTDWBsonDocument.Contains(const AName: String): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Contains(AName);
end;

function TRESTDWBsonDocument.ContainsValue(const AValue: TRESTDWBsonValue): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ContainsValue(AValue);
end;

function TRESTDWBsonDocument.DeepClone: TRESTDWBsonDocument;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TRESTDWBsonDocument._IDocument, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonDocument.DeepClone)');
end;

procedure TRESTDWBsonDocument.Delete(const AIndex: Integer);
begin
  Assert(Assigned(FImpl));
  FImpl.Delete(AIndex);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonDocument.Equal(const A, B: TRESTDWBsonDocument): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

function TRESTDWBsonDocument.Get(const AName: String;
  const ADefault: TRESTDWBsonValue): TRESTDWBsonValue;
begin
  Assert(Assigned(FImpl));
  FImpl.Get(AName, ADefault.FImpl, Result.FImpl);
end;

function TRESTDWBsonDocument.GetAllowDuplicateNames: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AllowDuplicateNames;
end;

function TRESTDWBsonDocument.GetCount: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Count;
end;

function TRESTDWBsonDocument.GetElement(const AIndex: Integer): TRESTDWBsonElement;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Elements[AIndex];
end;

function TRESTDWBsonDocument.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(FImpl);
end;

function TRESTDWBsonDocument.GetValue(const AIndex: Integer): TRESTDWBsonValue;
begin
  Assert(Assigned(FImpl));
  FImpl.GetValue(AIndex, Result.FImpl);
end;

function TRESTDWBsonDocument.GetValueByName(const AName: String): TRESTDWBsonValue;
begin
  Assert(Assigned(FImpl));
  FImpl.GetValueByName(AName, Result.FImpl);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonDocument.Implicit(const A: TRESTDWBsonDocument): TRESTDWBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TRESTDWBsonDocument.IndexOfName(const AName: String): Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.IndexOfName(AName);
end;

function TRESTDWBsonDocument.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class function TRESTDWBsonDocument.Load(const ABson: TBytes): TRESTDWBsonDocument;
var
  Reader: IgoBsonReader;
begin
  Reader := TRESTDWBsonReader.Create(ABson);
  Result := Reader.ReadDocument;
end;

class function TRESTDWBsonDocument.LoadFromBsonFile(
  const AFilename: String): TRESTDWBsonDocument;
var
  Reader: IgoBsonReader;
begin
  Reader := TRESTDWBsonReader.Load(AFilename);
  Result := Reader.ReadDocument;
end;

class function TRESTDWBsonDocument.LoadFromBsonStream(
  const AStream: TStream): TRESTDWBsonDocument;
var
  Reader: IgoBsonReader;
begin
  Reader := TRESTDWBsonReader.Load(AStream);
  Result := Reader.ReadDocument;
end;

class function TRESTDWBsonDocument.LoadFromJsonFile(
  const AFilename: String): TRESTDWBsonDocument;
var
  Reader: IgoJsonReader;
begin
  Reader := TRESTDWJsonReader.Load(AFilename);
  Result := Reader.ReadDocument;
end;

class function TRESTDWBsonDocument.LoadFromJsonStream(
  const AStream: TStream): TRESTDWBsonDocument;
var
  Reader: IgoJsonReader;
begin
  Reader := TRESTDWJsonReader.Load(AStream);
  Result := Reader.ReadDocument;
end;

function TRESTDWBsonDocument.Merge(const AOtherDocument: TRESTDWBsonDocument;
  const AOverwriteExistingElements: Boolean): TRESTDWBsonDocument;
begin
  Assert(Assigned(FImpl));
  FImpl.Merge(AOtherDocument, AOverwriteExistingElements);
  Result.FImpl := FImpl;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonDocument.NotEqual(const A, B: TRESTDWBsonDocument): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

class function TRESTDWBsonDocument.Parse(const AJson: String; AllowDuplicateNames : Boolean = false): TRESTDWBsonDocument;
var
  Reader: IgoJsonReader;
begin
  Reader := TRESTDWJsonReader.Create(AJson, AllowDuplicateNames);
  Result := Reader.ReadDocument;
end;

procedure TRESTDWBsonDocument.Remove(const AName: String);
begin
  Assert(Assigned(FImpl));
  FImpl.Remove(AName);
end;

procedure TRESTDWBsonDocument.SaveToBsonFile(const AFilename: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToBsonStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TRESTDWBsonDocument.SaveToBsonStream(const AStream: TStream);
var
  Bson: TBytes;
begin
  Bson := ToBson;
  AStream.Write(Bson, Length(Bson));
end;

procedure TRESTDWBsonDocument.SaveToJsonFile(const AFilename: String;
  const ASettings: TRESTDWJsonWriterSettings);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToJsonStream(Stream, ASettings);
  finally
    Stream.Free;
  end;
end;

procedure TRESTDWBsonDocument.SaveToJsonFile(const AFilename: String);
begin
  SaveToJsonFile(AFilename, TRESTDWJsonWriterSettings.Default);
end;

procedure TRESTDWBsonDocument.SaveToJsonStream(const AStream: TStream);
begin
  SaveToJsonStream(AStream, TRESTDWJsonWriterSettings.Default);
end;

procedure TRESTDWBsonDocument.SaveToJsonStream(const AStream: TStream;
  const ASettings: TRESTDWJsonWriterSettings);
var
  Json: String;
begin
  Json := ToJson(ASettings);
  StreamWWrite(Json, AStream);
end;

procedure TRESTDWBsonDocument.SetAllowDuplicateNames(const AValue: Boolean);
begin
  Assert(Assigned(FImpl));
  FImpl.AllowDuplicateNames := AValue;
end;

procedure TRESTDWBsonDocument.SetNil;
begin
  FImpl := nil;
end;

procedure TRESTDWBsonDocument.SetValue(const AIndex: Integer;
  const AValue: TRESTDWBsonValue);
begin
  Assert(Assigned(FImpl));
  FImpl.SetValue(AIndex, AValue.FImpl);
end;

procedure TRESTDWBsonDocument.SetValueByName(const AName: String;
  const AValue: TRESTDWBsonValue);
begin
  Assert(Assigned(FImpl));
  FImpl.SetValueByName(AName, AValue.FImpl);
end;

function TRESTDWBsonDocument.ToArray: TRESTDWArrayBsonElement;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToArray;
end;

function TRESTDWBsonDocument.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonDocument.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonDocument.ToJson(const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

function TRESTDWBsonDocument.TryGetElement(const AName: String;
  out AElement: TRESTDWBsonElement): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.TryGetElement(AName, AElement);
end;

function TRESTDWBsonDocument.TryGetValue(const AName: String;
  out AValue: TRESTDWBsonValue): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.TryGetValue(AName, AValue.FImpl);
end;

class function TRESTDWBsonDocument.TryLoad(const ABson: TBytes;
  out ADocument: TRESTDWBsonDocument): Boolean;
var
  Reader: IgoBsonReader;
begin
  try
    Reader := TRESTDWBsonReader.Create(ABson);
    ADocument := Reader.ReadDocument;
    Result := True;
  except
    ADocument.FImpl := nil;
    Result := False;
  end;
end;

class function TRESTDWBsonDocument.TryParse(const AJson: String;
  out ADocument: TRESTDWBsonDocument; AllowDuplicateNames : Boolean = false): Boolean;
var
  Reader: IgoJsonReader;
begin
  try
    Reader := TRESTDWJsonReader.Create(AJson, AllowDuplicateNames);
    ADocument := Reader.ReadDocument;
    Result := True;
  except
    ADocument.FImpl := nil;
    Result := False;
  end;
end;

{ TRESTDWBsonDocument.TEnumerator }

constructor TRESTDWBsonDocument.TEnumerator.Create(const AImpl: _IDocument);
begin
  Assert(Assigned(AImpl));
  FImpl := AImpl;
  FHigh := AImpl.Count - 1;
  FIndex := -1;
end;

function TRESTDWBsonDocument.TEnumerator.GetCurrent: TRESTDWBsonElement;
begin
  Result := FImpl.Elements[FIndex];
end;

function TRESTDWBsonDocument.TEnumerator.MoveNext: Boolean;
begin
  Result := (FIndex < FHigh);
  if Result then
    Inc(FIndex);
end;

{ TRESTDWBsonBinaryData }

function TRESTDWBsonBinaryData.Clone: TRESTDWBsonBinaryData;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TRESTDWBsonBinaryData._IBinaryData, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonBinaryData.Clone)');
end;

class function TRESTDWBsonBinaryData.Create: TRESTDWBsonBinaryData;
begin
  Result.FImpl := TValueBinaryData.Create;
end;

class function TRESTDWBsonBinaryData.Create(const AData: TBytes): TRESTDWBsonBinaryData;
begin
  Result.FImpl := TValueBinaryData.Create(AData);
end;

class function TRESTDWBsonBinaryData.Create(const AData: TBytes;
  const ASubType: TRESTDWBsonBinarySubType): TRESTDWBsonBinaryData;
begin
  Result.FImpl := TValueBinaryData.Create(AData, ASubType);
end;

function TRESTDWBsonBinaryData.DeepClone: TRESTDWBsonBinaryData;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TRESTDWBsonBinaryData._IBinaryData, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonArray.TRESTDWBsonBinaryData)');
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonBinaryData.Equal(const A, B: TRESTDWBsonBinaryData): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

function TRESTDWBsonBinaryData.GetAsBytes: TBytes;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsBytes;
end;

function TRESTDWBsonBinaryData.GetByte(const AIndex: Integer): Byte;
begin
  Result := FImpl[AIndex];
end;

function TRESTDWBsonBinaryData.GetCount: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Count;
end;

function TRESTDWBsonBinaryData.GetSubType: TRESTDWBsonBinarySubType;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.SubType;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonBinaryData.Implicit(
  const A: TRESTDWBsonBinaryData): TRESTDWBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TRESTDWBsonBinaryData.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonBinaryData.NotEqual(const A,
  B: TRESTDWBsonBinaryData): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

procedure TRESTDWBsonBinaryData.SetByte(const AIndex: Integer; const AValue: Byte);
begin
  FImpl[AIndex] := AValue;
end;

procedure TRESTDWBsonBinaryData.SetNil;
begin
  FImpl := nil;
end;

function TRESTDWBsonBinaryData.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonBinaryData.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonBinaryData.ToJson(
  const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TRESTDWBsonNull }

function TRESTDWBsonNull.Clone: TRESTDWBsonNull;
begin
  Result := FImpl;
end;

{$IFNDEF FPC}Class {$ENDIF}Constructor TRESTDWBsonNull.Create;
begin
  {$IFDEF FPC}Create;{$ENDIF}
  FImpl.FValue := _INull(@VALUE_NULL);
end;

function TRESTDWBsonNull.DeepClone: TRESTDWBsonNull;
begin
  Result := FImpl;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonNull.Equal(const A, B: TRESTDWBsonNull): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonNull.Implicit(const A: TRESTDWBsonNull): TRESTDWBsonValue;
begin
  Result.FImpl := A.FValue;
end;

function TRESTDWBsonNull.IsNil: Boolean;
begin
  Result := (FValue = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonNull.NotEqual(const A, B: TRESTDWBsonNull): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

function TRESTDWBsonNull.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonNull.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonNull.ToJson(const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TRESTDWBsonUndefined }

function TRESTDWBsonUndefined.Clone: TRESTDWBsonUndefined;
begin
  Result := FImpl;
end;

{$IFNDEF FPC}class {$ENDIF}constructor TRESTDWBsonUndefined.Create;
begin
  FImpl.FValue := _IUndefined(@VALUE_UNDEFINED);
end;

function TRESTDWBsonUndefined.DeepClone: TRESTDWBsonUndefined;
begin
  Result := FImpl;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonUndefined.Equal(const A, B: TRESTDWBsonUndefined): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonUndefined.Implicit(const A: TRESTDWBsonUndefined): TRESTDWBsonValue;
begin
  Result.FImpl := A.FValue;
end;

function TRESTDWBsonUndefined.IsNil: Boolean;
begin
  Result := (FValue = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonUndefined.NotEqual(const A, B: TRESTDWBsonUndefined): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

function TRESTDWBsonUndefined.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonUndefined.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonUndefined.ToJson(const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TRESTDWBsonRegularExpression }

function TRESTDWBsonRegularExpression.Clone: TRESTDWBsonRegularExpression;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TRESTDWBsonRegularExpression._IRegularExpression, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonRegularExpression.Clone)');
end;

class function TRESTDWBsonRegularExpression.Create(const APattern,
  AOptions: String): TRESTDWBsonRegularExpression;
begin
  Result.FImpl := TValueRegularExpression.Create(APattern, AOptions);
end;

class function TRESTDWBsonRegularExpression.Create(
  const APattern: String): TRESTDWBsonRegularExpression;
begin
  Result.FImpl := TValueRegularExpression.Create(APattern);
end;

function TRESTDWBsonRegularExpression.DeepClone: TRESTDWBsonRegularExpression;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TRESTDWBsonRegularExpression._IRegularExpression, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonRegularExpression.DeepClone)');
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonRegularExpression.Equal(const A,
  B: TRESTDWBsonRegularExpression): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

function TRESTDWBsonRegularExpression.GetOptions: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Options;
end;

function TRESTDWBsonRegularExpression.GetPattern: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Pattern;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonRegularExpression.Implicit(
  const A: TRESTDWBsonRegularExpression): TRESTDWBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonRegularExpression.Implicit(const A: String): TRESTDWBsonRegularExpression;
begin
  Result.FImpl := TValueRegularExpression.Create(A);
end;

function TRESTDWBsonRegularExpression.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonRegularExpression.NotEqual(const A,
  B: TRESTDWBsonRegularExpression): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

procedure TRESTDWBsonRegularExpression.SetNil;
begin
  FImpl := nil;
end;

function TRESTDWBsonRegularExpression.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonRegularExpression.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonRegularExpression.ToJson(
  const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TRESTDWBsonJavaScript }

function TRESTDWBsonJavaScript.Clone: TRESTDWBsonJavaScript;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TRESTDWBsonJavaScript._IJavaScript, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonJavaScript.Clone)');
end;

class function TRESTDWBsonJavaScript.Create(const ACode: String): TRESTDWBsonJavaScript;
begin
  Result.FImpl := TValueJavaScript.Create(ACode);
end;

function TRESTDWBsonJavaScript.DeepClone: TRESTDWBsonJavaScript;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TRESTDWBsonJavaScript._IJavaScript, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonJavaScript.DeepClone)');
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonJavaScript.Equal(const A, B: TRESTDWBsonJavaScript): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

function TRESTDWBsonJavaScript.GetCode: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Code;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonJavaScript.Implicit(
  const A: TRESTDWBsonJavaScript): TRESTDWBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TRESTDWBsonJavaScript.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonJavaScript.NotEqual(const A,
  B: TRESTDWBsonJavaScript): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

procedure TRESTDWBsonJavaScript.SetNil;
begin
  FImpl := nil;
end;

function TRESTDWBsonJavaScript.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonJavaScript.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonJavaScript.ToJson(
  const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TRESTDWBsonJavaScriptWithScope }

function TRESTDWBsonJavaScriptWithScope.Clone: TRESTDWBsonJavaScriptWithScope;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonJavaScriptWithScope.Clone)');
end;

class function TRESTDWBsonJavaScriptWithScope.Create(const ACode: String;
  const AScope: TRESTDWBsonDocument): TRESTDWBsonJavaScriptWithScope;
begin
  Result.FImpl := TValueJavaScriptWithScope.Create(ACode, AScope);
end;

function TRESTDWBsonJavaScriptWithScope.DeepClone: TRESTDWBsonJavaScriptWithScope;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonJavaScriptWithScope.DeepClone)');
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonJavaScriptWithScope.Equal(const A,
  B: TRESTDWBsonJavaScriptWithScope): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

function TRESTDWBsonJavaScriptWithScope.GetCode: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Code;
end;

function TRESTDWBsonJavaScriptWithScope.GetScope: TRESTDWBsonDocument;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Scope;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonJavaScriptWithScope.Implicit(
  const A: TRESTDWBsonJavaScriptWithScope): TRESTDWBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TRESTDWBsonJavaScriptWithScope.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonJavaScriptWithScope.NotEqual(const A,
  B: TRESTDWBsonJavaScriptWithScope): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

procedure TRESTDWBsonJavaScriptWithScope.SetNil;
begin
  FImpl := nil;
end;

function TRESTDWBsonJavaScriptWithScope.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonJavaScriptWithScope.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonJavaScriptWithScope.ToJson(
  const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TRESTDWBsonSymbol }

function TRESTDWBsonSymbol.Clone: TRESTDWBsonSymbol;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TRESTDWBsonSymbol._ISymbol, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonSymbol.Clone)');
end;

function TRESTDWBsonSymbol.DeepClone: TRESTDWBsonSymbol;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TRESTDWBsonSymbol._ISymbol, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonSymbol.DeepClone)');
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonSymbol.Equal(const A, B: TRESTDWBsonSymbol): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

function TRESTDWBsonSymbol.GetName: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Name;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonSymbol.Implicit(const A: TRESTDWBsonSymbol): TRESTDWBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TRESTDWBsonSymbol.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonSymbol.NotEqual(const A, B: TRESTDWBsonSymbol): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

procedure TRESTDWBsonSymbol.SetNil;
begin
  FImpl := nil;
end;

function TRESTDWBsonSymbol.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonSymbol.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonSymbol.ToJson(const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TRESTDWBsonSymbolTable }

class constructor TRESTDWBsonSymbolTable.Create;
begin
  FTable := {$IFDEF FPC} specialize {$ENDIF} TDictionary<String, TRESTDWBsonSymbol>.Create;
  FLock := TCriticalSection.Create;
end;

class destructor TRESTDWBsonSymbolTable.Destroy;
begin
  FreeAndNil(FTable);
  FreeAndNil(FLock);
end;

class function TRESTDWBsonSymbolTable.Lookup(const AName: String): TRESTDWBsonSymbol;
begin
  FLock.Enter;
  try
    if (not FTable.TryGetValue(AName, Result)) then
    begin
      Result.FImpl := TValueSymbol.Create(AName);
      FTable.Add(AName, Result);
    end;
  finally
    FLock.Leave;
  end;
end;

{ TRESTDWBsonDateTime }

function TRESTDWBsonDateTime.Clone: TRESTDWBsonDateTime;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TRESTDWBsonDateTime._IDateTime, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonDateTime.Clone)');
end;

class function TRESTDWBsonDateTime.Create(const ADateTime: TDateTime;
  const ADateTimeIsUTC: Boolean): TRESTDWBsonDateTime;
begin
  Result.FImpl := TValueDateTime.Create(ADateTime, ADateTimeIsUTC);
end;

class function TRESTDWBsonDateTime.Create(
  const AMillisecondsSinceEpoch: Int64): TRESTDWBsonDateTime;
begin
  Result.FImpl := TValueDateTime.Create(AMillisecondsSinceEpoch);
end;

function TRESTDWBsonDateTime.DeepClone: TRESTDWBsonDateTime;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TRESTDWBsonDateTime._IDateTime, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonDateTime.DeepClone)');
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonDateTime.Equal(const A, B: TRESTDWBsonDateTime): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

function TRESTDWBsonDateTime.GetMillisecondsSinceEpoch: Int64;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.MillisecondsSinceEpoch;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonDateTime.Implicit(const A: TRESTDWBsonDateTime): TRESTDWBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TRESTDWBsonDateTime.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonDateTime.NotEqual(const A, B: TRESTDWBsonDateTime): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

procedure TRESTDWBsonDateTime.SetNil;
begin
  FImpl := nil;
end;

function TRESTDWBsonDateTime.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonDateTime.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonDateTime.ToJson(const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

function TRESTDWBsonDateTime.ToLocalTime: TDateTime;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToLocalTime;
end;

function TRESTDWBsonDateTime.ToUniversalTime: TDateTime;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToUniversalTime;
end;

{ TRESTDWBsonTimestamp }

class function TRESTDWBsonTimestamp.Create(const AValue: Int64): TRESTDWBsonTimestamp;
begin
  Result.FImpl := TValueTimestamp.Create(AValue);
end;

function TRESTDWBsonTimestamp.Clone: TRESTDWBsonTimestamp;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TRESTDWBsonTimestamp._ITimestamp, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonTimestamp.Clone)');
end;

class function TRESTDWBsonTimestamp.Create(const ATimestamp, AIncrement: Integer): TRESTDWBsonTimestamp;
begin
  Result.FImpl := TValueTimestamp.Create(ATimestamp, AIncrement);
end;

function TRESTDWBsonTimestamp.DeepClone: TRESTDWBsonTimestamp;
var
  C: TRESTDWBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TRESTDWBsonTimestamp._ITimestamp, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TRESTDWBsonTimestamp.DeepClone)');
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonTimestamp.Equal(const A, B: TRESTDWBsonTimestamp): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

function TRESTDWBsonTimestamp.GetIncrement: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Increment;
end;

function TRESTDWBsonTimestamp.GetTimestamp: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Timestamp;
end;

function TRESTDWBsonTimestamp.GetValue: Int64;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Value;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonTimestamp.Implicit(
  const A: TRESTDWBsonTimestamp): TRESTDWBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TRESTDWBsonTimestamp.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonTimestamp.NotEqual(const A, B: TRESTDWBsonTimestamp): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

procedure TRESTDWBsonTimestamp.SetNil;
begin
  FImpl := nil;
end;

function TRESTDWBsonTimestamp.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonTimestamp.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonTimestamp.ToJson(
  const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TRESTDWBsonMaxKey }

function TRESTDWBsonMaxKey.Clone: TRESTDWBsonMaxKey;
begin
  Result := FImpl;
end;

{$IFNDEF FPC}class {$ENDIF}constructor TRESTDWBsonMaxKey.Create;
begin
  FImpl.FValue := _IMaxKey(@VALUE_MAX_KEY);
end;

function TRESTDWBsonMaxKey.DeepClone: TRESTDWBsonMaxKey;
begin
  Result := FImpl;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonMaxKey.Equal(const A, B: TRESTDWBsonMaxKey): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonMaxKey.Implicit(const A: TRESTDWBsonMaxKey): TRESTDWBsonValue;
begin
  Result.FImpl := A.FValue;
end;

function TRESTDWBsonMaxKey.IsNil: Boolean;
begin
  Result := (FValue = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonMaxKey.NotEqual(const A, B: TRESTDWBsonMaxKey): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

function TRESTDWBsonMaxKey.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonMaxKey.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonMaxKey.ToJson(const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TRESTDWBsonMinKey }

function TRESTDWBsonMinKey.Clone: TRESTDWBsonMinKey;
begin
  Result := FImpl;
end;

{$IFNDEF FPC}class {$ENDIF}constructor TRESTDWBsonMinKey.Create;
begin
  FImpl.FValue := _IMinKey(@VALUE_MIN_KEY);
end;

function TRESTDWBsonMinKey.DeepClone: TRESTDWBsonMinKey;
begin
  Result := FImpl;
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonMinKey.Equal(const A, B: TRESTDWBsonMinKey): Boolean;
begin
  Result := (TRESTDWBsonValue(A) = TRESTDWBsonValue(B));
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonMinKey.Implicit(const A: TRESTDWBsonMinKey): TRESTDWBsonValue;
begin
  Result.FImpl := A.FValue;
end;

function TRESTDWBsonMinKey.IsNil: Boolean;
begin
  Result := (FValue = nil);
end;

class {$IFNDEF FPC}operator {$ELSE}Function{$ENDIF} TRESTDWBsonMinKey.NotEqual(const A, B: TRESTDWBsonMinKey): Boolean;
begin
  Result := (TRESTDWBsonValue(A) <> TRESTDWBsonValue(B));
end;

function TRESTDWBsonMinKey.ToBson: TBytes;
begin
  Result := TRESTDWBsonValue(Self).ToBson;
end;

function TRESTDWBsonMinKey.ToJson: String;
begin
  Result := TRESTDWBsonValue(Self).ToJson;
end;

function TRESTDWBsonMinKey.ToJson(const ASettings: TRESTDWJsonWriterSettings): String;
begin
  Result := TRESTDWBsonValue(Self).ToJson(ASettings);
end;

{ TNonRefCountedInterface }

function TNonRefCountedInterface.Addref: Integer;
begin
  Result := -1;
end;

function TNonRefCountedInterface.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := E_NOINTERFACE;
end;

function TNonRefCountedInterface.Release: Integer;
begin
  Result := -1;
end;

{ TRefCountedInterface }

function TRefCountedInterface.Addref: Integer;
begin
  Result := AtomicIncrement(FRefCount);
end;

function TRefCountedInterface.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  Result := E_NOINTERFACE;
end;

function TRefCountedInterface.Release: Integer;
begin
  Result := AtomicDecrement(FRefCount);
  if (Result = 0) then
    FreeMem(@Self);
end;

{ TValue }

function TValue.AsArray: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF};
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsBoolean: Boolean;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsByteArray: TBytes;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsDouble: Double;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsGuid: TGUID;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsInt64: Int64;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsInteger: Integer;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsObjectId: TRESTDWObjectId;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsString: String;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.Clone: TRESTDWBsonValue._IValue;
begin
  Result := TRESTDWBsonValue._IValue(@Self);
end;

function TValue.DeepClone: TRESTDWBsonValue._IValue;
begin
  Result := TRESTDWBsonValue._IValue(@Self);
end;

function TValue.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  This, Other: TRESTDWBsonValue;
begin
  This.FImpl := TRESTDWBsonValue._IValue(@Self);
  Other.FImpl := AOther;
  Result := (This = Other);
end;

function TValue.GetBsonType: TRESTDWBsonType;
begin
  raise EAbstractError.CreateRes(@SAbstractError);
end;

function TValue.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := ADefault;
end;

function TValue.ToByteArray: TBytes;
begin
  Result := nil;
end;

function TValue.ToDouble(const ADefault: Double): Double;
begin
  Result := ADefault;
end;

function TValue.ToGuid: TGUID;
begin
{$IFNDEF FPC}
 Result := TGUID.Empty;
{$ELSE}
 FillChar(Result, Sizeof(Result), 0);
{$ENDIF}
end;

function TValue.ToInt64(const ADefault: Int64): Int64;
begin
  Result := ADefault;
end;

function TValue.ToInteger(const ADefault: Integer): Integer;
begin
  Result := ADefault;
end;

function TValue.ToLocalTime: TDateTime;
begin
  Result := 0;
end;

function TValue.ToObjectId: TRESTDWObjectId;
begin
  Result := TRESTDWObjectId.Empty;
end;

function TValue.ToString(const ADefault: String): String;
begin
  Result := ADefault;
end;

function TValue.ToUniversalTime: TDateTime;
begin
  Result := 0;
end;

{ TValueFalse }

function TValueFalse.AsBoolean: Boolean;
begin
  Result := False;
end;

class constructor TValueFalse.Create;
begin
  FValue := TRESTDWBsonValue._IValue(@VALUE_BOOLEAN_FALSE);
end;

function TValueFalse.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TRESTDWBsonType.Boolean) then
    Result := (not AOther.AsBoolean)
  else
    Result := False;
end;

function TValueFalse.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Boolean;
end;

function TValueFalse.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueFalse.ToDouble(const ADefault: Double): Double;
begin
  Result := 0;
end;

function TValueFalse.ToInt64(const ADefault: Int64): Int64;
begin
  Result := 0;
end;

function TValueFalse.ToInteger(const ADefault: Integer): Integer;
begin
  Result := 0;
end;

function TValueFalse.ToString(const ADefault: String): String;
begin
  Result := 'false';
end;

{ TValueTrue }

function TValueTrue.AsBoolean: Boolean;
begin
  Result := True;
end;

class constructor TValueTrue.Create;
begin
  FValue := TRESTDWBsonValue._IValue(@VALUE_BOOLEAN_TRUE);
end;

function TValueTrue.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TRESTDWBsonType.Boolean) then
    Result := AOther.AsBoolean
  else
    Result := False;
end;

function TValueTrue.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Boolean;
end;

function TValueTrue.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := True;
end;

function TValueTrue.ToDouble(const ADefault: Double): Double;
begin
  Result := 1;
end;

function TValueTrue.ToInt64(const ADefault: Int64): Int64;
begin
  Result := 1;
end;

function TValueTrue.ToInteger(const ADefault: Integer): Integer;
begin
  Result := 1;
end;

function TValueTrue.ToString(const ADefault: String): String;
begin
  Result := 'true';
end;

{ TValueInteger }

function TValueInteger.AsInteger: Integer;
begin
  Result := FValue;
end;

class function TValueInteger.Create(const AValue: Integer): TRESTDWBsonValue._IValue;
var
  V: PValueInteger;
begin
  GetMem(V, SizeOf(TValueInteger));
  V^.FBase.FVTable := @VTABLE_INTEGER;
  V^.FBase.FRefCount := 0;
  V^.FValue := AValue;
  Result := TRESTDWBsonValue._IValue(V);
end;

function TValueInteger.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TRESTDWBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TRESTDWBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TRESTDWBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueInteger.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Int32;
end;

function TValueInteger.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0);
end;

function TValueInteger.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueInteger.ToInt64(const ADefault: Int64): Int64;
begin
  Result := FValue;
end;

function TValueInteger.ToInteger(const ADefault: Integer): Integer;
begin
  Result := FValue;
end;

function TValueInteger.ToString(const ADefault: String): String;
begin
  Result := IntToStr(FValue);
end;

{ TValueIntegerConst }

function TValueIntegerConst.AsInteger: Integer;
begin
  Result := FValue;
end;

{$IFNDEF FPC}class {$ENDIF}constructor TValueIntegerConst.Create;
var
  I: Integer;
  P: PValueIntegerConst;
begin
  GetMem(FPrecreatedData, ((MAX_PRECREATED_VALUE - MIN_PRECREATED_VALUE) + 1) * SizeOf(TValueIntegerConst));
  P := FPrecreatedData;
  for I := MIN_PRECREATED_VALUE to MAX_PRECREATED_VALUE do
  begin
    P^.FBase.FVTable := @VTABLE_INTEGER_CONST;
    P^.FValue := I;
    FPrecreatedValues[I] := TRESTDWBsonValue._IValue(P);
    Inc(P);
  end;
end;

{$IFNDEF FPC}class {$ENDIF}destructor TValueIntegerConst.Destroy;
var
  I: Integer;
begin
  for I := MIN_PRECREATED_VALUE to MAX_PRECREATED_VALUE do
    FPrecreatedValues[I] := nil;
  FreeMem(FPrecreatedData);
  FPrecreatedData := nil;
end;

function TValueIntegerConst.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TRESTDWBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TRESTDWBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TRESTDWBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueIntegerConst.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Int32;
end;

function TValueIntegerConst.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0);
end;

function TValueIntegerConst.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueIntegerConst.ToInt64(const ADefault: Int64): Int64;
begin
  Result := FValue;
end;

function TValueIntegerConst.ToInteger(const ADefault: Integer): Integer;
begin
  Result := FValue;
end;

function TValueIntegerConst.ToString(const ADefault: String): String;
begin
  Result := IntToStr(FValue);
end;

{ TValueInt64 }

function TValueInt64.AsInt64: Int64;
begin
  Result := FValue;
end;

class function TValueInt64.Create(const AValue: Int64): TRESTDWBsonValue._IValue;
var
  V: PValueInt64;
begin
  GetMem(V, SizeOf(TValueInt64));
  V^.FBase.FVTable := @VTABLE_INT64;
  V^.FBase.FRefCount := 0;
  V^.FValue := AValue;
  Result := TRESTDWBsonValue._IValue(V);
end;

function TValueInt64.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TRESTDWBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TRESTDWBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TRESTDWBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueInt64.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Int64;
end;

function TValueInt64.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0);
end;

function TValueInt64.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueInt64.ToInt64(const ADefault: Int64): Int64;
begin
  Result := FValue;
end;

function TValueInt64.ToInteger(const ADefault: Integer): Integer;
begin
  Result := FValue;
end;

function TValueInt64.ToString(const ADefault: String): String;
begin
  Result := IntToStr(FValue);
end;

{ TValueInt64Const }

function TValueInt64Const.AsInt64: Int64;
begin
  Result := FValue;
end;

{$IFNDEF FPC}class {$ENDIF}constructor TValueInt64Const.Create;
var
  I: Integer;
  P: PValueInt64Const;
begin
  GetMem(FPrecreatedData, ((MAX_PRECREATED_VALUE - MIN_PRECREATED_VALUE) + 1) * SizeOf(TValueInt64Const));
  P := FPrecreatedData;
  for I := MIN_PRECREATED_VALUE to MAX_PRECREATED_VALUE do
  begin
    P^.FBase.FVTable := @VTABLE_INT64_CONST;
    P^.FValue := I;
    FPrecreatedValues[I] := TRESTDWBsonValue._IValue(P);
    Inc(P);
  end;
end;

{$IFNDEF FPC}class {$ENDIF}destructor TValueInt64Const.Destroy;
var
  I: Integer;
begin
  for I := MIN_PRECREATED_VALUE to MAX_PRECREATED_VALUE do
    FPrecreatedValues[I] := nil;
  FreeMem(FPrecreatedData);
  FPrecreatedData := nil;
end;

function TValueInt64Const.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TRESTDWBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TRESTDWBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TRESTDWBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueInt64Const.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Int64;
end;

function TValueInt64Const.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0);
end;

function TValueInt64Const.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueInt64Const.ToInt64(const ADefault: Int64): Int64;
begin
  Result := FValue;
end;

function TValueInt64Const.ToInteger(const ADefault: Integer): Integer;
begin
  Result := FValue;
end;

function TValueInt64Const.ToString(const ADefault: String): String;
begin
  Result := IntToStr(FValue);
end;

{ TValueDouble }

function TValueDouble.AsDouble: Double;
begin
  Result := FValue;
end;

class function TValueDouble.Create(const AValue: Double): TRESTDWBsonValue._IValue;
var
  V: PValueDouble;
begin
  GetMem(V, SizeOf(TValueDouble));
  V^.FBase.FVTable := @VTABLE_DOUBLE;
  V^.FBase.FRefCount := 0;
  V^.FValue := AValue;
  Result := TRESTDWBsonValue._IValue(V);
end;

function TValueDouble.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TRESTDWBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TRESTDWBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TRESTDWBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueDouble.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Double;
end;

function TValueDouble.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0) and (not FValue.IsNan);
end;

function TValueDouble.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueDouble.ToInt64(const ADefault: Int64): Int64;
begin
  Result := Trunc(FValue);
end;

function TValueDouble.ToInteger(const ADefault: Integer): Integer;
begin
  Result := Trunc(FValue);
end;

function TValueDouble.ToString(const ADefault: String): String;
begin
  Result := FloatToStr(FValue, goUSFormatSettings);
end;

{ TValueDoubleZero }

function TValueDoubleZero.AsDouble: Double;
begin
  Result := 0;
end;

{$IFNDEF FPC}class {$ENDIF}constructor TValueDoubleZero.Create;
begin
  FValue := TRESTDWBsonValue._IValue(@VALUE_DOUBLE_ZERO);
end;

function TValueDoubleZero.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TRESTDWBsonType.Int32:
      Result := (AOther.AsInteger = 0);

    TRESTDWBsonType.Int64:
      Result := (AOther.AsInt64 = 0);

    TRESTDWBsonType.Double:
      Result := (AOther.AsDouble = 0);
  else
    Result := False;
  end;
end;

function TValueDoubleZero.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Double;
end;

function TValueDoubleZero.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueDoubleZero.ToDouble(const ADefault: Double): Double;
begin
  Result := 0;
end;

function TValueDoubleZero.ToInt64(const ADefault: Int64): Int64;
begin
  Result := 0;
end;

function TValueDoubleZero.ToInteger(const ADefault: Integer): Integer;
begin
  Result := 0;
end;

function TValueDoubleZero.ToString(const ADefault: String): String;
begin
  Result := '0';
end;

{ TValueDateTime }

class function TValueDateTime.Create(const ADateTime: TDateTime;
  const ADateTimeIsUTC: Boolean): TRESTDWBsonDateTime._IDateTime;
begin
  Result := Create(goDateTimeToMillisecondsSinceEpoch(ADateTime, ADateTimeIsUTC));
end;

class function TValueDateTime.Create(
  const AMillisecondsSinceEpoch: Int64): TRESTDWBsonDateTime._IDateTime;
var
  V: PValueDateTime;
begin
  GetMem(V, SizeOf(TValueDateTime));
  V^.FBase.FVTable := @VTABLE_DATE_TIME;
  V^.FBase.FRefCount := 0;
  V^.FMillisecondsSinceEpoch := AMillisecondsSinceEpoch;
  Result := TRESTDWBsonDateTime._IDateTime(V);
end;

function TValueDateTime.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  Other: PValueDateTime;
begin
  if (AOther.BsonType = TRESTDWBsonType.DateTime) then
  begin
    Other := PValueDateTime(AOther);
    Result := (FMillisecondsSinceEpoch = Other^.FMillisecondsSinceEpoch);
  end
  else
    Result := False;
end;

function TValueDateTime.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.DateTime;
end;

function TValueDateTime.GetMillisecondsSinceEpoch: Int64;
begin
  Result := FMillisecondsSinceEpoch;
end;

function TValueDateTime.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  {$IFNDEF FPC}
  if (IID = TRESTDWBsonDateTime._IDateTime) then
  begin
  {$ENDIF}
    TRESTDWBsonDateTime._IDateTime(Obj) := TRESTDWBsonDateTime._IDateTime(@Self);
    Result := S_OK;
  {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
  {$ENDIF}
end;

function TValueDateTime.ToLocalTime: TDateTime;
begin
  Result := goToDateTimeFromMillisecondsSinceEpoch(FMillisecondsSinceEpoch, False);
end;

function TValueDateTime.ToString(const ADefault: String): String;
begin
  Result := DateToISO8601(ToLocalTime, False);
end;

function TValueDateTime.ToUniversalTime: TDateTime;
begin
  Result := goToDateTimeFromMillisecondsSinceEpoch(FMillisecondsSinceEpoch, True);
end;

{ TValueString }

function TValueString.AsString: String;
begin
  Result := Value;
end;

class function TValueString.Create(const AValue: String): TRESTDWBsonValue._IValue;
var
  Len: Integer;
  V: PValueString;
begin
  Len := Length(AValue);
  GetMem(V, SizeOf(TValueString) + Len * SizeOf(Char));
  V^.FBase.FVTable := @VTABLE_STRING;
  V^.FBase.FRefCount := 0;
  V^.FLength := Len;
  Result := TRESTDWBsonValue._IValue(V);
  Inc(V);
  Move(AValue[Low(String)], V^, Len * SizeOf(Char));
end;

function TValueString.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TRESTDWBsonType.&String) then
    Result := (Value = AOther.AsString)
  else
    Result := False;
end;

function TValueString.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.&String;
end;

function TValueString.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := True;
end;

function TValueString.ToDouble(const ADefault: Double): Double;
begin
  Result := StrToFloatDef(Value, ADefault, goUSFormatSettings);
end;

function TValueString.ToInt64(const ADefault: Int64): Int64;
begin
  Result := StrToInt64Def(Value, ADefault);
end;

function TValueString.ToInteger(const ADefault: Integer): Integer;
begin
  Result := StrToIntDef(Value, ADefault);
end;

function TValueString.ToString(const ADefault: String): String;
begin
  Result := Value;
end;

function TValueString.Value: String;
begin
  SetString(Result, PChar(PByte(@Self) + SizeOf(TValueString)), FLength);
end;

{ TValueStringEmpty }

function TValueStringEmpty.AsString: String;
begin
  Result := '';
end;

{$IFNDEF FPC}class {$ENDIF}constructor TValueStringEmpty.Create;
begin
  FValue := TRESTDWBsonValue._IValue(@VALUE_STRING_EMPTY);
end;

function TValueStringEmpty.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TRESTDWBsonType.&String) then
    Result := (AOther.AsString = '')
  else
    Result := False;
end;

function TValueStringEmpty.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.&String;
end;

function TValueStringEmpty.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueStringEmpty.ToDouble(const ADefault: Double): Double;
begin
  Result := ADefault;
end;

function TValueStringEmpty.ToInt64(const ADefault: Int64): Int64;
begin
  Result := ADefault;
end;

function TValueStringEmpty.ToInteger(const ADefault: Integer): Integer;
begin
  Result := ADefault;
end;

function TValueStringEmpty.ToString(const ADefault: String): String;
begin
  Result := '';
end;

{ TValueStringConstant }

function TValueStringConstant.AsString: String;
begin
  Result := Value;
end;

class function TValueStringConstant.Create(const AValue: String): TRESTDWBsonValue._IValue;
var
  V: PValueStringConstant;
begin
  GetMem(V, SizeOf(TValueStringConstant));
  V^.FBase.FVTable := @VTABLE_STRING_CONSTANT;
  V^.FBase.FRefCount := 0;
  V^.FValue := Pointer(AValue);
  Result := TRESTDWBsonValue._IValue(V);
end;

function TValueStringConstant.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TRESTDWBsonType.&String) then
    Result := (Value = AOther.AsString)
  else
    Result := False;
end;

function TValueStringConstant.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.&String;
end;

function TValueStringConstant.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := True;
end;

function TValueStringConstant.ToDouble(const ADefault: Double): Double;
begin
  Result := StrToFloatDef(Value, ADefault, goUSFormatSettings);
end;

function TValueStringConstant.ToInt64(const ADefault: Int64): Int64;
begin
  Result := StrToInt64Def(Value, ADefault);
end;

function TValueStringConstant.ToInteger(const ADefault: Integer): Integer;
begin
  Result := StrToIntDef(Value, ADefault);
end;

function TValueStringConstant.ToString(const ADefault: String): String;
begin
  Result := Value;
end;

function TValueStringConstant.Value: String;
begin
  Result := String(FValue);
end;

{ TValueArray }

procedure TValueArray.Add(const AValue: TRESTDWBsonValue._IValue);
var
  Capacity: Integer;
begin
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  Capacity := Length(FItems);
  if (FCount >= Capacity) then
  begin
    if (Capacity > 64) then
      Inc(Capacity, Capacity div 4)
    else if (Capacity > 8) then
      Inc(Capacity, 16)
    else
      Inc(Capacity, 4);
    SetLength(FItems, Capacity);
  end;
  FItems[FCount] := AValue;
  Inc(FCount);
end;

procedure TValueArray.AddRangeOpenArray(const AValues: array of TRESTDWBsonValue);
var
  I: Integer;
begin
  for I := 0 to Length(AValues) - 1 do
    Add(AValues[I].FImpl);
end;

procedure TValueArray.AddRangeGenArray(const AValues: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF});
var
  I: Integer;
begin
  for I := 0 to Length(AValues) - 1 do
    Add(AValues[I].FImpl);
end;

procedure TValueArray.AddRangeBsonArray(const AValues: TRESTDWBsonArray);
var
  I: Integer;
begin
  if (AValues.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  for I := 0 to AValues.Count - 1 do
    Add(AValues[I].FImpl);
end;

function TValueArray.AsArray: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF};
var
  I: Integer;
begin
  SetLength(Result, FCount);
  for I := 0 to FCount - 1 do
    Result[I].FImpl := FItems[I];
end;

procedure TValueArray.Clear;
begin
  FItems := nil;
  FCount := 0;
end;

function TValueArray.Clone: TRESTDWBsonValue._IValue;
var
  A: PValueArray;
  I: Integer;
begin
  Result := TValueArray.Create(FCount);
  A := PValueArray(Result);
  for I := 0 to FCount - 1 do
    A^.Add(FItems[I]);
end;

function TValueArray.Contains(const AValue: TRESTDWBsonValue): Boolean;
var
  I: Integer;
  Item: TRESTDWBsonValue;
begin
  for I := 0 to FCount - 1 do
  begin
    Item.FImpl := FItems[I];
    if (Item = AValue) then
      Exit(True);
  end;
  Result := False;
end;

class function TValueArray.Create(
  const AValues: array of TRESTDWBsonValue): TRESTDWBsonArray._IArray;
begin
  Result := Create(Length(AValues));
  Result.AddRange(AValues);
end;

class function TValueArray.Create(
  const ACapacity: Integer): TRESTDWBsonArray._IArray;
var
  V: PValueArray;
begin
  GetMem(V, SizeOf(TValueArray));
  V^.FBase.FVTable := @VTABLE_ARRAY;
  V^.FBase.FRefCount := 0;
  Pointer(V^.FItems) := nil;
  SetLength(V^.FItems, ACapacity);
  V^.FCount := 0;
  Result := TRESTDWBsonArray._IArray(V);
end;

class function TValueArray.Create(
  const AValues: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF}): TRESTDWBsonArray._IArray;
begin
  Result := Create(Length(AValues));
  Result.AddRange(AValues);
end;

function TValueArray.DeepClone: TRESTDWBsonValue._IValue;
var
  A: PValueArray;
  I: Integer;
begin
  Result := TValueArray.Create(FCount);
  A := PValueArray(Result);
  for I := 0 to FCount - 1 do
    A^.Add(FItems[I].DeepClone);
end;

procedure TValueArray.Delete(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);

  FItems[AIndex] := nil;

  Dec(FCount);
  if (AIndex <> FCount) then
  begin
    Move(FItems[AIndex + 1], FItems[AIndex], (FCount - AIndex) * SizeOf(TRESTDWBsonValue._IValue));
    FillChar(FItems[FCount], SizeOf(TRESTDWBsonValue), 0);
  end;
end;

function TValueArray.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  Other: {$IFNDEF FPC}TArray<TRESTDWBsonValue>{$ELSE}TRESTDWArrayBsonValue{$ENDIF};
  Item: TRESTDWBsonValue;
  I: Integer;
begin
  if (AOther.BsonType = TRESTDWBsonType.&Array) then
  begin
    Other := AOther.AsArray;
    Result := (FCount = Length(Other));
    if (Result) then
    begin
      for I := 0 to FCount - 1 do
      begin
        Item.FImpl := FItems[I];
        if (Item <> Other[I]) then
          Exit(False);
      end;
    end;
  end
  else
    Result := False;
end;

function TValueArray.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.&Array;
end;

function TValueArray.GetCount: Integer;
begin
  Result := FCount;
end;

procedure TValueArray.GetItem(const AIndex: Integer;
  out AValue: TRESTDWBsonValue._IValue);
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  AValue := FItems[AIndex];
end;

function TValueArray.IndexOf(const AValue: TRESTDWBsonValue): Integer;
var
  I: Integer;
  Item: TRESTDWBsonValue;
begin
  for I := 0 to FCount - 1 do
  begin
    Item.FImpl := FItems[I];
    if (Item = AValue) then
      Exit(I);
  end;
  Result := -1;
end;

function TValueArray.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  {$IFNDEF FPC}
  if (IID = TRESTDWBsonArray._IArray) then
  begin
  {$ENDIF}
    TRESTDWBsonArray._IArray(Obj) := TRESTDWBsonArray._IArray(@Self);
    Result := S_OK;
  {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
  {$ENDIF}
end;

function TValueArray.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FItems := nil;
    FreeMem(@Self);
  end;
end;

function TValueArray.Remove(const AValue: TRESTDWBsonValue): Boolean;
var
  Index: Integer;
begin
  if (AValue.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);
  Index := IndexOf(AValue);
  Result := (Index >= 0);
  if (Result) then
    Delete(Index);
end;

procedure TValueArray.SetItem(const AIndex: Integer;
  const AValue: TRESTDWBsonValue._IValue);
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);
  FItems[AIndex] := AValue;
end;

{ TValueBinaryData }

function TValueBinaryData.AsByteArray: TBytes;
begin
  Result := FValue;
end;

function TValueBinaryData.AsGuid: TGUID;
begin
  case FSubType of
    TRESTDWBsonBinarySubType.UuidLegacy:
      Result := TGUID.Create(FValue, TEndian.Little);

    TRESTDWBsonBinarySubType.UuidStandard:
      Result := TGUID.Create(FValue, TEndian.Big);
  else
    raise EIntfCastError.Create('Invalid cast (AsGuid)');
  end;
end;

class function TValueBinaryData.Create(const AValue: TBytes;
  const ASubType: TRESTDWBsonBinarySubType): TRESTDWBsonBinaryData._IBinaryData;
var
  V: PValueBinaryData;
begin
  GetMem(V, SizeOf(TValueBinaryData));
  V^.FBase.FVTable := @VTABLE_BINARY_DATA;
  V^.FBase.FRefCount := 0;
  Pointer(V^.FValue) := nil;
  V^.FValue := AValue;
  V^.FSubType := ASubType;
  Result := TRESTDWBsonBinaryData._IBinaryData(V);
end;

class function TValueBinaryData.Create: TRESTDWBsonBinaryData._IBinaryData;
begin
  Result := Create(nil);
end;

class function TValueBinaryData.Create(
  const AValue: TGUID): TRESTDWBsonBinaryData._IBinaryData;
begin
  Result := Create(AValue.ToByteArray(TEndian.Big), TRESTDWBsonBinarySubType.UuidStandard);
end;

function TValueBinaryData.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  Other: PValueBinaryData;
begin
  if (AOther.BsonType = TRESTDWBsonType.Binary) then
  begin
    Other := PValueBinaryData(AOther);
    Result := (FSubType = Other^.FSubType)
      and (Length(FValue) = Length(Other^.FValue))
      and (CompareMem(@FValue[0], @Other^.FValue[0], Length(FValue)));
  end
  else
    Result := False;
end;

function TValueBinaryData.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Binary;
end;

function TValueBinaryData.GetByte(const AIndex: Integer): Byte;
begin
  if (AIndex < 0) or (AIndex >= Length(FValue)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  Result := FValue[AIndex];
end;

function TValueBinaryData.GetAsBytes: TBytes;
begin
  Result := FValue;
end;

function TValueBinaryData.GetCount: Integer;
begin
  Result := Length(FValue);
end;

function TValueBinaryData.GetSubType: TRESTDWBsonBinarySubType;
begin
  Result := FSubType;
end;

function TValueBinaryData.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  {$IFNDEF FPC}
  if (IID = TRESTDWBsonBinaryData._IBinaryData) then
  begin
  {$ENDIF}
    TRESTDWBsonBinaryData._IBinaryData(Obj) := TRESTDWBsonBinaryData._IBinaryData(@Self);
    Result := S_OK;
  {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
  {$ENDIF}
end;

function TValueBinaryData.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FValue := nil;
    FreeMem(@Self);
  end;
end;

procedure TValueBinaryData.SetByte(const AIndex: Integer; const AValue: Byte);
begin
  if (AIndex < 0) or (AIndex >= Length(FValue)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  FValue[AIndex] := AValue;
end;

function TValueBinaryData.ToByteArray: TBytes;
begin
  Result := FValue;
end;

function TValueBinaryData.ToGuid: TGUID;
begin
 Case FSubType of
   TRESTDWBsonBinarySubType.UuidLegacy   : Result := TGUID.Create(FValue, TEndian.Little);
   TRESTDWBsonBinarySubType.UuidStandard : Result := TGUID.Create(FValue, TEndian.Big);
  Else
   Begin
    {$IFNDEF FPC}
     Result := TGUID.Empty;
    {$ELSE}
     FillChar(Result, Sizeof(Result), 0);
    {$ENDIF}
   End;
 End;
end;

{ TValueDocument }

procedure TValueDocument.Add(const AName: String;
  const AValue: TRESTDWBsonValue._IValue);
var
  IsDuplicate: Boolean;
  Capacity: Integer;
begin
  IsDuplicate := (IndexOfName(AName) >= 0);
  if (IsDuplicate) and (not FAllowDuplicateNames) then
    raise EInvalidOperation.CreateRes(@SGenericDuplicateItem);

  Capacity := Length(FElements);
  if (FCount >= Capacity) then
  begin
    if (Capacity > 64) then
      Inc(Capacity, Capacity div 4)
    else if (Capacity > 8) then
      Inc(Capacity, 16)
    else
      Inc(Capacity, 4);
    SetLength(FElements, Capacity);
  end;
  FElements[FCount].FName := AName;
  FElements[FCount].FImpl := AValue;
  Inc(FCount);

  if (not IsDuplicate) then
  begin
    if (FIndices = nil) then
      RebuildIndices
    else
      FIndices^.Add(AName, FCount - 1);
  end;
end;

procedure TValueDocument.Clear;
begin
  FElements := nil;
  if (FIndices <> nil) then
  begin
    FIndices^.Release;
    FIndices := nil;
  end;
  FCount := 0;
end;

function TValueDocument.Clone: TRESTDWBsonValue._IValue;
var
  D: PValueDocument;
  I: Integer;
begin
  Result := TValueDocument.Create;
  D := PValueDocument(Result);
  for I := 0 to FCount - 1 do
   D^.Add(FElements[I].FName, FElements[I].FImpl);
end;

function TValueDocument.Contains(const AName: String): Boolean;
begin
  Result := (IndexOfName(AName) <> -1);
end;

function TValueDocument.ContainsValue(const AValue: TRESTDWBsonValue): Boolean;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    if (FElements[I].Value = AValue) then
      Exit(True);
  end;
  Result := False;
end;

class function TValueDocument.Create(
  const AAllowDuplicateNames: Boolean): TRESTDWBsonDocument._IDocument;
var
  V: PValueDocument;
begin
  GetMem(V, SizeOf(TValueDocument));
  V^.FBase.FVTable := @VTABLE_DOCUMENT;
  V^.FBase.FRefCount := 0;
  V^.FAllowDuplicateNames := AAllowDuplicateNames;
  Pointer(V^.FElements) := nil;
  Pointer(V^.FIndices) := nil;
  V^.FCount := 0;
  Result := TRESTDWBsonDocument._IDocument(V);
end;

class function TValueDocument.Create(
  const AElement: TRESTDWBsonElement): TRESTDWBsonDocument._IDocument;
begin
  Result := Create;
  Result.Add(AElement.FName, AElement.FImpl);
end;

class function TValueDocument.Create(const AName: String;
  const AValue: TRESTDWBsonValue): TRESTDWBsonDocument._IDocument;
begin
  Result := Create;
  Result.Add(AName, AValue.FImpl);
end;

function TValueDocument.DeepClone: TRESTDWBsonValue._IValue;
var
  D: PValueDocument;
  I: Integer;
  E: TRESTDWBsonElement;
begin
  Result := TValueDocument.Create;
  D := PValueDocument(Result);
  for I := 0 to FCount - 1 do
  begin
    E := FElements[I].DeepClone;
    D^.Add(E.FName, E.FImpl);
  end;
end;

procedure TValueDocument.Delete(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= Length(FElements)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);

  FElements[AIndex] := Default(TRESTDWBsonElement);

  Dec(FCount);
  if (AIndex <> FCount) then
  begin
    Move(FElements[AIndex + 1], FElements[AIndex], (FCount - AIndex) * SizeOf(TRESTDWBsonElement));
    FillChar(FElements[FCount], SizeOf(TRESTDWBsonElement), 0);
  end;
end;

function TValueDocument.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  Other: PValueDocument;
  I: Integer;
begin
  if (AOther.BsonType = TRESTDWBsonType.Document) then
  begin
    Other := PValueDocument(AOther);
    Result := (FCount = Other^.FCount);
    for I := 0 to FCount - 1 do
    begin
      if (FElements[I] <> Other^.FElements[I]) then
        Exit(False);
    end;
  end
  else
    Result := False;
end;

procedure TValueDocument.Get(const AName: String;
  const ADefault: TRESTDWBsonValue._IValue; out AValue: TRESTDWBsonValue._IValue);
var
  Index: Integer;
begin
  Index := IndexOfName(AName);
  if (Index < 0) then
    AValue := ADefault
  else
    AValue := FElements[Index].FImpl;
end;

function TValueDocument.GetAllowDuplicateNames: Boolean;
begin
  Result := FAllowDuplicateNames;
end;

function TValueDocument.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Document;
end;

function TValueDocument.GetCount: Integer;
begin
  Result := FCount;
end;

function TValueDocument.GetElement(const AIndex: Integer): TRESTDWBsonElement;
begin
  if (AIndex < 0) or (AIndex >= Length(FElements)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  Result := FElements[AIndex];
end;

procedure TValueDocument.GetValue(const AIndex: Integer;
  out AValue: TRESTDWBsonValue._IValue);
begin
  if (AIndex < 0) or (AIndex >= Length(FElements)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  AValue := FElements[AIndex].FImpl;
end;

procedure TValueDocument.GetValueByName(const AName: String;
  out AValue: TRESTDWBsonValue._IValue);
var
  Index: Integer;
begin
  Index := IndexOfName(AName);
  if (Index < 0) then
    AValue := TRESTDWBsonNull.Value._Value
  else
    AValue := FElements[Index].FImpl;
end;

function TValueDocument.IndexOfName(const AName: String): Integer;
var
  I: Integer;
begin
  if (FIndices = nil) then
  begin
    for I := 0 to Length(FElements) - 1 do
    begin
      if (FElements[I].Name = AName) then
        Exit(I);
    end;
    Result := -1;
  end
  else
    Result := FIndices^.Get(AName);
end;

procedure TValueDocument.Merge(const AOtherDocument: TRESTDWBsonDocument;
  const AOverwriteExistingElements: Boolean);
var
  Element: TRESTDWBsonElement;
begin
  if (AOtherDocument.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  for Element in AOtherDocument do
  begin
    if (AOverwriteExistingElements) or (not Contains(Element.Name)) then
      SetValueByName(Element.Name, Element.FImpl);
  end;
end;

function TValueDocument.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 {$IFNDEF FPC}
  if (IID = TRESTDWBsonDocument._IDocument) then
  begin
 {$ENDIF}
    TRESTDWBsonDocument._IDocument(Obj) := TRESTDWBsonDocument._IDocument(@Self);
    Result := S_OK;
 {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
 {$ENDIF}
end;

procedure TValueDocument.RebuildIndices;
var
  I: Integer;
begin
  if (FCount < INDICES_COUNT_THRESHOLD) then
  begin
    if (FIndices <> nil) then
    begin
      FIndices^.Release;
      FIndices := nil;
    end;
    Exit;
  end;

  if (FIndices = nil) then
  begin
    GetMem(FIndices, SizeOf(TIndexMap));
    FillChar(FIndices^, SizeOf(TIndexMap), 0);
  end
  else
    FIndices^.Clear;

  { Process the elements in reverse order so that in case of duplicates the
    dictionary ends up pointing at the first one }
  for I := FCount - 1 downto 0 do
    FIndices^.Add(FElements[I].Name, I);
end;

function TValueDocument.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FElements := nil;
    if (FIndices <> nil) then
      FIndices^.Release;
    FreeMem(@Self);
  end;
end;

procedure TValueDocument.Remove(const AName: String);
var
  RemovedAny: Boolean;
  I: Integer;
begin
  if (FAllowDuplicateNames) then
  begin
    RemovedAny := False;
    for I := FCount - 1 downto 0 do
    begin
      if (FElements[I].Name = AName) then
      begin
        Delete(I);
        RemovedAny := True;
      end;
    end;

    if (RemovedAny) then
      RebuildIndices;
  end
  else
  begin
    I := IndexOfName(AName);
    if (I >= 0) then
    begin
      Delete(I);
      RebuildIndices;
    end;
  end;
end;

procedure TValueDocument.SetAllowDuplicateNames(const AValue: Boolean);
begin
  FAllowDuplicateNames := AValue;
end;

procedure TValueDocument.SetValue(const AIndex: Integer;
  const AValue: TRESTDWBsonValue._IValue);
begin
  if (AIndex < 0) or (AIndex >= Length(FElements)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);
  FElements[AIndex].FImpl := AValue;
end;

procedure TValueDocument.SetValueByName(const AName: String;
  const AValue: TRESTDWBsonValue._IValue);
var
  Index: Integer;
begin
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  Index := IndexOfName(AName);
  if (Index < 0) then
    Add(AName, AValue)
  else
    FElements[Index].FImpl := AValue;
end;

function TValueDocument.ToArray: TRESTDWArrayBsonElement;
begin
  SetLength(FElements, FCount);
  Result := FElements;
end;

function TValueDocument.TryGetElement(const AName: String;
  out AElement: TRESTDWBsonElement): Boolean;
var
  Index: Integer;
begin
  Index := IndexOfName(AName);
  if (Index < 0) then
  begin
    AElement := Default(TRESTDWBsonElement);
    Result := False;
  end
  else
  begin
    AElement := FElements[Index];
    Result := True;
  end;
end;

function TValueDocument.TryGetValue(const AName: String;
  out AValue: TRESTDWBsonValue._IValue): Boolean;
var
  Index: Integer;
begin
  Index := IndexOfName(AName);
  if (Index < 0) then
  begin
    AValue := nil;
    Result := False;
  end
  else
  begin
    AValue := FElements[Index].FImpl;
    Result := True;
  end;
end;

{ TValueDocument.TIndexMap }

procedure TValueDocument.TIndexMap.Add(const AName: String;
  const AIndex: Integer);
var
  Mask, Index, HashCode, HC: Integer;
begin
  if (FCount >= FGrowThreshold) then
    Resize(Length(FEntries) * 2);

  HashCode := goMurmurHash2(Pointer(AName)^, Length(AName) * SizeOf(Char)) and $7FFFFFFF;
  Mask := Length(FEntries) - 1;
  Index := HashCode and Mask;

  while True do
  begin
    HC := FEntries[Index].HashCode;
    if (HC = EMPTY_HASH) then
      Break;

    if (HC = HashCode) and (FEntries[Index].Name = AName) then
    begin
      FEntries[Index].Index := AIndex;
      Exit;
    end;

    Index := (Index + 1) and Mask;
  end;

  FEntries[Index].HashCode := HashCode;
  FEntries[Index].Name := AName;
  FEntries[Index].Index := AIndex;
  Inc(FCount);
end;

procedure TValueDocument.TIndexMap.Clear;
begin
  FEntries := nil;
  FCount := 0;
  FGrowThreshold := 0;
end;

function TValueDocument.TIndexMap.Get(const AName: String): Integer;
var
  Mask, Index, HashCode, HC: Integer;
begin
  if (FCount = 0) then
    Exit(-1);

  Mask := Length(FEntries) - 1;
  HashCode := goMurmurHash2(Pointer(AName)^, Length(AName) * SizeOf(Char)) and $7FFFFFFF;
  Index := HashCode and Mask;

  while True do
  begin
    HC := FEntries[Index].HashCode;
    if (HC = EMPTY_HASH) then
      Exit(-1);

    if (HC = HashCode) and (FEntries[Index].Name = AName) then
      Exit(FEntries[Index].Index);

    Index := (Index + 1) and Mask;
  end;
end;

procedure TValueDocument.TIndexMap.Release;
begin
  FEntries := nil;
  FreeMem(@Self);
end;

procedure TValueDocument.TIndexMap.Resize(ANewSize: Integer);
var
  NewMask, I, NewIndex: Integer;
  OldEntries, NewEntries: TMapEntries;
begin
  if (ANewSize < 4) then
    ANewSize := 4;
  NewMask := ANewSize - 1;
  SetLength(NewEntries, ANewSize);
  for I := 0 to ANewSize - 1 do
    NewEntries[I].HashCode := EMPTY_HASH;
  OldEntries := FEntries;

  for I := 0 to Length(OldEntries) - 1 do
  begin
    if (OldEntries[I].HashCode <> EMPTY_HASH) then
    begin
      NewIndex := OldEntries[I].HashCode and NewMask;
      while (NewEntries[NewIndex].HashCode <> EMPTY_HASH) do
        NewIndex := (NewIndex + 1) and NewMask;
      NewEntries[NewIndex] := OldEntries[I];
    end;
  end;

  FEntries := NewEntries;
  FGrowThreshold := (ANewSize * 3) shr 2; // 75%
end;

{ TValueNull }

function TValueNull.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  Result := (AOther.BsonType = TRESTDWBsonType.Null);
end;

function TValueNull.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Null;
end;

function TValueNull.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 {$IFNDEF FPC}
  if (IID = TRESTDWBsonNull._INull) then
  begin
 {$ENDIF}
    TRESTDWBsonNull._INull(Obj) := TRESTDWBsonNull._INull(@VALUE_NULL);
    Result := S_OK;
 {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
 {$ENDIF}
end;

function TValueNull.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueNull.ToString(const ADefault: String): String;
begin
  Result := 'null';
end;

{ TValueUndefined }

function TValueUndefined.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  Result := (AOther.BsonType = TRESTDWBsonType.Undefined);
end;

function TValueUndefined.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Undefined;
end;

function TValueUndefined.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 {$IFNDEF FPC}
  if (IID = TRESTDWBsonUndefined._IUndefined) then
  begin
 {$ENDIF}
    TRESTDWBsonUndefined._IUndefined(Obj) := TRESTDWBsonUndefined._IUndefined(@VALUE_UNDEFINED);
    Result := S_OK;
 {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
 {$ENDIF}
end;

function TValueUndefined.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueUndefined.ToString(const ADefault: String): String;
begin
  Result := 'undefined';
end;

{ TValueObjectId }

function TValueObjectId.AsObjectId: TRESTDWObjectId;
begin
  Result := FValue;
end;

class function TValueObjectId.Create(
  const AValue: TRESTDWObjectId): TRESTDWBsonValue._IValue;
var
  V: PValueObjectId;
begin
  GetMem(V, SizeOf(TValueObjectId));
  V^.FBase.FVTable := @VTABLE_OBJECT_ID;
  V^.FBase.FRefCount := 0;
  V^.FValue := AValue;
  Result := TRESTDWBsonValue._IValue(V);
end;

function TValueObjectId.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TRESTDWBsonType.ObjectId) then
    Result := (FValue = AOther.AsObjectId)
  else
    Result := False;
end;

function TValueObjectId.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.ObjectId;
end;

function TValueObjectId.ToObjectId: TRESTDWObjectId;
begin
  Result := FValue;
end;

function TValueObjectId.ToString(const ADefault: String): String;
begin
  Result := FValue.ToString;
end;

{ TValueRegularExpression }

class function TValueRegularExpression.Create(
  const APattern: String): TRESTDWBsonRegularExpression._IRegularExpression;
var
  Index: Integer;
  Escaped, Unescaped, Pattern, Options: String;
begin
  if (APattern <> '') and (APattern.Chars[0] = '/') then
  begin
    Index := APattern.LastIndexOf('/');
    Escaped := APattern.Substring(1, Index - 1);
    if (Escaped = '(?:)') then
      Unescaped := ''
    else
      Unescaped := Escaped.Replace('\/', '/', [rfReplaceAll]);
    Pattern := Unescaped;
    Options := APattern.Substring(Index + 1);
  end
  else
  begin
    Pattern := APattern;
    Options := '';
  end;
  Result := Create(Pattern, Options);
end;

class function TValueRegularExpression.Create(const APattern,
  AOptions: String): TRESTDWBsonRegularExpression._IRegularExpression;
var
  V: PValueRegularExpression;
begin
  GetMem(V, SizeOf(TValueRegularExpression));
  V^.FBase.FVTable := @VTABLE_REGULAR_EXPRESSION;
  V^.FBase.FRefCount := 0;
  Pointer(V^.FPattern) := nil;
  Pointer(V^.FOptions) := nil;
  V^.FPattern := APattern;
  V^.FOptions := AOptions;
  Result := TRESTDWBsonRegularExpression._IRegularExpression(V);
end;

function TValueRegularExpression.Equals(
  const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  Other: PValueRegularExpression;
begin
  if (AOther.BsonType = TRESTDWBsonType.RegularExpression) then
  begin
    Other := PValueRegularExpression(AOther);
    Result := (FPattern = Other^.FPattern) and (FOptions = Other^.FOptions);
  end
  else
    Result := False;
end;

function TValueRegularExpression.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.RegularExpression;
end;

function TValueRegularExpression.GetOptions: String;
begin
  Result := FOptions;
end;

function TValueRegularExpression.GetPattern: String;
begin
  Result := FPattern;
end;

function TValueRegularExpression.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
 {$IFNDEF FPC}
  if (IID = TRESTDWBsonRegularExpression._IRegularExpression) then
  begin
 {$ENDIF}
    TRESTDWBsonRegularExpression._IRegularExpression(Obj) := TRESTDWBsonRegularExpression._IRegularExpression(@Self);
    Result := S_OK;
 {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
 {$ENDIF}
end;

function TValueRegularExpression.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FPattern := '';
    FOptions := '';
    FreeMem(@Self);
  end;
end;

{ TValueJavaScript }

class function TValueJavaScript.Create(
  const ACode: String): TRESTDWBsonJavaScript._IJavaScript;
var
  V: PValueJavaScript;
begin
  GetMem(V, SizeOf(TValueJavaScript));
  V^.FBase.FVTable := @VTABLE_JAVA_SCRIPT;
  V^.FBase.FRefCount := 0;
  Pointer(V^.FCode) := nil;
  V^.FCode := ACode;
  Result := TRESTDWBsonJavaScript._IJavaScript(V);
end;

function TValueJavaScript.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  Other: PValueJavaScript;
begin
  if (AOther.BsonType = TRESTDWBsonType.JavaScript) then
  begin
    Other := PValueJavaScript(AOther);
    Result := (FCode = Other^.FCode);
  end
  else
    Result := False;
end;

function TValueJavaScript.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.JavaScript;
end;

function TValueJavaScript.GetCode: String;
begin
  Result := FCode;
end;

function TValueJavaScript.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  {$IFNDEF FPC}
  if (IID = TRESTDWBsonJavaScript._IJavaScript) then
  begin
  {$ENDIF}
    TRESTDWBsonJavaScript._IJavaScript(Obj) := TRESTDWBsonJavaScript._IJavaScript(@Self);
    Result := S_OK;
  {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
  {$ENDIF}
end;

function TValueJavaScript.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FCode := '';
    FreeMem(@Self);
  end;
end;

{ TValueJavaScriptWithScope }

function TValueJavaScriptWithScope.Clone: TRESTDWBsonValue._IValue;
begin
  Result := TValueJavaScriptWithScope.Create(FBase.FCode, FScope.Clone);
end;

class function TValueJavaScriptWithScope.Create(const ACode: String;
  const AScope: TRESTDWBsonDocument): TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope;
var
  V: PValueJavaScriptWithScope;
begin
  if (AScope.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  GetMem(V, SizeOf(TValueJavaScriptWithScope));
  V^.FBase.FBase.FVTable := @VTABLE_JAVA_SCRIPT_WITH_SCOPE;
  V^.FBase.FBase.FRefCount := 0;
  Pointer(V^.FBase.FCode) := nil;
  V^.FBase.FCode := ACode;
  Pointer(V^.FScope) := nil;
  V^.FScope := AScope;

  Result := TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope(V);
end;

function TValueJavaScriptWithScope.DeepClone: TRESTDWBsonValue._IValue;
begin
  Result := TValueJavaScriptWithScope.Create(FBase.FCode, FScope.DeepClone);
end;

function TValueJavaScriptWithScope.Equals(
  const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  Other: PValueJavaScriptWithScope;
begin
  if (AOther.BsonType = TRESTDWBsonType.JavaScriptWithScope) then
  begin
    Other := PValueJavaScriptWithScope(AOther);
    Result := (FBase.FCode = Other^.FBase.FCode) and (FScope = Other^.FScope);
  end
  else
    Result := False;
end;

function TValueJavaScriptWithScope.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.JavaScriptWithScope;
end;

function TValueJavaScriptWithScope.GetScope: TRESTDWBsonDocument;
begin
  Result := FScope;
end;

function TValueJavaScriptWithScope.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  {$IFNDEF FPC}
  if (IID = TRESTDWBsonJavaScript._IJavaScript)
    or (IID = TRESTDWBsonJavaScriptWithScope._IJavaScriptWithScope) then
  begin
  {$ENDIF}
    TRESTDWBsonJavaScript._IJavaScript(Obj) := TRESTDWBsonJavaScript._IJavaScript(@Self);
    Result := S_OK;
  {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
  {$ENDIF}
end;

function TValueJavaScriptWithScope.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FBase.FRefCount);
  if (Result = 0) then
  begin
    FBase.FCode := '';
    FScope.FImpl := nil;
    FreeMem(@Self);
  end;
end;

{ TValueSymbol }

class function TValueSymbol.Create(const AName: String): TRESTDWBsonSymbol._ISymbol;
var
  V: PValueSymbol;
begin
  GetMem(V, SizeOf(TValueSymbol));
  V^.FBase.FVTable := @VTABLE_SYMBOL;
  V^.FBase.FRefCount := 0;
  Pointer(V^.FName) := nil;
  V^.FName := AName;
  Result := TRESTDWBsonSymbol._ISymbol(V);
end;

function TValueSymbol.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  Other: PValueSymbol;
begin
  if (AOther.BsonType = TRESTDWBsonType.Symbol) then
  begin
    Other := PValueSymbol(AOther);
    Result := (FName = Other^.FName);
  end
  else
    Result := False;
end;

function TValueSymbol.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Symbol;
end;

function TValueSymbol.GetName: String;
begin
  Result := FName;
end;

function TValueSymbol.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 {$IFNDEF FPC}
  if (IID = TRESTDWBsonSymbol._ISymbol) then
  begin
 {$ENDIF}
    TRESTDWBsonSymbol._ISymbol(Obj) := TRESTDWBsonSymbol._ISymbol(@Self);
    Result := S_OK;
 {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
 {$ENDIF}
end;

function TValueSymbol.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FName := '';
    FreeMem(@Self);
  end;
end;

function TValueSymbol.ToString(const ADefault: String): String;
begin
  Result := FName;
end;

{ TValueTimestamp }

class function TValueTimestamp.Create(
  const AValue: Int64): TRESTDWBsonTimestamp._ITimestamp;
var
  V: PValueTimestamp;
begin
  GetMem(V, SizeOf(TValueTimestamp));
  V^.FBase.FVTable := @VTABLE_TIMESTAMP;
  V^.FBase.FRefCount := 0;
  V^.FValue := AValue;
  Result := TRESTDWBsonTimestamp._ITimestamp(V);
end;

class function TValueTimestamp.Create(const ATimestamp,
  AIncrement: Integer): TRESTDWBsonTimestamp._ITimestamp;
begin
  Result := Create((UInt64(ATimestamp) shl 32) or UInt32(AIncrement));
end;

function TValueTimestamp.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
var
  Other: PValueTimestamp;
begin
  if (AOther.BsonType = TRESTDWBsonType.Timestamp) then
  begin
    Other := PValueTimestamp(AOther);
    Result := (FValue = Other^.FValue);
  end
  else
    Result := False;
end;

function TValueTimestamp.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.Timestamp;
end;

function TValueTimestamp.GetIncrement: Integer;
begin
  Result := Integer(FValue);
end;

function TValueTimestamp.GetTimestamp: Integer;
begin
  Result := Integer(FValue shr 32);
end;

function TValueTimestamp.GetValue: Int64;
begin
  Result := FValue;
end;

function TValueTimestamp.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 {$IFNDEF FPC}
  if (IID = TRESTDWBsonTimestamp._ITimestamp) then
  begin
 {$ENDIF}
    TRESTDWBsonTimestamp._ITimestamp(Obj) := TRESTDWBsonTimestamp._ITimestamp(@Self);
    Result := S_OK;
 {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
 {$ENDIF}
end;

{ TValueMaxKey }

function TValueMaxKey.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  Result := (AOther.BsonType = TRESTDWBsonType.MaxKey);
end;

function TValueMaxKey.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.MaxKey;
end;

function TValueMaxKey.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 {$IFNDEF FPC}
  if (IID = TRESTDWBsonMaxKey._IMaxKey) then
  begin
 {$ENDIF}
    TRESTDWBsonMaxKey._IMaxKey(Obj) := TRESTDWBsonMaxKey._IMaxKey(@VALUE_MAX_KEY);
    Result := S_OK;
 {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
 {$ENDIF}
end;

function TValueMaxKey.ToString(const ADefault: String): String;
begin
  Result := 'MaxKey';
end;

{ TValueMinKey }

function TValueMinKey.Equals(const AOther: TRESTDWBsonValue._IValue): Boolean;
begin
  Result := (AOther.BsonType = TRESTDWBsonType.MinKey);
end;

function TValueMinKey.GetBsonType: TRESTDWBsonType;
begin
  Result := TRESTDWBsonType.MinKey;
end;

function TValueMinKey.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
 {$IFNDEF FPC}
  if (IID = TRESTDWBsonMinKey._IMinKey) then
  begin
 {$ENDIF}
    TRESTDWBsonMinKey._IMinKey(Obj) := TRESTDWBsonMinKey._IMinKey(@VALUE_MIN_KEY);
    Result := S_OK;
 {$IFNDEF FPC}
  end
  else
    Result := E_NOINTERFACE;
 {$ENDIF}
end;

function TValueMinKey.ToString(const ADefault: String): String;
begin
  Result := 'MinKey';
end;

end.
