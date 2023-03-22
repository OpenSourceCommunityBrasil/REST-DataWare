unit uRESTDWJSON;

{$I ..\..\Includes\uRESTDW.inc}

Interface

Uses
 {$IF Defined(RESTDWLAZARUS) AND not Defined(RESTDWLAMW)}
   LCL,
 {$ELSEIF Defined(RESTDWWINDOWS)}
   Windows,
 {$IFEND}
  SysUtils, Classes, TypInfo, uRESTDWTools;

Type

 { TStringListJSON }

 TStringListJSON = Class(TStringList)
 Public
  Constructor Create;
  Destructor Destroy;Override;
End;

Type
    {
    @abstract(Classe pai de todas as classes em uJSON , resolve o problema de
    impedância entre a classe java Object e a classe delphi TObject)
    }
    TZAbstractObject = class
      { retorna true se value é igual ao objeto}
      function equals(const Value: TZAbstractObject): Boolean; virtual;
      { código hash do objeto , usa-se o endereço de memória}
      function hash: LongInt;
      { clona o objeto
       @return ( um TZAbstractObject )}
      function Clone: TZAbstractObject; virtual;
      {retorna a representação com string do objeto
       @return (uma string)}
      function toString: string; virtual;
      {retorna true se o parâmetro Value é uma instância de TZAbstractObject }
      function instanceOf(const Value: TZAbstractObject): Boolean;
    end;

    { @abstract(wrapper para ClassCastException do java) }
    ClassCastException = class (Exception) end;
    { @abstract(wrapper para NoSuchElementException do java) }
    NoSuchElementException = class (Exception) end;
    { @abstract(wrapper para NumberFormatException do java) }
    NumberFormatException = class (Exception) end;
    { @abstract(wrapper para NullPointerException do java) }
    NullPointerException = class (Exception) end;
    { @abstract(as features não implementadas geram esta exception) }
    NotImplmentedFeature = class (Exception) end;
    PJSONArray = ^TJSONArray;
    TJSONArray = class ;
    _Number =  class ;
    _String = class;
    _Double = class;
    NULL = class ;

    { @abstract(exception gerada quando ocorre um erro de parsing) }
    ParseException = class (Exception)
       constructor create (_message : string ; index : integer);
    end;

    (**
      @abstract(Responsável por auxiliar na análise Léxica de uma string que representa um JSON.)
    *)
    JSONTokener = class  (TZAbstractObject)
     public
       (**
        Construct a JSONTokener from a string.
        @param(s A source string.)     *)
       constructor create (s: string) ;

       (**
        Back up one character. This provides a sort of lookahead capability,
        so that you can test for a digit or letter before attempting to parse
        the next number or identifier.
       *)
       procedure back();
       (**
        Get the hex value of a character (base16).
        @param(c A character between '0' and '9' or between 'A' and 'F' or
        between 'a' and 'f'.)
        @return(An int between 0 and 15, or -1 if c was not a hex digit.)
       *)
       class function dehexchar(c : char) :integer;
       function more :boolean;
       function next() : char; overload ;
       function next (c:char ) : char; overload ;
       function next (n:integer) : string; overload ;
       function nextClean () : char;
       function nextString (quote : char) : string;
       function nextTo (d : char) : string;  overload ;
       function nextTo (delimiters : string) : char;   overload ;
       function nextValue () : TZAbstractObject ;
       procedure skipPast (_to : string ) ;
       function skipTo (_to : char ): char;
       function syntaxError (_message : string) : ParseException;
       function toString : string;  override;
       function unescape (s : string): string;
    private
      myIndex : integer;
      mySource : string;
    end;

  { @abstract(Classe que representa um objeto JSON) }
  TJSONObject = class (TZAbstractObject)
  private
    myHashMap : TStringListJSON;
    ja :TJSONArray;
  public
    (**
      Construct an empty TJSONObject.
    *)
    constructor create;  overload;

    (**
      Construct a TJSONObject from a subset of another TJSONObject.
      An array of strings is used to identify the keys that should be copied.
      Missing keys are ignored.
      @param(jo A TJSONObject.)
      @param(sa An array of strings).
     *)
    constructor create  (jo : TJSONObject; sa : array of string); overload;
    (**
      Construct a TJSONObject from a JSONTokener.
      @param(x A JSONTokener object containing the source string.)
      @raises(ParseException if there is a syntax error in the source string.)
    *)
    constructor create (x : JSONTokener); overload;
    (**
      Construct a TJSONObject from a TStringList.
      @param(map A map object that can be used to initialize the contents of
       the TJSONObject.)
     *)
    constructor create (map : TStringList); overload;
    (**
     Construct a TJSONObject from a string.
     This is the most commonly used TJSONObject constructor.
     @param(s @html(A string beginning
     with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     with <code>}</code>&nbsp;<small>(right brace)</small>.))
     @raises(ParseException The string must be properly formatted.)
    *)
    constructor create (s : string); overload;

    (**
       remove todos os menbros de um objeto JSON  .
    *)
    procedure clean;
    (**
      sobreescreve o metodo clone de  TZAbstractObject
    *)
    function clone               : TZAbstractObject;   override;
    function accumulate   (key   : string;
                           value : TZAbstractObject) : TJSONObject;
    function get          (key   : string)           : TZAbstractObject;
    function getBoolean   (key   : string)           : Boolean;
    function getDouble    (key   : string)           : Double;
    function getInt       (key   : string)           : Integer;
    function getInt64     (key   : string)           : Int64;
    function getJSONArray (key   : string)           : TJSONArray;
    function getJSONObject(key   : string)           : TJSONObject;
    function getString    (key   : string)           : String;
    function has          (key   : string)           : Boolean;
    function isNull       (key   : string)           : Boolean;
    (**
      retorna um TStringList com todos os nomes dos atributos do TJSONObject
    *)
    function keys : TStringList;
    (**
      Retorna quantos atributos tem o TJSONObject
    *)
    function length : integer;
    (**
     Produce a TJSONArray containing the names of the elements of this
     TJSONObject.
     @return(A TJSONArray containing the key strings, or null if the TJSONObject
     is empty).
    *)
    function names : TJSONArray;
    (**
       transforma uma class wrapper _Number (Number em java) em AnsiString
    *)
    class function numberToString (n: _Number): string;
    (**
      Make JSON string of an object value.
      @html(<p>
      Warning: This method assumes that the data structure is acyclical.
      )
      @param(value The value to be serialized.)
      @return( @html(a printable, displayable, transmittable
       representation of the object, beginning
       with <code>{</code>&nbsp;<small>(left brace)</small> and ending
       with <code>}</code>&nbsp;<small>(right brace)</small>.))
     *)
    class function valueToString(value : TZAbstractObject) : string; overload;
    (**
      Make a prettyprinted JSON text of an object value.
      @html(
      <p>
      Warning: This method assumes that the data structure is acyclical.
      )
      @param(value The value to be serialized.)
      @param(indentFactor The number of spaces to add to each level of
       indentation.)
      @param(indent The indentation of the top level.)
      @return(@html(a printable, displayable, transmittable
       representation of the object, beginning
       with <code>{</code>&nbsp;<small>(left brace)</small> and ending
       with <code>}</code>&nbsp;<small>(right brace)</small>.))
     *)
    class function valueToString(value : TZAbstractObject; indentFactor
    , indent : integer) : string; overload;
    (**
      Get an optional value associated with a key.
      @param(key   A key string.)
      @return(An object which is the value, or null if there is no value.)
      @raises(NullPointerException caso key = '')
    *)
    function opt (key : string) : TZAbstractObject;
    function optBoolean (key : string): boolean; overload;
    function optBoolean (key : string; defaultValue : boolean): boolean; overload;
    function optDouble (key : string): double; overload;
    function optDouble (key : string; defaultValue : double): double; overload;
    function optInt (key : string): integer; overload;
    function optInt (key : string; defaultValue : integer): integer; overload;
    function optInt64 (key : string): Int64; overload;
    function optInt64 (key : string; defaultValue : Int64): Int64; overload;
    function optString (key : string): string; overload;
    function optString (key : string; defaultValue : string): string; overload;

    function optJSONArray (key : string): TJSONArray; overload;
    function optJSONObject (key : string): TJSONObject; overload;

    function put (key : string; value : boolean): TJSONObject; overload;
    function put (key : string; value : double): TJSONObject; overload;
    function put (key : string; value : integer): TJSONObject; overload;
    function put (key : string; value : Int64): TJSONObject; overload;
    function put (key : string; value : string): TJSONObject; overload;

    (**
      Put a key/value pair in the TJSONObject. If the value is null,
      then the key will be removed from the TJSONObject if it is present.
      @param(key   A key string.)
      @param(value An object which is the value. It should be of one of these
       types: Boolean, Double, Integer, TJSONArray, TJSONObject, String, or the
       TJSONObject.NULL object.)
      @return(this.)
      @raises(NullPointerException The key must be non-null.)
    *)
    function put (key : string; value : TZAbstractObject): TJSONObject; overload;
    (**
      Put a key/value pair in the TJSONObject, but only if the
      value is non-null.
      @param(key   A key string.)
      @param(value An object which is the value. It should be of one of these
       types: Boolean, Double, Integer, TJSONArray, TJSONObject, String, or the
       TJSONObject.NULL object.)
      @return(this.)
      @raises(NullPointerException The key must be non-null.)
    *)
    function putOpt (key : string; value : TZAbstractObject): TJSONObject;
    class function quote (s : string): string;
    class function convertUTF8String(s: string): string;
    function remove (key : string): TZAbstractObject;
    procedure assignTo(json: TJSONObject);

    function toJSONArray (anames : TJSONArray) : TJSONArray;
    function toString (): string ;  overload; override;
    function toString (indentFactor : integer): string; overload;
    function toString (indentFactor, indent : integer): string; overload;

    destructor destroy;override;
    class function NULL : NULL;
  end;

  { @abstract(Trata um array JSON = [...])}
  TJSONArray = class (TZAbstractObject)
  public
    destructor destroy ; override;
    constructor create ; overload;
    constructor create (collection : TList); overload;
    constructor create (x : JSONTokener); overload;
    constructor create (s : string);  overload;
    function get (index : integer) : TZAbstractObject;
    function getBoolean (index : integer) : boolean;
    function getDouble (index : integer) : double;
    function getInt (index : integer): integer;
    function getInt64 (index : integer): Int64;
    {
      Get the TJSONArray associated with an index.
      @param(index The index must be between 0 and length() - 1.)
      @return(A TJSONArray value.)
      @raises(NoSuchElementException if the index is not found or if the
      value is not a TJSONArray)     }
    function getJSONArray (index : integer) : TJSONArray;
    function getJSONObject (index : integer) : TJSONObject;
    function getString (index : integer) : string;
    function isNull (index : integer): boolean;
    function join (separator : string) : string;
    function length : integer;
    function opt (index : integer) : TZAbstractObject;
    function optBoolean ( index : integer) : boolean; overload;
    function optBoolean ( index : integer; defaultValue : boolean) : boolean; overload;
    function optDouble (index : integer) : double; overload;
    function optDouble (index : integer; defaultValue :double ) : double ; overload;
    function optInt (index : integer) : integer; overload;
    function optInt (index : integer; defaultValue : integer) : integer; overload;
    function optInt64 (index : integer) : int64; overload;
    function optInt64 (index : integer; defaultValue : int64) : int64; overload;
    function optJSONArray (index : integer) : TJSONArray ; overload;
    function optJSONObject (index : integer) : TJSONObject ; overload;
    function optString (index : integer) : string; overload;
    function optString (index : integer; defaultValue : string) : string; overload;
    function put ( value : boolean) : TJSONArray; overload ;
    function put ( value : double ) : TJSONArray;   overload ;
    function put ( value : integer) : TJSONArray;   overload ;
    function put ( value : int64) : TJSONArray;   overload ;
    function put ( value : TZAbstractObject) : TJSONArray;  overload ;
    function put ( value: string): TJSONArray; overload;
    function put ( index : integer ; value : boolean): TJSONArray;  overload ;
    function put ( index : integer ; value : double) : TJSONArray;  overload ;
    function put ( index : integer ; value : integer) : TJSONArray;  overload ;
    function put ( index : integer ; value : int64) : TJSONArray;  overload ;
    function put ( index : integer ; value : TZAbstractObject) : TJSONArray;  overload ;
    function put ( index: integer; value: string): TJSONArray; overload;
    function toJSONObject (names  :TJSONArray ) : TJSONObject ;  overload ;
    function toString : string; overload; override;
    function toString (indentFactor : integer) : string; overload;
    function toString (indentFactor, indent : integer) : string; overload;
    function toList : TList;
  private
    myArrayList : TList;
  end;

  (** @abstract(wrapper da classe Number do java) *)
  _Number =  class (TZAbstractObject)
     function doubleValue : double; virtual; abstract;
     function intValue : integer; virtual; abstract;
     function int64Value : Int64; virtual; abstract;
  end;

  (** @abstract(wrapper da classe Boolean do java) *)
  _Boolean = class (TZAbstractObject)
    class function _TRUE () : _Boolean;
    class function _FALSE () : _Boolean;
    class function valueOf (b : boolean) : _Boolean;
    constructor create (b : boolean);
    function toString () : string; override;
    function clone :TZAbstractObject;  override;
  private
    fvalue : boolean;
  end;

  (** @abstract(wrapper da classe Double do java) *)
  _Double = class (_Number)
   Public
     constructor create (s : string); overload;
     constructor create (s : _String); overload;
     constructor create (d : double); overload;
     function doubleValue : double; override;
     function intValue : integer;  override;
     function int64Value : int64;  override;
     function toString () : string ; override;
     class function NaN : double;
     function clone :TZAbstractObject; override;
  private
    fvalue : double;
  end;

  (** @abstract(wrapper da classe Integer do java) *)
  _Integer = class (_Number)
  Public
    class function parseInt (s : string; i : integer): integer; overload;
    class function parseInt (s : _String): integer; overload;
    class function toHexString (c : char) : string;
    constructor create (i : integer); overload;
    constructor create (s : string); overload;
    function doubleValue : double; override;
    function intValue : integer;  override;
    function toString () : string; override;
     function clone :TZAbstractObject; override;
  private
    fvalue : integer;
  end;

  _Int64 = class (_Number)
  Public
    class function parseInt (s : string; i : Int64): Int64; overload;
    class function parseInt (s : _String): Int64; overload;
    class function toHexString (c : char) : string;
    constructor create (i : Int64); overload;
    constructor create (s : string); overload;
    function doubleValue : double; override;
    function intValue : Int64;  overload;
    function toString () : string; override;
     function clone :TZAbstractObject; override;
  private
    fvalue : Int64;
  end;

  (** @abstract(wrapper da classe String do java) *)
  _String = class (TZAbstractObject)
   constructor create (s : string);
   function equalsIgnoreCase (s: string) : boolean;
   function Equals(const Value: TZAbstractObject): Boolean; override;
   function toString() : string; override;
   function clone :TZAbstractObject; override;
  private
     fvalue : string;
  end;


  (** @abstract(utilizado quando se deseja representar um valor NULL ) *)
  NULL = class (TZAbstractObject)
     function Equals(const Value: TZAbstractObject): Boolean; override;
     function toString() : string; override;
  end;


var
  (** constante para representar um objeto null *)
  CNULL : NULL;

implementation

uses uRESTDWConsts;

const
  CROTINA_NAO_IMPLEMENTADA : String = 'Command not implemented';

procedure newNotImplmentedFeature () ;
begin
  raise NotImplmentedFeature.create (CROTINA_NAO_IMPLEMENTADA);
end;

function getFormatSettings : TFormatSettings ;
var
  f : TFormatSettings;
begin
  {$IF Defined(RESTDWFMX) and not Defined(POSIX)}
  SysUtils.GetLocaleFormatSettings (windows.GetThreadLocale,f);
  {$ELSEIF not Defined(RESTDWWINDOWS)}
  newNotImplmentedFeature;
  {$IFEND}
  result := f;
  result.DecimalSeparator := '.';
  result.ThousandSeparator := ',';
end;


function HexToInt(S: String): Integer;
var
  I, E, F, G: Integer;

  function DigitValue(C: Char): Integer;
  begin
    case C of
      'A': Result := 10;
      'B': Result := 11;
      'C': Result := 12;
      'D': Result := 13;
      'E': Result := 14;
      'F': Result := 15;
    else
      Result := StrToInt(C);
    end;
  end;

begin
  S := UpperCase(S);
  if S[1] = '$' then Delete(S, 1, 1);
  if S[2] = 'X' then Delete(S, 1, 2);
  E := -1; Result := 0;
  for I := Length(S) downto 1 do begin
    G := 1; for F := 0 to E do G := G*16;
    Result := Result+(DigitValue(S[I])*G);
    Inc(E);
  end;
end;

function HexToInt64(Hex: string): int64;
var
  i: integer;
  HexValues: String;
begin
  HexValues:= '0123456789ABCDEF';
  Result := 0;
  case Length(Hex) of
    0: Result := 0;
    1..16: for i:=1 to Length(Hex) do
      Result := 16*Result + Pos(Upcase(Hex[i]), HexValues)-1;
    else for i:=1 to 16 do
      Result := 16*Result + Pos(Upcase(Hex[i]), HexValues)-1;
  end;
end;

{ JSONTokener }

constructor JSONTokener.create(s: string);
begin
 myIndex := 1;
 mySource := s;
end;

procedure JSONTokener.back;
begin
  {$IFDEF RESTDWANDROID} //Android}
  if (self.myIndex > 0) then begin
            self.myIndex := self.myIndex - 1;
  end;
  {$ELSE}
  if (self.myIndex > 1) then begin
            self.myIndex := self.myIndex - 1;
  end;
  {$ENDIF}
end;

class function JSONTokener.dehexchar(c: char): integer;
begin
  if ((c >= '0') and (c <= '9')) then begin
      result :=  (ord(c) - ord('0'));
      exit;
  end;
  if ((c >= 'A') and (c <= 'F')) then begin
      result :=  (ord(c) + 10 - ord('A'));
      exit;
  end;
  if ((c >= 'a') and (c <= 'f')) then begin
      result := ord(c) + 10 - ord('a');
      exit;
  end;
  result := -1;
end;

(**
     * Determine if the source string still contains characters that next()
     * can consume.
     * @return true if not yet at the end of the source.
*)
function JSONTokener.more: boolean;
begin
 result := self.myIndex <= System.length(self.mySource)+1;
end;

function JSONTokener.next: char;
begin
   if (more()) then begin
     result := self.mySource[self.myIndex];
	   self.myIndex := self.myIndex + 1;
     exit;
   end;
		result := chr(0);
end;

 (**
     * Consume the next character, and check that it matches a specified
     * character.
     * @param c The character to match.
     * @return The character.
     * @throws ParseException if the character does not match.
     *)
function JSONTokener.next(c: char): char;
begin
  result := next();
  if (result <> c) then begin
      raise syntaxError('Expected ' + c + ' and instead saw ' +
              result + '.');
  end;
end;

(**
     * Get the next n characters.
     *
     * @param n     The number of characters to take.
     * @return      A string of n characters.
     * @raises (ParseException
     *   Substring bounds error if there are not
     *   n characters remaining in the source string.)
     *)
function JSONTokener.next(n: integer): string;
var
 i,j : integer;
begin
   i := self.myIndex;
   j := i + n;
   if (j > System.length(self.mySource)) then begin
      raise syntaxError('Substring bounds error');
   end;
   self.myIndex := self.myIndex + n;
   result := copy (self.mySource,i,n); //substring(i, j)
end;

 (**
     * Get the next char in the string, skipping whitespace
     * and comments (slashslash, slashstar, and hash).
     * @throws ParseException
     * @return  A character, or 0 if there are no more characters.
     *)
function JSONTokener.nextClean: char;
var
  c: char;

begin
  while (true) do begin
            c := next();
            if (c = '/') then begin
                case (next()) of
                '/': begin
                    repeat
                        c := next();
                    until (not ((c <> #10) and (c <> #13) and (c <> #0)));
                end ;
                '*': begin
                    while (true) do begin
                        c := next();
                        if (c = #0) then begin
                            raise syntaxError('Unclosed comment.');
                        end;
                        if (c = '*') then begin
                            if (next() = '/') then begin
                                break;
                            end;
                            back();
                        end;
                    end;
                end
                else begin
                    back();
                    result := '/';
                    exit;
                end;
            end;
            end else if (c = '#') then begin
                repeat
                    c := next();
                until (not ((c <> #10) and (c <> #13) and (c <> #0)));
            end else if ((c = #0) or (c > ' ')) then begin
                result := c;
                exit;
            end;
  end; //while
end;


(**
     * Return the characters up to the next close quote character.
     * Backslash processing is done. The formal JSON format does not
     * allow strings in single quotes, but an implementation is allowed to
     * accept them.
     * @param quote The quoting character, either
     *      <code>"</code>&nbsp;<small>(double quote)</small> or
     *      <code>'</code>&nbsp;<small>(single quote)</small>.
     * @return      A String.
     * @raises (ParseException Unterminated string.)
     *)
function JSONTokener.nextString (quote : char): string;
var
  c : char;
  sb : string;
begin
        sb := '';
        while (true) do begin
            c := next();
            case (c) of
            '\': begin
                c := next();
                case (c) of
                'b': 
                    sb := sb + #8;
                't':
                    sb := sb + #9;
                'n':
                    sb := sb + #10;
                'f':
                    sb := sb + #12;
                'r':
                    sb := sb + #13;
                'u':
                  sb := sb+WideChar(StrToInt('$'+next(4)));
                {case 'u':
                    sb.append((char)Integer.parseInt(next(4), 16));
                    break;
                case 'x' :  \cx  	The control character corresponding to x
                    sb.append((char) Integer.parseInt(next(2), 16));
                    break;}
                  else   sb := sb + c
                end;
            end
            else  begin
                if (c = quote) then begin
                    result := sb;
                    exit;
                end;
                sb := sb + c
            end;
            end;
        end;
end;

(**
     * Get the text up but not including the specified character or the
     * end of line, whichever comes first.
     * @param  d A delimiter character.
     * @return   A string.
     *)
function JSONTokener.nextTo(d: char): string;
var
  sb : string;
  c : char;
begin
  sb := '';
  c  := #0;
  while (true) do begin
            c := next();
            if ((c = d) or (c = #0) or (c = #10) or (c = #13)) then begin
                if (c <> #0) then begin
                    back();
                end;
                result := trim (sb);
                exit;
            end;
            sb := sb + c;
  end;
end;

(**
     * Get the text up but not including one of the specified delimeter
     * characters or the end of line, whichever comes first.
     * @param delimiters A set of delimiter characters.
     * @return A string, trimmed.
*)
function JSONTokener.nextTo(delimiters: string): char;
var
  c : char;
  sb : string;
begin
        c := #0;
        sb := '';
        while (true) do begin
            c := next();
            if ((pos (c,delimiters) > 0) or (c = #0) or
                    (c = #10) or (c = #13)) then begin
                if (c <> #0) then begin
                    back();
                end;
                sb := trim(sb);
                if (System.length(sb) > 0) then result := sb[1];
                exit;
            end;
            sb := sb + c;
        end;
end;

(**
     * Get the next value. The value can be a Boolean, Double, Integer,
     * TJSONArray, TJSONObject, or String, or the TJSONObject.NULL object.
     * @raises (ParseException The source does not conform to JSON syntax.)
     *
     * @return An object.
*)
function JSONTokener.nextValue: TZAbstractObject;
var
  c, b : char;
  s , sb: string;
begin
  c := nextClean();

        case (c) of
            '"', #39: begin
                result := _String.create (nextString(c));
                exit;
            end;
            '{': begin
                back();
                result := TJSONObject.create(self);
                exit;
            end;
            '[': begin
                back();
                result := TJSONArray.create(self);
                exit;
            end;
        end;

        (*
         * Handle unquoted text. This could be the values true, false, or
         * null, or it can be a number. An implementation (such as this one)
         * is allowed to also accept non-standard forms.
         *
         * Accumulate characters until we reach the end of the text or a
         * formatting character.
         *)

        sb := '';
        b := c;
        while ((ord(c) >= ord(' ')) and (pos (c,',:]}/\\\"[{;=#') = 0)) do begin
            sb := sb + c;
            c := next();
        end;
        back();

        (*
         * If it is true, false, or null, return the proper value.
         *)

        s := trim (sb);
        if (s = '') then begin
            raise syntaxError('Missing value.');
        end;
        if (AnsiLowerCase (s) = 'true') then begin
            result :=  _Boolean._TRUE;
            exit;
        end;

        if (AnsiLowerCase (s) = 'false') then begin
            result := _Boolean._FALSE;
            exit;
        end;
        if (AnsiLowerCase (s) = 'null') then begin
            result := TJSONObject.NULL;
            exit;
        end;

        (*
         * If it might be a number, try converting it. We support the 0- and 0x-
         * conventions. If a number cannot be produced, then the value will just
         * be a string. Note that the 0-, 0x-, plus, and implied string
         * conventions are non-standard. A JSON parser is free to accept
         * non-JSON forms as long as it accepts all correct JSON forms.
         *)

        if ( ((b >= '0') and (b <= '9')) or (b = '.')
                          or (b = '-') or (b = '+')) then begin
            if (b = '0') then begin
                if ( (System.length(s) > 2) and
                        ((s[2] = 'x') or (s[2] = 'X') ) ) then begin
                    try
                        result := _Integer.create(_Integer.parseInt(copy(s,3,System.length(s)),
                                                            16));
                        exit;
                    Except
                    end;
                end else begin
                          If Not((Pos(',', s) > 0) or (Pos('.', s) > 0)) Then
                           Begin
                            try
                                result := _Integer.create(_Integer.parseInt(s,
                                                            8));
                                exit;
                            Except
                            end;
                           End;
                          try
                              result := _Double.create(s);
                              exit;
                          Except
                          end;
                end;
            end;
            If Not((Pos(',', s) > 0) or (Pos('.', s) > 0)) Then
             Begin
              try
                  if Length(s) < 10 then
                   result := _Integer.create(s)
                  else
                   result := _Int64.create(s);
                  exit;
              Except
              end;
             End;
            try
                result := _Double.create(s);
                exit;
            Except
            end;
        end;
        result := _String.create(s);
end;

(**
     * Skip characters until the next character is the requested character.
     * If the requested character is not found, no characters are skipped.
     * @param to A character to skip to.
     * @return The requested character, or zero if the requested character
     * is not found.
     *)
function JSONTokener.skipTo(_to: char): char;
var
  c : char;
  index : integer;
begin
   c := #0;
        index := self.myIndex;
        repeat
            c := next();
            if (c = #0) then begin
                self.myIndex := index;
                result := c;
                exit;
           end;
        until (not (c <> _to));
        back();
        result := c;
        exit;
end;

(**
     * Skip characters until past the requested string.
     * If it is not found, we are left at the end of the source.
     * @param to A string to skip past.
     *)
procedure JSONTokener.skipPast(_to: string);
begin
   self.myIndex := pos (_to, copy(mySource, self.myIndex, System.length(mySource)));
        if (self.myIndex < 0) then begin
            self.myIndex := System.length(self.mySource)+1;
        end else begin
            self.myIndex := self.myIndex + System.length(_to);
        end;
end;

(**
     * Make a ParseException to signal a syntax error.
     *
     * @param message The error message.
     * @return  A ParseException object, suitable for throwing
     *)
function JSONTokener.syntaxError(_message: string): ParseException;
begin
 result := ParseException.create (_message + toString()+' next to : '
 + copy (toString(),self.myIndex,10), self.myIndex);
end;

(**
     * Make a printable string of this JSONTokener.
     *
     * @return " at character [this.myIndex] of [this.mySource]"
     *)
function JSONTokener.toString: string;
begin
  result := ' at character ' + intToStr(self.myIndex) + ' of ' + self.mySource;
end;

(**
     * Convert <code>%</code><i>hh</i> sequences to single characters, and
     * convert plus to space.
     * @param s A string that may contain
     *      <code>+</code>&nbsp;<small>(plus)</small> and
     *      <code>%</code><i>hh</i> sequences.
     * @return The unescaped string.
     *)
function JSONTokener.unescape(s: string): string;
var
  len, i,d,e : integer;
  b : string;
  c : char;
begin
  len := System.length(s);
  b := '';
  i := 1;
        while ( i <= len ) do begin
            c := s[i];
            if (c = '+') then begin
                c := ' ';
            end else if ((c = '%') and ((i + 2) <= len)) then begin
                d := dehexchar(s[i + 1]);
                e := dehexchar(s[i + 2]);
                if ((d >= 0) and (e >= 0)) then begin
                    c := chr(d * 16 + e);
                    i := i + 2;
                end;
            end;
            b := b + c;
            i := i + 1;
        end;
        result := b ;
end;

{ TJSONObject }

constructor TJSONObject.create;
begin
  myHashMap := TStringListJSON.create;
end;

constructor TJSONObject.create(jo: TJSONObject; sa: array of string);
var
 i : integer;
begin
  create();
  for i :=low(sa) to high(sa)  do begin
            putOpt(sa[i], jo.opt(sa[i]).Clone);
  end;
end;

constructor TJSONObject.create(x: JSONTokener);
var
 c : char;
 key : string;
begin
  create ;
  c := #0;
  key := '';

  if (x.nextClean() <> '{') then begin
      raise x.syntaxError('A TJSONObject must begin with "{"');
  end;
  while (true) do begin
      c := x.nextClean();
      case (c) of
      #0:
          raise x.syntaxError('A TJSONObject must end with "}"');
      '}': begin
          exit;
      end
      else begin
          x.back();
          with x.nextValue() do
          begin
            key := toString();
            Free; //Fix memory leak. By creation_zy
          end;
      end
      end; //fim do case

      (*
       * The key is followed by ':'. We will also tolerate '=' or '=>'.
       *)

      c := x.nextClean();
      if (c = '=') then begin
          if (x.next() <> '>') then begin
              x.back();
          end;
      end else if (c <> ':') then begin
          raise x.syntaxError('Expected a ":" after a key');
      end;
      self.myHashMap.AddObject(key, x.nextValue);

      (*
       * Pairs are separated by ','. We will also tolerate ';'.
       *)

      case (x.nextClean()) of
      ';', ',': begin
          if (x.nextClean() = '}') then begin
              exit;
          end;
          x.back();
      end;
      '}': begin
          exit;
      end
      else begin
          raise x.syntaxError('Expected a "," or "}"');
      end
      end;
  end; //while

end;

constructor TJSONObject.create(map: TStringList);
var
 i : integer;
begin
  myHashMap := TStringlistJSON.create;
  for i := 0 to map.Count -1 do begin
   myHashMap.AddObject(map[i],map.Objects[i]);
  end;
end;

constructor TJSONObject.create(s: string);
var
  token : JSOnTokener;
begin
 token :=  JSONTokener.create(s);
 Try
  create (token);
 Finally
  FreeAndNil(token);
 End;
end;

(**
     * Accumulate values under a key. It is similar to the put method except
     * that if there is already an object stored under the key then a
     * TJSONArray is stored under the key to hold all of the accumulated values.
     * If there is already a TJSONArray, then the new value is appended to it.
     * In contrast, the put method replaces the previous value.
     * @param key   A key string.
     * @param value An object to be accumulated under the key.
     * @return this.
     * @throws NullPointerException if the key is null
     *)
function TJSONObject.accumulate(key: string; value: TZAbstractObject): TJSONObject;
var
 a : TJSONArray;
 o : TZAbstractObject;
begin
  a := nil;
  o := opt(key);
  if (o = nil) then begin
      put(key, value);
  end else if (o is TJSONArray) then begin
      a := TJSONArray(o);
      a.put(value);
  end else  begin
      a := TJSONArray.create;
      a.put(o.clone);
      a.put(value);
      put(key, a);
  end;
  result := self;
end;

(**
     * Get the value object associated with a key.
     *
     * @param key   A key string.
     * @return      The object associated with the key.
     * @raises (NoSuchElementException if the key is not found.)
     *)
function TJSONObject.get(key: string): TZAbstractObject;
var
 o : TZAbstractObject;
begin
  o := opt(key);
  if (o = nil) then begin
      raise NoSuchElementException.create('TJSONObject[' +
          quote(key) + '] not found.');
  end;
  result := o;
end;

(**
     * Get the boolean value associated with a key.
     *
     * @param key   A key string.
     * @return      The truth.
     * @raises (NoSuchElementException if the key is not found.)
     * @raises (ClassCastException
     *  if the value is not a Boolean or the String "true" or "false".)
     *)
function TJSONObject.getBoolean(key: string): boolean;
var
 o : TZAbstractObject;
begin
    o := get(key);
    if (o.equals(_Boolean._FALSE) or
            ((o is _String) and
            (_String(o)).equalsIgnoreCase('false'))) then begin
        result := false;
        exit;
    end else if (o.equals(_Boolean._TRUE) or
            ((o is _String) and
            (_String(o)).equalsIgnoreCase('true'))) then begin
        result := true;
        exit;
    end;
    raise ClassCastException.create('TJSONObject[' +
        quote(key) + '] is not a Boolean.');
end;

function TJSONObject.getDouble(key: string): double;
var
  o : TZAbstractObject;
begin
        o := get(key);
        if (o is _Number) then begin
            result := _Number (o).doubleValue();
            exit;
        end ;
        if (o is _String) then begin
            result := StrToFloat (_String(o).toString(), getFormatSettings());
            exit;
        end;
        raise NumberFormatException.create('TJSONObject[' +
            quote(key) + '] is not a number.');
end;

(**
     * Get the int value associated with a key.
     *
     * @param key   A key string.
     * @return      The integer value.
     * @raises (NoSuchElementException if the key is not found)
     * @raises (NumberFormatException
     *  if the value cannot be converted to a number.)
     *)
function TJSONObject.getInt(key: string): integer;
var
  o : TZAbstractObject;
begin
        o := get(key);
        if (o is _Number) then begin
           result :=  _Number(o).intValue();
        end else begin
           result :=  Round(getDouble(key));
        end;

end;

function TJSONObject.getInt64(key: string): Int64;
var
  o : TZAbstractObject;
begin
        o := get(key);
        if (o is _Number) then begin
           result :=  _Number(o).int64Value();
        end else begin
           result :=  Round(getDouble(key));
        end;
end;

(**
     * Get the TJSONArray value associated with a key.
     *
     * @param key   A key string.
     * @return      A TJSONArray which is the value.
     * @raises (NoSuchElementException if the key is not found or
     *  if the value is not a TJSONArray.)
     *)
function TJSONObject.getJSONArray(key: string): TJSONArray;
var
 o : TZAbstractObject;
begin
  o := opt(key);
  if (o is TJSONArray) then begin
      result := TJSONArray(o);
  end else begin
    raise  NoSuchElementException.create('TJSONObject[' +
        quote(key) + '] is not a TJSONArray.');
  end;
end;

(**
     * Get the TJSONObject value associated with a key.
     *
     * @param key   A key string.
     * @return      A TJSONObject which is the value.
     * @raises (NoSuchElementException if the key is not found or
     *  if the value is not a TJSONObject.)
     *)
function TJSONObject.getJSONObject(key: string): TJSONObject;
var
 o : TZAbstractObject;
begin
  o := get(key);
  if (o is TJSONObject) then begin
      result := TJSONObject(o);
  end else begin
    raise NoSuchElementException.create('TJSONObject[' +
        quote(key) + '] is not a TJSONObject.');
  end;
end;

(**
     * Get the string associated with a key.
     *
     * @param key   A key string.
     * @return      A string which is the value.
     * @raises (NoSuchElementException if the key is not found.)
*)
function TJSONObject.getString(key: string): string;
begin
  result := get(key).toString();
end;

(**
     * Determine if the TJSONObject contains a specific key.
     * @param key   A key string.
     * @return      true if the key exists in the TJSONObject.
     *)
function TJSONObject.has(key: string): boolean;
begin
   result := self.myHashMap.IndexOf(key) >= 0;
end;

(**
     * Determine if the value associated with the key is null or if there is
     *  no value.
     * @param key   A key string.
     * @return      true if there is no value associated with the key or if
     *  the value is the TJSONObject.NULL object.
     *)
function TJSONObject.isNull(key: string): boolean;
var
 o : TZAbstractObject;
begin
 o := opt(key);
 result := NULL.equals(o);
 If Not result Then
  result := o = cnull;
end;

function TJSONObject.keys: TStringList;
var
 i : integer;
begin
  result := TStringList.Create;
  for i := 0 to myHashMap.Count -1 do begin
    result.add (myHashMap[i]);
  end;
end;

function TJSONObject.length: integer;
begin
   result := myHashMap.Count;
end;

(**
     * Produce a TJSONArray containing the names of the elements of this
     * TJSONObject.
     * @return A TJSONArray containing the key strings, or null if the TJSONObject
     * is empty.
     *)
function TJSONObject.names: TJSONArray;
var
  i : integer;
  k : TStringList;
begin
  if Not Assigned(ja) then
    ja := TJSONArray.create;
    k := keys;
    try
      If ja.myArrayList.Count = 0 Then
       for i := 0 to k.Count -1 do
        ja.put (_String.create (k[i]));
      if (ja.length = 0) then begin
         result := nil;
      end else begin
         result := ja;
      end;
    finally
      k.free;
    end;
end;

class function TJSONObject.numberToString(n: _Number): string;
begin
   if (n = nil) then begin
     result := '';
   end
   else begin
     result :=  n.toString();
   end;
end;

function TJSONObject.opt(key: string): TZAbstractObject;
begin
   if (key = '') then begin
            raise NullPointerException.create('Null key');
   end else begin
        if myHashMap.IndexOf(key) < 0 then begin
          result := nil;
        end else begin
         result :=  TZAbstractObject (myHashMap.Objects [myHashMap.IndexOf(key)]);
        end;
   end;
end;

(**
     * Get an optional boolean associated with a key.
     * It returns false if there is no such key, or if the value is not
     * Boolean.TRUE or the String "true".
     *
     * @param key   A key string.
     * @return      The truth.
     *)
function TJSONObject.optBoolean(key: string): boolean;
begin
  result := optBoolean (key, false);
end;

(**
     * Get an optional boolean associated with a key.
     * It returns the defaultValue if there is no such key, or if it is not
     * a Boolean or the String "true" or "false" (case insensitive).
     *
     * @param key              A key string.
     * @param defaultValue     The default.
     * @return      The truth.
     *)
function TJSONObject.optBoolean(key: string;
  defaultValue: boolean): boolean;
var
  o : TZAbstractObject;
begin
        o := opt(key);
        if (o <> nil) then begin
            if (o.equals(_Boolean._FALSE) or
                    ((o is _String) and
                    (_String(o).equalsIgnoreCase('false')))) then begin
                result := false;
                exit;
            end else if (o.equals(_Boolean._TRUE) or
                    ((o is _String) and
                    (_String(o).equalsIgnoreCase('true')))) then begin
                result := true;
                exit;
            end;
        end;
        result := defaultValue;
end;

(**
     * Get an optional double associated with a key,
     * or NaN if there is no such key or if its value is not a number.
     * If the value is a string, an attempt will be made to evaluate it as
     * a number.
     *
     * @param key   A string which is the key.
     * @return      An object which is the value.
     *)
function TJSONObject.optDouble(key: string): double;
begin
  result := optDouble(key, _Double.NaN);
end;

(**
     * Get an optional double associated with a key, or the
     * defaultValue if there is no such key or if its value is not a number.
     * If the value is a string, an attempt will be made to evaluate it as
     * a number.
     *
     * @param key   A key string.
     * @param defaultValue     The default.
     * @return      An object which is the value.
     *)
function TJSONObject.optDouble(key: string; defaultValue: double): double;
var
 o : TZAbstractObject;
begin
    o := opt(key);
    if (o <> nil) then begin
        if (o is _Number) then begin
            result := (_Number(o)).doubleValue();
            exit;
        end  ;
        try
            result := _Double.create(_String(o)).doubleValue();
            exit;
          except on e:Exception  do begin
            result := defaultValue;
            exit;
          end;
        end;
    end;
    result := defaultValue;
end;

(**
     * Get an optional int value associated with a key,
     * or zero if there is no such key or if the value is not a number.
     * If the value is a string, an attempt will be made to evaluate it as
     * a number.
     *
     * @param key   A key string.
     * @return      An object which is the value.
     *)
function TJSONObject.optInt(key: string): integer;
begin
  result := optInt (key, 0);
end;

(**
     * Get an optional int value associated with a key,
     * or the default if there is no such key or if the value is not a number.
     * If the value is a string, an attempt will be made to evaluate it as
     * a number.
     *
     * @param key   A key string.
     * @param defaultValue     The default.
     * @return      An object which is the value.
     *)
function TJSONObject.optInt(key: string; defaultValue: integer): integer;
var
  o : TZAbstractObject;
begin
  o := opt(key);
  if (o <> null) then begin
      if (o is _Number) then begin
          result :=  (_Number(o)).intValue();
          exit;
      end;
      try
          result := _Integer.parseInt(_String(o));
          exit;
        except on e:Exception  do begin
          result := defaultValue;
          exit;
        end;
      end;
  end;
  result := defaultValue;
end;

function TJSONObject.optInt64(key: string; defaultValue: Int64): Int64;
var
  o : TZAbstractObject;
begin
  o := opt(key);
  if (o <> null) then begin
      if (o is _Number) then begin
          result :=  (_Number(o)).int64Value();
          exit;
      end;
      try
          result := _Int64.parseInt(_String(o));
          exit;
        except on e:Exception  do begin
          result := defaultValue;
          exit;
        end;
      end;
  end;
  result := defaultValue;
end;

function TJSONObject.optInt64(key: string): Int64;
begin
  result := optInt64 (key, 0);
end;

(**
     * Get an optional TJSONArray associated with a key.
     * It returns null if there is no such key, or if its value is not a
     * TJSONArray.
     *
     * @param key   A key string.
     * @return      A TJSONArray which is the value.
     *)
function TJSONObject.optJSONArray(key: string): TJSONArray;
var
 o : TZAbstractObject ;
begin
    o := opt(key);
    if (o is TJSONArray) then begin
      result := TJSONArray(o);
    end else begin
      result := nil;
    end;
end;

(**
     * Get an optional TJSONObject associated with a key.
     * It returns null if there is no such key, or if its value is not a
     * TJSONObject.
     *
     * @param key   A key string.
     * @return      A TJSONObject which is the value.
     *)
function TJSONObject.optJSONObject(key: string): TJSONObject;
var
 o : TZAbstractObject ;
begin
  o := opt(key);
  if (o is TJSONObject) then begin
      result := TJSONObject(o);
    end else begin
      result := nil;
    end;
end;

(**
     * Get an optional string associated with a key.
     * It returns an empty string if there is no such key. If the value is not
     * a string and is not null, then it is coverted to a string.
     *
     * @param key   A key string.
     * @return      A string which is the value.
     *)
function TJSONObject.optString(key: string): string;
begin
  result := optString(key, '');
end;

(**
     * Get an optional string associated with a key.
     * It returns the defaultValue if there is no such key.
     *
     * @param key   A key string.
     * @param defaultValue     The default.
     * @return      A string which is the value.
     *)
function TJSONObject.optString(key, defaultValue: string): string;
var
 o : TZAbstractObject ;
begin
  o := opt(key);
  if (o <> nil) then begin
      result := o.toString();
    end else begin
      result := defaultValue;
    end;
end;

(**
     * Put a key/boolean pair in the TJSONObject.
     *
     * @param key   A key string.
     * @param value A boolean which is the value.
     * @return this.
     *)
function TJSONObject.put(key: string; value: boolean): TJSONObject;
begin
   put(key, _Boolean.valueOf(value));
   result := self;
end;

(**
     * Put a key/double pair in the TJSONObject.
     *
     * @param key   A key string.
     * @param value A double which is the value.
     * @return this.
     *)
function TJSONObject.put(key: string; value: double): TJSONObject;
begin
   put(key, _Double.create(value));
   result := self;
end;

(**
     * Put a key/int pair in the TJSONObject.
     *
     * @param key   A key string.
     * @param value An int which is the value.
     * @return this.
     *)
function TJSONObject.put(key: string; value: integer): TJSONObject;
begin
   put(key, _Integer.create(value));
   result := self;
end;

function TJSONObject.put(key: string; value: Int64): TJSONObject;
begin
   put(key, _Int64.create(value));
   result := self;
end;

(**
     * Put a key/value pair in the TJSONObject. If the value is null,
     * then the key will be removed from the TJSONObject if it is present.
     * @param key   A key string.
     * @param value An object which is the value. It should be of one of these
     *  types: Boolean, Double, Integer, TJSONArray, TJSONObject, String, or the
     *  TJSONObject.NULL object.
     * @return this.
     * @raises (NullPointerException The key must be non-null.)
     *)
function TJSONObject.put(key: string; value: TZAbstractObject): TJSONObject;
var
  temp : TObject;
  i : integer;
begin
    if (key = '') then begin
            raise NullPointerException.create('Null key.');
    end ;
    if (value <> nil) then begin
        i := self.myHashMap.IndexOf(key);
        if ( i >= 0) then begin
          temp := self.myHashMap.Objects [i];
          self.myHashMap.Objects[i]  := value;
          temp.free;
        end else begin
        self.myHashMap.AddObject(key, value);
        end;
    end else begin
        temp := remove(key);
        if (temp <> nil) then  begin
          temp.free;
        end;
    end;
    result := self;
end;

function TJSONObject.put(key, value: string): TJSONObject;
begin
   put(key, _String.create(value));
   result := self;
end;
function TJSONObject.putOpt(key: string; value: TZAbstractObject): TJSONObject;
begin
   if (value <> nil) then begin
    put(key, value);
   end ;
   result := self;
end;

(**
     * Produce a string in double quotes with backslash sequences in all the
     * right places.
     * @param string A String
     * @return  A String correctly formatted for insertion in a JSON message.
     *)
class function TJSONObject.quote(s: string): string;
begin
 Result := Format('"%s"', [TJSONObject.convertUTF8String(s)]);
end;

class function TJSONObject.convertUTF8String(s : string): string;
var
   b,c : char;
   i, len : integer;
   sb, t : string;
Const
 NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                 '0'..'9','$','!','''','(',')'];
begin
 Result :=  '';
 If ((s = '') or (System.Length(s) = 0)) Then
  Exit;
 b := #0;
 c := #0;
 i := 0;
 len := System.length(s);
 t := '';
 sb := '';
 For i := 1 To len Do
  Begin
   b := c;
   c := s[i];
   Case (c) Of
    '\',
    '"' : Begin
           sb := sb + '\';
           sb := sb + c;
          End;
    '/' : Begin
           If (b = '<') Then
            sb := sb + '\';
           sb := sb + c;
          End;
    #8  : sb := sb + '\b';
    #9  : sb := sb + '\t';
    #10 : sb := sb + '\n';
    #12 : sb := sb + '\f';
    #13 : sb := sb + '\r';
    Else Begin
          If (not (c in NoConversion)) Then
           Begin
            t := '000' + _Integer.toHexString(c);
            sb := sb + '\u' + copy (t,System.length(t)-3,4);
           End
          Else
           sb := sb + c;
         End;
   End;
  End;
 Result := sb;
End;

(**
     * Remove a name and its value, if present.
     * @param key The name to be removed.
     * @return The value that was associated with the name,
     * or null if there was no value.
     *)
function TJSONObject.remove(key: string): TZAbstractObject;
begin
  if ( myHashMap.IndexOf(key) < 0) then begin
    result := nil
  end else begin
   result := TZAbstractObject(myHashMap.Objects [myHashMap.IndexOf(key)]);
   self.myHashMap.delete (myHashMap.IndexOf(key));
  end;
end;

(**
     * Produce a TJSONArray containing the values of the members of this
     * TJSONObject.
     * @param names A TJSONArray containing a list of key strings. This
     * determines the sequence of the values in the result.
     * @return A TJSONArray of values.
     *)
function TJSONObject.toJSONArray(anames: TJSONArray): TJSONArray;
var
 i : integer;
begin
  if ((anames = nil) or (anames.length() = 0)) then begin
      result := nil;
      exit;
  end;
  If Not Assigned(ja) Then
   ja := TJSONArray.create;
  If ja.myArrayList.Count = 0 Then
   for i := 0 to anames.length -1 {; i < anames.length(); i += 1)} do begin
      ja.put(self.opt(names.getString(i)));
  end;
  result := ja;
end;

(**
     * Make an JSON external form string of this TJSONObject. For compactness, no
     * unnecessary whitespace is added.
     * <p>
     * Warning: This method assumes that the data structure is acyclical.
     *
     * @return a printable, displayable, portable, transmittable
     *  representation of the object, beginning
     *  with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     *  with <code>}</code>&nbsp;<small>(right brace)</small>.
     *)
function TJSONObject.toString: string;
var
 _keys : TStringList;
 sb : string;
 o : string;
 i :integer;
begin
      _keys := keys();
      try
          sb := '{';

          for i := 0 to _keys.count -1 do begin
              if (System.length(sb) > 1) then begin
                  sb:= sb + ',';
              end;
              o := _keys[i];
              sb := sb + quote(o);
              sb := sb + ':';
              sb:= sb + valueToString(TZAbstractObject(myHashMap.Objects[myHashMap.IndexOf(o)]));
          end;
          sb := sb + '}';
          result := sb;
      finally
        _keys.free;
      end;
end;

(**
     * Make a prettyprinted JSON external form string of this TJSONObject.
     * <p>
     * Warning: This method assumes that the data structure is acyclical.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @return a printable, displayable, portable, transmittable
     *  representation of the object, beginning
     *  with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     *  with <code>}</code>&nbsp;<small>(right brace)</small>.
     *)
function TJSONObject.toString(indentFactor: integer): string;
begin
  result := toString(indentFactor, 0);
end;

(**
     * Make a prettyprinted JSON string of this TJSONObject.
     * <p>
     * Warning: This method assumes that the data structure is acyclical.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @param indent The indentation of the top level.
     * @return a printable, displayable, transmittable
     *  representation of the object, beginning
     *  with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     *  with <code>}</code>&nbsp;<small>(right brace)</small>.
     *)
function TJSONObject.toString(indentFactor, indent: integer): string;
var
 j , i , n , newindent: integer;
 _keys : TStringList;
 o, sb : string;
begin
        i := 0;
        n := length();
        if (n = 0) then begin
            result := '{}';
            exit;
        end;
        _keys := keys();
        try
            sb := sb + '{';
            newindent := indent + indentFactor;
            if (n = 1) then begin
                o := _keys[0];
                sb:= sb + quote(o);
                sb:= sb + ': ';
                sb:= sb + valueToString(TZAbstractObject(myHashMap
                .Objects[myHashMap.IndexOf(o)])
                , indentFactor, indent);
            end else begin
                for j := 0 to _keys.count -1 do begin
                    o := _keys[j];
                    if (System.length(sb) > 1) then begin
                        sb := sb + ','+ #10;
                    end else begin
                        sb:= sb + #10;
                    end;
                    for i := 0 to newindent -1  do begin
                        sb:= sb + ' ';
                    end;
                    sb:= sb + quote(o);
                    sb:= sb + ': ';
                    sb:= sb + valueToString(TZAbstractObject(myHashMap
                    .Objects[myHashMap.IndexOf(o)])
                    , indentFactor, newindent);
                end;
                if (System.length(sb) > 1) then begin
                    sb := sb + #10;
                    for i := 0 to indent -1 do begin
                        sb:= sb + ' ';
                    end;
                end;
            end;
            sb:= sb + '}';
            result :=  sb;
        finally
            _keys.Free; 
        end;
end;

class function TJSONObject.NULL: NULL;
begin
  result := CNULL;
end;

class function TJSONObject.valueToString(value: TZAbstractObject): string;
begin
  if ((value = nil) or (value.equals(null))) then begin
      result := 'null';
      exit;
  end;
  if (value is _Number) then begin
      result := numberToString(_Number(value));
      exit;
  end;
  if ((value is _Boolean) or (value is TJSONObject) or
          (value is TJSONArray)) then begin
      result := value.toString();
      exit;
  end;
  result := quote(value.toString());
end;

(**
     * Make a prettyprinted JSON string of an object value.
     * <p>
     * Warning: This method assumes that the data structure is acyclical.
     * @param value The value to be serialized.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @param indent The indentation of the top level.
     * @return a printable, displayable, transmittable
     *  representation of the object, beginning
     *  with <code>{</code>&nbsp;<small>(left brace)</small> and ending
     *  with <code>}</code>&nbsp;<small>(right brace)</small>.
     *)
class function TJSONObject.valueToString(value: TZAbstractObject;
  indentFactor, indent: integer): string;
begin
   if ((value = nil) or (value.equals(nil))) then begin
        result := 'null';
        exit;
    end;
    if (value is _Number) then begin
        result := numberToString(_Number(value));
        exit;
    end;
    if (value is _Boolean) then begin
        result :=  value.toString();
        exit;
    end;
    if (value is TJSONObject) then begin
        result := ((TJSONObject(value)).toString(indentFactor, indent));
        exit;
    end;
    if (value is TJSONArray) then begin
        result := ((TJSONArray(value)).toString(indentFactor, indent));
        exit;
    end;
    result := quote(value.toString());
end;

{ _Boolean }

function _Boolean.clone: TZAbstractObject;
begin
  result := _Boolean.create(Self.fvalue);
end;

constructor _Boolean.create(b: boolean);
begin
   fvalue := b;
end;

var
  CONST_FALSE : _Boolean;
  CONST_TRUE : _Boolean;

function _Boolean.toString: string;
begin
  if fvalue then begin
    result := 'true';
  end else begin
    result := 'false';
  end;
end;

class function _Boolean.valueOf(b: boolean): _Boolean;
begin
 if (b) then begin
    result := _TRUE;
 end else begin
    result := _FALSE;
 end;
end;

class function _Boolean._FALSE: _Boolean;
begin
  result := CONST_FALSE;
end;

class function _Boolean._TRUE: _Boolean;
begin
  result := CONST_TRUE;
end;

{ _String }

function _String.clone: TZAbstractObject;
begin
  result := _String.create (self.fvalue);
end;

constructor _String.create(s: string);
begin
  fvalue := s;
end;

function _String.equals(const Value: TZAbstractObject): Boolean;
begin
    result := (value is _String) and (_String (value).fvalue = fvalue);
end;

function _String.equalsIgnoreCase(s: string): boolean;
begin
   result := AnsiLowerCase (s) = AnsiLowerCase (fvalue);
end;

function _String.toString: string;
begin
  result := fvalue;
end;

{ ParseException }

constructor ParseException.create(_message: string; index: integer);
begin
   inherited createFmt(_message+#10#13' erro no caracter : %d',[index]);
end;

{ _Integer }

constructor _Integer.create(i: integer);
begin
  fvalue := i;
end;

function _Integer.clone: TZAbstractObject;
begin
  result := _Integer.create (self.fvalue);
end;

constructor _Integer.create(s: string);
begin
  fvalue := strToInt(s);
end;

function _Integer.doubleValue: double;
begin
  result := fvalue;
end;

function _Integer.intValue: integer;
begin
  result := fvalue;
end;

class function _Integer.parseInt(s: string; i: integer): integer;
begin
  case i of
  10: begin
    result := strToInt (s);
  end;
  16: begin
   result := hexToInt (s);
  end;
  8: begin
       if (s = '0') then begin
         result := 0
       end else begin
        newNotImplmentedFeature () ;
       end;
  end;
  end;
end;

class function _Integer.parseInt(s: _String): integer;
begin
  result := _Integer.parseInt (s.toString, 10);
end;

class function _Integer.toHexString(c: char): string;
begin
  result := IntToHex(ord(c),2);
end;

function _Integer.toString: string;
begin
  result := intToStr (fvalue);
end;

{ _Double }

constructor _Double.create(s: string);
begin
  fvalue := StrToFloat (s, getFormatSettings);
end;

constructor _Double.create(s: _String);
begin
  create (s.toString);
end;

function _Double.clone: TZAbstractObject;
begin
  result := _Double.create (Self.fvalue);
end;

constructor _Double.create(d: double);
begin
  fvalue := d;
end;

function _Double.doubleValue: double;
begin
  result := fvalue;
end;

function _Double.int64Value: int64;
begin
  result := trunc (fvalue);
end;

function _Double.intValue: integer;
begin
  result := trunc (fvalue);
end;

class function _Double.NaN: double;
begin
  result := 3.6e-4951;
end;

// Alteração feito por Ico Menezes (realizar parse dos pontos flutuantes do openJson) 26/10/2019
function _Double.toString: string;
begin
//  result := '"' + StringReplace(FloatToStr(fvalue), ',', '.', [rfReplaceAll]) + '"';
  result := StringReplace(FloatToStr(fvalue), ',', '.', [rfReplaceAll]);
end;

{ TJSONArray }

(**
     * Construct a TJSONArray from a JSONTokener.
     * @param x A JSONTokener
     * @raises (ParseException A TJSONArray must start with '[')
     * @raises (ParseException Expected a ',' or ']')
     *)
constructor TJSONArray.create(x: JSONTokener);
begin
  create;
  if (x.nextClean() <> '[') then begin
      raise x.syntaxError('A TJSONArray must start with "["');
  end;
  if (x.nextClean() = ']') then begin
      exit;
  end;
  x.back();
  while (true) do begin
      if (x.nextClean() = ',') then begin
          x.back();
          myArrayList.add(nil);
      end else begin
          x.back();
          myArrayList.add(x.nextValue());
      end;
      case (x.nextClean()) of
      ';',',': begin
          if (x.nextClean() = ']') then begin
              exit;
          end;
          x.back();
      end;
      ']': begin
          exit;
      end else begin
         raise x.syntaxError('Expected a "," or "]"');
      end
      end;
  end;
end;

destructor TJSONObject.destroy;
begin
  clean;
//  myHashMap.Clear;
  if Assigned(myHashMap) then
   FreeAndNil(myHashMap);
  if Assigned(ja) then
   FreeAndNil(ja);
  inherited;
end;

(**
     * Construct a TJSONArray from a Collection.
     * @param collection     A Collection.
     *)
constructor TJSONArray.create(collection: TList);
var
  i : integer;
begin
  myArrayList := TList.create;
  for i := 0 to collection.count -1 do begin
     myArrayList.add (collection[i]);
  end;
end;

(**
 * Construct an empty TJSONArray.
*)
constructor TJSONArray.create;
begin
   myArrayList := TList.create;
end;

(**
     * Construct a TJSONArray from a source string.
     * @param string     A string that begins with
     * <code>[</code>&nbsp;<small>(left bracket)</small>
     *  and ends with <code>]</code>&nbsp;<small>(right bracket)</small>.
     *  @raises (ParseException The string must conform to JSON syntax.)
     *)
constructor TJSONArray.create(s: string);
var
 token : JSOnTokener;
begin
  token := JSONTokener.create(s);
  create (token);
  FreeAndNil(token);
end;

destructor TJSONArray.destroy;
var
 obj : TObject;
begin
  while myArrayList.Count > 0 do begin
    obj := TObject(myArrayList[0]);
    if    (obj <> CONST_FALSE)
      and (obj <> CONST_TRUE)
      and (obj <> CNULL)
      and (Assigned(obj)) then
     Begin
//      {$IFNDEF FPC}
//      Dispose(myArrayList[0]);
//      {$ELSE}
      FreeAndNil(obj);
//      {$ENDIF}
     End;
    myArrayList.Delete(0);
  end;
  FreeAndNil(myArrayList);
  inherited;
end;

(**
     * Get the object value associated with an index.
     * @param index
     *  The index must be between 0 and length() - 1.
     * @return An object value.
     * @raises (NoSuchElementException)
     *)
function TJSONArray.get(index: integer): TZAbstractObject;
var
  o : TZAbstractObject;
begin
  o := opt(index);
  if (o = nil) then begin
      raise NoSuchElementException.create('TJSONArray[' + intToStr(index)
        + '] not found.');
  end ;
  result := o;
end;

(**
     * Get the boolean value associated with an index.
     * The string values "true" and "false" are converted to boolean.
     *
     * @param index The index must be between 0 and length() - 1.
     * @return      The truth.
     * @raises (NoSuchElementException if the index is not found)
     * @raises (ClassCastException)
     *)
function TJSONArray.getBoolean(index: integer): boolean;
var
  o : TZAbstractObject;
begin
  o := get(index);
  if ((o.equals(_Boolean._FALSE) or
          ((o is _String) and
          (_String(o)).equalsIgnoreCase('false')))) then begin
      result := false;
      exit;
  end else if ((o.equals(_Boolean._TRUE) or
          ((o is _String) and
          (_String(o)).equalsIgnoreCase('true')))) then begin
      result := true;
      exit;
  end;
  raise ClassCastException.create('TJSONArray[' + intToStr(index) +
      '] not a Boolean.');
end;

(**
     * Get the double value associated with an index.
     *
     * @param index The index must be between 0 and length() - 1.
     * @return      The value.
     * @raises (NoSuchElementException if the key is not found)
     * @raises (NumberFormatException
     *  if the value cannot be converted to a number.)
     *)
function TJSONArray.getDouble(index: integer): double;
var
  o : TZAbstractObject;
  d : _Double;
begin
  o := get(index);
  if (o is _Number) then begin
      result := (_Number(o)).doubleValue();
      exit;
  end;
  if (o is _String) then begin
      d :=  _Double.create(_String(o));
      try
       result := d.doubleValue();
       exit;
      finally
       d.Free;
      end; 
  end;
  raise NumberFormatException.create('TJSONObject['
     + intToStr(index) + '] is not a number.');
end;

(**
     * Get the int value associated with an index.
     *
     * @param index The index must be between 0 and length() - 1.
     * @return      The value.
     * @raises (NoSuchElementException if the key is not found)
     * @raises (NumberFormatException
     *  if the value cannot be converted to a number.)
     *)
function TJSONArray.getInt(index: integer): integer;
var
  o : TZAbstractObject;
begin
  o := get(index);
  if (o is _Number) then begin
    result := _Number(o).intValue();
  end else begin
    result := trunc (getDouble (index));
  end;
end;

function TJSONArray.getInt64(index: integer): Int64;
var
  o : TZAbstractObject;
begin
  o := get(index);
  if (o is _Number) then begin
    result := _Number(o).int64Value();
  end else begin
    result := trunc (getDouble (index));
  end;
end;

{
     * Get the TJSONArray associated with an index.
     * @param index The index must be between 0 and length() - 1.
     * @return      A TJSONArray value.
     * @raises (NoSuchElementException if the index is not found or if the
     * value is not a TJSONArray)     }
function TJSONArray.getJSONArray(index: integer): TJSONArray;
var
 o : TZAbstractObject;
begin
  o := get(index);
  if (o is TJSONArray) then begin
      result := TJSONArray(o);
      exit;
  end;
  raise NoSuchElementException.create('TJSONArray[' + intToStr(index) +
          '] is not a TJSONArray.');
end;

(**
     * Get the TJSONObject associated with an index.
     * @param index subscript
     * @return      A TJSONObject value.
     * @raises (NoSuchElementException if the index is not found or if the
     * value is not a TJSONObject)
     *)
function TJSONArray.getJSONObject(index: integer): TJSONObject;
var
  o : TZAbstractObject;
  s : string;
begin
  o := get(index);
  if (o is TJSONObject) then begin
      result := TJSONObject(o);
  end else begin
      if o <> nil then begin
        s := o.ClassName;
      end else begin
        s := 'nil';
      end;
      raise NoSuchElementException.create('TJSONArray[' + intToStr(index) +
        '] is not a TJSONObject is ' + s);
  end;
end;

(**
     * Get the string associated with an index.
     * @param index The index must be between 0 and length() - 1.
     * @return      A string value.
     * @raises (NoSuchElementException)
     *)
function TJSONArray.getString(index: integer): string;
begin
  result := get(index).toString();
end;

(**
 * Determine if the value is null.
 * @param index The index must be between 0 and length() - 1.
 * @return true if the value at the index is null, or if there is no value.
 *)

function TJSONArray.isNull(index: integer): boolean;
var
 o : TZAbstractObject;
begin
 o := opt(index);
 result := (o = nil) or (o.equals(nil));
 If Not result Then
  result := o = cnull;
end;

(**
 * Make a string from the contents of this TJSONArray. The separator string
 * is inserted between each element.
 * Warning: This method assumes that the data structure is acyclical.
 * @param separator A string that will be inserted between the elements.
 * @return a string.
 *)
function TJSONArray.join(separator: string): string;
var
  len, i : integer;
  sb, s : string ;
begin
		len := length();
    sb := '';
    for i := 0 to len -1 do begin
        if (i > 0) then begin
            sb := sb + separator;
        end;
        s := TJSONObject.valueToString(TZAbstractObject( myArrayList[i]));
        sb:= sb + s;
    end;
    result := sb;
end;

(**
 * Get the length of the TJSONArray.
 *
 * @return The length (or size).
 *)
function TJSONArray.length: integer;
begin
  result := myArrayList.Count ;
end;

 {
      Get the optional object value associated with an index.
      @param index The index must be between 0 and length() - 1.
      @return      An object value, or null if there is no
                   object at that index.
     }
function TJSONArray.opt(index: integer): TZAbstractObject;
begin
    if ((index < 0) or (index >= length()) ) then begin
       result := nil;
    end else begin
      result := TZAbstractObject (myArrayList[index]);
    end;
end;

(**
     * Get the optional boolean value associated with an index.
     * It returns false if there is no value at that index,
     * or if the value is not Boolean.TRUE or the String "true".
     *
     * @param index The index must be between 0 and length() - 1.
     * @return      The truth.
     *)
function TJSONArray.optBoolean(index: integer): boolean;
begin
  result := optBoolean(index, false);
end;

(**
     * Get the optional boolean value associated with an index.
     * It returns the defaultValue if there is no value at that index or if it is not
     * a Boolean or the String "true" or "false" (case insensitive).
     *
     * @param index The index must be between 0 and length() - 1.
     * @param defaultValue     A boolean default.
     * @return      The truth.
     *)
function TJSONArray.optBoolean(index: integer;
  defaultValue: boolean): boolean;
var
 o : TZAbstractObject;
begin
  o := opt(index);
  if (o <> nil) then begin
      if ((o.equals(_Boolean._FALSE) or
              ((o is _String) and
              (_String(o)).equalsIgnoreCase('false')))) then begin
          result := false;
          exit;
      end else if ((o.equals(_Boolean._TRUE) or
              ((o is _String) and
              (_String(o)).equalsIgnoreCase('true')))) then begin
          result := true;
          exit;
      end;
  end;
  result := defaultValue;
end;

(**
 * Get the optional double value associated with an index.
 * NaN is returned if the index is not found,
 * or if the value is not a number and cannot be converted to a number.
 *
 * @param index The index must be between 0 and length() - 1.
 * @return      The value.
 *)
function TJSONArray.optDouble(index: integer): double;
begin
   result := optDouble(index, _Double.NaN);
end;

(**
 * Get the optional double value associated with an index.
 * The defaultValue is returned if the index is not found,
 * or if the value is not a number and cannot be converted to a number.
 *
 * @param index subscript
 * @param defaultValue     The default value.
 * @return      The value.
 *)
function TJSONArray.optDouble(index: integer; defaultValue :double): double;
var
 o : TZAbstractObject;
 d : _Double;
begin
  o := opt(index);
  if (o <> nil) then begin
      if (o is _Number) then begin
          result := (_Number(o)).doubleValue();
          exit;
      end;
      try
          d := _Double.create (_String (o));
          result := d.doubleValue ;
          d.Free;
	        exit;
      except
        on e:Exception  do begin
          result := defaultValue;
        end;
      end;
  end;
  result := defaultValue;
end;

(**
 * Get the optional int value associated with an index.
 * Zero is returned if the index is not found,
 * or if the value is not a number and cannot be converted to a number.
 *
 * @param index The index must be between 0 and length() - 1.
 * @return      The value.
 *)
function TJSONArray.optInt(index: integer): integer;
begin
  result := optInt(index, 0);
end;

(**
 * Get the optional int value associated with an index.
 * The defaultValue is returned if the index is not found,
 * or if the value is not a number and cannot be converted to a number.
 * @param index The index must be between 0 and length() - 1.
 * @param defaultValue     The default value.
 * @return      The value.
 *)
function TJSONArray.optInt(index, defaultValue: integer): integer;
var
  o : TZAbstractObject;
begin
  o := opt(index);
  if (o <> nil) then begin
      if (o is _Number) then begin
          result :=  (_Number(o)).intValue();
          exit;
      end;
      try
        result := _Integer.parseInt(_String(o));
        exit;
      except on e: exception do begin
        result := defaultValue;
        exit;
      end;
      end;
  end;
  result := defaultValue;
end;

function TJSONArray.optInt64(index: integer; defaultValue: int64): int64;
var
  o : TZAbstractObject;
begin
  o := opt(index);
  if (o <> nil) then begin
      if (o is _Number) then begin
          result :=  (_Number(o)).int64Value();
          exit;
      end;
      try
        result := _Int64.parseInt(_String(o));
        exit;
      except on e: exception do begin
        result := defaultValue;
        exit;
      end;
      end;
  end;
  result := defaultValue;
end;

function TJSONArray.optInt64(index: integer): int64;
begin
  result := optInt64(index, 0);
end;

(**
 * Get the optional TJSONArray associated with an index.
 * @param index subscript
 * @return      A TJSONArray value, or null if the index has no value,
 * or if the value is not a TJSONArray.
 *)
Function TJSONArray.optJSONArray(index: integer): TJSONArray;
Var
 o : TZAbstractObject;
Begin
 o := opt(index);
 If (o is TJSONArray) Then
  Result := TJSONArray(o)
 Else
  Result := Nil;
End;

(**
 * Get the optional TJSONObject associated with an index.
 * Null is returned if the key is not found, or null if the index has
 * no value, or if the value is not a TJSONObject.
 *
 * @param index The index must be between 0 and length() - 1.
 * @return      A TJSONObject value.
 *)

Function TJSONArray.optJSONObject(index: integer): TJSONObject;
Var
 o : TZAbstractObject;
Begin
 o := opt(index);
 If (o is TJSONObject) Then
  Result := TJSONObject(o)
 Else
  Result := Nil;
End;

(**
 * Get the optional string value associated with an index. It returns an
 * empty string if there is no value at that index. If the value
 * is not a string and is not null, then it is coverted to a string.
 *
 * @param index The index must be between 0 and length() - 1.
 * @return      A String value.
 *)

Function TJSONArray.optString(index: integer): string;
Begin
 Result := optString(index, '');
End;

(**
 * Get the optional string associated with an index.
 * The defaultValue is returned if the key is not found.
 *
 * @param index The index must be between 0 and length() - 1.
 * @param defaultValue     The default value.
 * @return      A String value.
 *)

Function TJSONArray.optString(index: integer; defaultValue: string): string;
Var
 o : TZAbstractObject;
Begin
 o := opt(index);
 If (o <> Nil) Then
  Result := o.toString
 Else
  Result := defaultValue;
End;

(**
 * Append a boolean value.
 *
 * @param value A boolean value.
 * @return this.
 *)

Function TJSONArray.put(value: boolean): TJSONArray;
Begin
 put(_Boolean.valueOf(value));
 Result :=  self;
End;

(**
 * Append a double value.
 *
 * @param value A double value.
 * @return this.
 *)

Function TJSONArray.put(value: double): TJSONArray;
Begin
 put(_Double.create(value));
 Result := self;
End;

(**
 * Append an int value.
 *
 * @param value An int value.
 * @return this.
 *)

Function TJSONArray.put(value: integer): TJSONArray;
Begin
 put(_Integer.create(value));
 Result := self;
End;

Function TJSONArray.put(value: string): TJSONArray;
Begin
 put(_String.create (value));
 Result := self;
End;

(**
 * Append an object value.
 * @param value An object value.  The value should be a
 *  Boolean, Double, Integer, TJSONArray, JSObject, or String, or the
 *  TJSONObject.NULL object.
 * @return this.
 *)

Function TJSONArray.put(value: TZAbstractObject): TJSONArray;
Begin
 myArrayList.add(value);
 Result := self;
End;

(**
 * Put or replace a boolean value in the TJSONArray.
 * @param index subscript The subscript. If the index is greater than the length of
 *  the TJSONArray, then null elements will be added as necessary to pad
 *  it out.
 * @param value A boolean value.
 * @return this.
 * @raises (NoSuchElementException The index must not be negative.)
 *)

Function TJSONArray.put(index: integer; value: boolean): TJSONArray;
Begin
 put(index, _Boolean.valueOf(value));
 Result := self;
End;

Function TJSONArray.put(index, value: integer): TJSONArray;
Begin
 put(index, _Integer.create(value));
 Result := self;
End;

Function TJSONArray.put(index: integer; value: double): TJSONArray;
Begin
 put(index, _Double.create(value));
 Result := self;
End;

Function TJSONArray.put(index: integer; value: string): TJSONArray;
Begin
 put(index,_String.create (value));
 Result := self;
End;

function TJSONArray.put(index: integer; value: int64): TJSONArray;
begin
 put(index, _Int64.create(value));
 Result := self;
end;

function TJSONArray.put(value: int64): TJSONArray;
begin
 put(_Int64.create(value));
 Result := self;
end;

(**
     * Put or replace an object value in the TJSONArray.
     * @param index The subscript. If the index is greater than the length of
     *  the TJSONArray, then null elements will be added as necessary to pad
     *  it out.
     * @param value An object value.
     * @return this.
     * @raises (NoSuchElementException The index must not be negative.)
     * @raises (NullPointerException   The index must not be null.)
     *)

Function TJSONArray.put(index: integer; value: TZAbstractObject): TJSONArray;
Begin
 If (index < 0) Then
  Raise NoSuchElementException.create('TJSONArray[' + intToStr(index) + '] not found.')
 Else If (value = Nil) Then
  Raise NullPointerException.create('')
 Else If (index < length()) Then
  myArrayList[index] := Value
 Else
  Begin
   While (index <> length) Do
    put(nil);
   put(value);
  End;
 Result := self;
End;

(**
 * Produce a TJSONObject by combining a TJSONArray of names with the values
 * of this TJSONArray.
 * @param names A TJSONArray containing a list of key strings. These will be
 * paired with the values.
 * @return A TJSONObject, or null if there are no names or if this TJSONArray
 * has no values.
 *)

Function TJSONArray.toJSONObject(names :TJSONArray): TJSONObject;
Var
 jo : TJSONObject;
 i  : Integer;
Begin
 If ((names = Nil)      Or
     (names.length = 0) Or
     (length = 0))      Then
  Result := Nil;
 jo := TJSONObject.Create;
 For i := 0 To names.length Do
  jo.put(names.getString(i), self.opt(i));
 Result := jo;
End;

(**
 * Make an JSON external form string of this TJSONArray. For compactness, no
 * unnecessary whitespace is added.
 * Warning: This method assumes that the data structure is acyclical.
 *
 * @return a printable, displayable, transmittable
 *  representation of the array.
 *)

Function TJSONArray.toString : String;
Begin
 Result := '[' + join(',') + ']';
End;

(**
     * Make a prettyprinted JSON string of this TJSONArray.
     * Warning: This method assumes that the data structure is non-cyclical.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @return a printable, displayable, transmittable
     *  representation of the object, beginning
     *  with <code>[</code>&nbsp;<small>(left bracket)</small> and ending
     *  with <code>]</code>&nbsp;<small>(right bracket)</small>.
     *)

Function TJSONArray.toString(indentFactor : Integer) : String;
Begin
 Result := toString(indentFactor, 0);
End;

(**
  * Make a TList of TJSONArray;
  * @return a TList object
*)

Function TJSONArray.toList : TList;
Begin
 Result := TList.Create;
 Result.Assign(myArrayList, laCopy);
End;

(**
     * Make a prettyprinted string of this TJSONArray.
     * Warning: This method assumes that the data structure is non-cyclical.
     * @param indentFactor The number of spaces to add to each level of
     *  indentation.
     * @param indent The indention of the top level.
     * @return a printable, displayable, transmittable
     *  representation of the array.
     *)

Function TJSONArray.toString(indentFactor, indent: integer): string;
Var
 len, i,j, newindent : integer;
 sb : string;
Begin
 len := length;
 If (len = 0) Then
  Begin
   Result := '[]';
   Exit;
  End;
 i := 0;
 sb := '[';
 If (len = 1) Then
  sb := sb + TJSONObject.valueToString(TZAbstractObject( myArrayList[0]),indentFactor, indent)
 Else
  Begin
   newindent := indent + indentFactor;
   sb := sb + #10 ;
   For i := 0 To len -1 Do
    Begin
     If (i > 0) Then
      sb := sb +',' + #10;
     For j := 0 To newindent -1 Do
      sb := sb + ' ';
     sb := sb + (TJSONObject.valueToString(TZAbstractObject(myArrayList[i]), indentFactor, newindent));
    End;
   sb := sb + #10;
   For i := 0 To indent -1 Do
    sb := sb + ' ';
  End;
 sb := sb + ']';
 Result := sb;
End;

{ _NULL }

Function NULL.Equals(Const Value: TZAbstractObject): Boolean;
Begin
 If (value = Nil) Then
  result := True
 Else
  Result := (value is NULL);
End;

Function NULL.toString : String;
Begin
 Result := 'null';
End;

{ TZAbstractObject }

Function TZAbstractObject.Clone : TZAbstractObject;
Begin
 Result := Nil;
 newNotImplmentedFeature;
End;

Function TZAbstractObject.Equals(Const Value : TZAbstractObject) : Boolean;
Begin
 Result := (value <> nil) And (value = self);
End;

Function TZAbstractObject.Hash: LongInt;
Begin
 Result := integer(addr(self));
End;

Function TZAbstractObject.InstanceOf(Const Value : TZAbstractObject) : Boolean;
Begin
 Result := value is TZAbstractObject;
End;

Function TZAbstractObject.ToString: string;
Begin
 Result := Format('%s <%p>', [ClassName, addr(Self)]);
End;

Procedure TJSONObject.clean;
Var
 vTempString : String;
 vTempStringSize : Integer;
begin
 If Assigned(myHashMap) Then
  Begin
   While myHashMap.Count > 0 do
    Begin
     If (myHashMap.Objects[0] <> CONST_FALSE) And
        (myHashMap.Objects[0] <> CONST_TRUE)  And
        (Assigned(myHashMap.Objects[0]))      Then
      Begin
       Try
        If (UpperCase(myHashMap.Objects[0].classname) <> 'NULL') And
           (myHashMap.Objects[0] <> CNULL) Then
         Begin
          If UpperCase(myHashMap.Objects[0].classname) = 'TJSONARRAY' Then
           Begin
            vTempString     := TJSONArray(myHashMap.Objects[0]).toString;
            vTempStringSize := StrDWLength(vTempString);
            If ((vTempString[InitStrPos] = '[') or
                (vTempString[InitStrPos] = '{')) And
               ((vTempString[vTempStringSize - FinalStrPos] = ']') or
                (vTempString[vTempStringSize - FinalStrPos] = '}')) Then
              myHashMap.Objects[0].Free;
           End
          Else
           myHashMap.Objects[0].Free;
         End;
       Except

       End;
      End;
     Try
      myHashMap.Delete(0);
     Except
      Exit;
     End;
    End;
  End;
End;

(**
* Assign the values to other json Object.
* @param TJSONObject  objeto to assign Values
*)

Procedure TJSONObject.assignTo(json : TJSONObject) ;
Var
 _keys : TStringList;
 i : integer;
Begin
 _keys := keys;
 Try
  For i := 0 To _keys.Count -1 Do
   json.put (_keys[i],get(_keys[i]).clone);
 Finally
  FreeAndNil(_keys);
 End;
End;

Function TJSONObject.clone: TZAbstractObject;
Var
 json : TJSONObject;
Begin
 json   := TJSONObject.Create(self.toString);
 result := json;
End;

{ _Number }

{ TStringListJSON }

Constructor TStringListJSON.Create;
Begin
  inherited Create;
End;

destructor TStringListJSON.Destroy;
Var
 I : Integer;
Begin
 For I := Count -1 DownTo 0 do
  Begin
   If Assigned(Self.Objects[I]) Then
    Begin
     Self.Objects[I].Free;
     Self.Objects[I] := Nil;
    End;
  End;
 Clear;
 Inherited;
End;

{ _Int64 }

function _Int64.clone: TZAbstractObject;
begin
  result := _Int64.create (self.fvalue);
end;

constructor _Int64.create(i: Int64);
begin
  fvalue := i;
end;

constructor _Int64.create(s: string);
begin
  fvalue := StrToInt64(s);
end;

function _Int64.doubleValue: double;
begin
  result := fvalue;
end;

function _Int64.intValue: Int64;
begin
  result := fvalue;
end;

class function _Int64.parseInt(s: _String): Int64;
begin
  result := _Int64.parseInt (s.toString, 19);
end;

class function _Int64.parseInt(s: string; i: Int64): Int64;
begin
  case i of
  10: begin
    result := StrToInt64 (s);
  end;
  16: begin
   result := HexToInt64 (s);
  end;
  8: begin
       if (s = '0') then begin
         result := 0
       end else begin
        newNotImplmentedFeature () ;
       end;
  end;
  end;
end;

class function _Int64.toHexString(c: char): string;
begin
  result := IntToHex(ord(c),2);
end;

function _Int64.toString: string;
begin
  result := intToStr(fvalue);
end;

Initialization
  CONST_FALSE := _Boolean.Create(false);
  CONST_TRUE  := _Boolean.Create(true);
  CNULL       := NULL.Create;

Finalization
  CONST_FALSE.free;
  CONST_TRUE.Free;
  CNULL.free;

End.

