unit uRESTDWITextEncoding;

{$mode ObjFPC}{$H+}

interface
 uses
  Classes, SysUtils;

type
TBytes = array of Byte;
TWideChars = array of PWideChar;

ITextEncoding = interface(IInterface) ['{FA87FAE5-E3E3-4632-8FCA-2FB786848655}']
    function GetByteCount(const AChars: TWideChars): Integer; overload;
    function GetByteCount(const AChars: TWideChars; ACharIndex, ACharCount: Integer): Integer; overload;
    {$IFNDEF DOTNET}
    function GetByteCount(const AChars: PWideChar; ACharCount: Integer): Integer; overload;
    {$ENDIF}
    function GetByteCount(const AStr: UnicodeString): Integer; overload;
    function GetByteCount(const AStr: UnicodeString; ACharIndex, ACharCount: Integer): Integer; overload;
    function GetBytes(const AChars: TWideChars): TBytes; overload;
    function GetBytes(const AChars: TWideChars; ACharIndex, ACharCount: Integer): TBytes; overload;
    function GetBytes(const AChars: TWideChars; ACharIndex, ACharCount: Integer; var VBytes: TBytes; AByteIndex: Integer): Integer; overload;
    {$IFNDEF DOTNET}
    function GetBytes(const AChars: PWideChar; ACharCount: Integer): TBytes; overload;
    function GetBytes(const AChars: PWideChar; ACharCount: Integer; var VBytes: TBytes; AByteIndex: Integer): Integer; overload;
    function GetBytes(const AChars: PWideChar; ACharCount: Integer; ABytes: PByte; AByteCount: Integer): Integer; overload;
    {$ENDIF}
    function GetBytes(const AStr: UnicodeString): TBytes; overload;
    function GetBytes(const AStr: UnicodeString; ACharIndex, ACharCount: Integer): TBytes; overload;
    function GetBytes(const AStr: UnicodeString; ACharIndex, ACharCount: Integer; var VBytes: TBytes; AByteIndex: Integer): Integer; overload;
    function GetCharCount(const ABytes: TBytes): Integer; overload;
    function GetCharCount(const ABytes: TBytes; AByteIndex, AByteCount: Integer): Integer; overload;
    {$IFNDEF DOTNET}
    function GetCharCount(const ABytes: PByte; AByteCount: Integer): Integer; overload;
    {$ENDIF}
    function GetChars(const ABytes: TBytes): TWideChars; overload;
    function GetChars(const ABytes: TBytes; AByteIndex, AByteCount: Integer): TWideChars; overload;
    function GetChars(const ABytes: TBytes; AByteIndex, AByteCount: Integer; var VChars: TWideChars; ACharIndex: Integer): Integer; overload;
    {$IFNDEF DOTNET}
    function GetChars(const ABytes: PByte; AByteCount: Integer): TWideChars; overload;
    function GetChars(const ABytes: PByte; AByteCount: Integer; var VChars: TWideChars; ACharIndex: Integer): Integer; overload;
    function GetChars(const ABytes: PByte; AByteCount: Integer; AChars: PWideChar; ACharCount: Integer): Integer; overload;
    {$ENDIF}
    function GetIsSingleByte: Boolean;
    function GetMaxByteCount(ACharCount: Integer): Integer;
    function GetMaxCharCount(AByteCount: Integer): Integer;
    function GetPreamble: TBytes;
    function GetString(const ABytes: TBytes): UnicodeString; overload;
    function GetString(const ABytes: TBytes; AByteIndex, AByteCount: Integer): UnicodeString; overload;
    {$IFNDEF DOTNET}
    function GetString(const ABytes: PByte; AByteCount: Integer): UnicodeString; overload;
    {$ENDIF}
    property IsSingleByte: Boolean read GetIsSingleByte;
  end;
function InterlockedCompareExchangePtr(var VTarget: Pointer; const AValue, Compare: Pointer): Pointer;
function InterlockedCompareExchangeIntf(var VTarget: IInterface; const AValue, Compare: IInterface): IInterface;


implementation

function InterlockedCompareExchangePtr(var VTarget: Pointer; const AValue,
  Compare: Pointer): Pointer;
begin

  Result := Pointer(
    {$IFDEF CPU64}InterlockedCompareExchange64{$ELSE}InterlockedCompareExchange{$ENDIF}
    (PtrInt(VTarget), PtrInt(AValue), PtrInt(Compare))
     );

end;

function InterlockedCompareExchangeIntf(var VTarget: IInterface; const AValue,
  Compare: IInterface): IInterface;
{$IFDEF USE_INLINE}inline;{$ENDIF}
begin
 // TInterlocked does not have an overload for IInterface.
 // We have to ensure that the reference counts of the interfaces are managed correctly...
 if AValue <> nil then begin
   AValue._AddRef;
 end;
 Result := IInterface(InterlockedCompareExchangePtr(Pointer(VTarget), Pointer(AValue), Pointer(Compare)));
 if (AValue <> nil) and (Pointer(Result) <> Pointer(Compare)) then begin
   AValue._Release;
 end;
end;


end.

