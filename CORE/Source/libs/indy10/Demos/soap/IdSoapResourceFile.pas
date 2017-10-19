{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  15758: IdSoapResourceFile.pas 
{
{   Rev 1.0    11/2/2003 20:35:36  GGrieve
}
{
Version History:
  04-Sep 2002   Grahame Grieve                  Reduce dependency on idGlobal
  26-Jul 2002   Grahame Grieve                  D4 Compiler fixes
  07-May 2002   Andrew Cumming                  I forgot to use a unit...
  07-May 2002   Andrew Cumming                  First release
}


unit IdSoapResourceFile;

{$I IdSoapDefines.inc}

interface

uses
  {$IFNDEF DELPHI4}
  Contnrs,
  {$ENDIF}
  IdSoapDebug,
  IdSoapUtilities;

type
  TIdSoapResourceEntry = class(TIdBaseObject)
  private
    FResType: PChar;
    FSize: Cardinal;
    FDataVersion: Cardinal;
    FCharacteristics: Cardinal;
    FHeaderSize: Cardinal;
    FVersion: Cardinal;
    FData: Pointer;
    FName: String;
    FLanguage: Word;
    FFlags: Word;
    procedure SetSize(const Value: Cardinal);
    function GetResType: PChar;
    procedure SetResType(const Value: PChar);
    procedure SetName(const Value: String);
  public
    constructor create;
    destructor destroy; override;
    Property HeaderSize: Cardinal read FHeaderSize;
    Property ResType: PChar read GetResType write SetResType;  // eg RT_RCDATA
    Property Name: String read FName write SetName;
    Property DataVersion: Cardinal read FDataVersion write FDataVersion;
    Property Flags: Word read FFlags write FFlags;
    Property Language: Word read FLanguage write FLanguage;
    Property Version: Cardinal read FVersion write FVersion;
    Property Characteristics: Cardinal read FCharacteristics write FCharacteristics;
    Property Data: Pointer read FData;      // Dont forget to set the size BEFORE you move the data in
    Property Size: Cardinal read FSize write SetSize;
  end;

  TIdSoapResourceFile = Class(TIdBaseObject)
  private
    FResources: TObjectList;
    function GetCount: Integer;
    function GetResourceByName(AName: String): TIdSoapResourceEntry;
    function GetResources(AIndex: Integer): TIdSoapResourceEntry;
  public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure LoadFromFile(AFilename: String);
    Procedure SaveToFile(AFilename: String);
    Function Add(AResource: TIdSoapResourceEntry): Integer;
    Procedure Delete(AIndex: Integer);
    function Extract(AEntry: TIdSoapResourceEntry): TIdSoapResourceEntry;
    procedure Clear;
    property Count: Integer read GetCount;
    Property Resources[AIndex: Integer]: TIdSoapResourceEntry read GetResources; default;
    Property ResourceByName[AName: String]: TIdSoapResourceEntry read GetResourceByName;
  end;

implementation

Uses
  Classes,
  SysUtils;

type
  PCardinal = ^Cardinal;
  ResourceHeaderArray = array [1..8] of Cardinal;

const
  GValidResourceHeader : ResourceHeaderArray = (0,$20,$ffff,$ffff,0,0,0,0);

procedure FreeInternalResType(var ARes: PChar);
begin
  if (Cardinal(ARes) and $ffff0000) <> 0 then  // its a real string
    begin
    FreeMem(ARes);
    end;
  ARes := nil;
end;

function CopyInternalResourceType(ARes: PChar): PChar;
var
  LLen: Integer;
begin
  if (Cardinal(ARes) and $ffff0000) = 0 then
    begin
    result := ARes;
    end
  else
    begin
    LLen := (Length(ARes)+1) * Sizeof(Char);
    GetMem(result,LLen);
    move(ARes^,result^,LLen);
    end;
end;

function SameHeader(const AHeader1,AHeader2: ResourceHeaderArray): Boolean;
var
  i: Integer;
begin
  for i:=1 to 8 do
    begin
    if AHeader1[i] <> AHeader2[i] then
      begin
      result := false;
      exit;
      end;
    end;
  result := true;
end;

{ TIdSoapResourceEntry }

constructor TIdSoapResourceEntry.create;
begin
  inherited;
  FData := nil;
  FResType := nil;
end;

destructor TIdSoapResourceEntry.destroy;
begin
  if Assigned(FData) then
    begin
    FreeMem(FData);
    FData := nil;
    end;
  FreeInternalResType(FResType);
  inherited;
end;

function TIdSoapResourceEntry.GetResType: PChar;
begin
  result := FResType;
end;

procedure TIdSoapResourceEntry.SetSize(const Value: Cardinal);
begin
  FSize := Value;
  if Assigned(FData) then
    begin
    FreeMem(FData);
    end;
  FData := nil;
  if Value > 0 then
    begin
    GetMem(FData,Value);
    end;
end;

procedure TIdSoapResourceEntry.SetName(const Value: String);
begin
  FName := AnsiUpperCase(Value);  // for whatever reason, windows only seems to like upper case resource names
end;

procedure TIdSoapResourceEntry.SetResType(const Value: PChar);
begin
  FreeInternalResType(FResType);
  if (Cardinal(Value) and $ffff0000) <> 0 then
    begin
    FResType := CopyInternalResourceType(Value);
    end
  else
    begin
    FResType := Value;
    end;
end;

{ TIdSoapResourceFile }

function TIdSoapResourceFile.Add(AResource: TIdSoapResourceEntry): Integer;
begin
  result := -1;
  if Assigned(AResource) then
    begin
    Result := FResources.Add(AResource);
    end;
end;

procedure TIdSoapResourceFile.Clear;
begin
  FResources.Clear;
end;

constructor TIdSoapResourceFile.Create;
begin
  inherited;
  FResources := TObjectList.Create;
  FResources.OwnsObjects := True;
end;

procedure TIdSoapResourceFile.Delete(AIndex: Integer);
begin
  FResources.Delete(AIndex);
end;

destructor TIdSoapResourceFile.Destroy;
begin
  FreeAndNil(FResources);
  Inherited;
end;

function TIdSoapResourceFile.Extract(AEntry: TIdSoapResourceEntry): TIdSoapResourceEntry;
begin
  result := TObject(FResources.Extract(AEntry)) as TIdSoapResourceEntry;
end;

function TIdSoapResourceFile.GetCount: Integer;
begin
  result := FResources.Count;
end;

function TIdSoapResourceFile.GetResourceByName(AName: String): TIdSoapResourceEntry;
var
  i: Integer;
begin
  result := nil;
  AName := UpperCase(AName);
  for i:=0 to Count-1 do
    begin
    if AName = Resources[i].Name then
      begin
      result := Resources[i];
      break;
      end;
    end;
end;

function TIdSoapResourceFile.GetResources(AIndex: Integer): TIdSoapResourceEntry;
begin
  result := FResources[AIndex] as TIdSoapResourceEntry;
end;

Function LoadIdent(AStream: TFileStream): PChar;
var
  LWord: Word;
  LString: String;
begin
  AStream.ReadBuffer(LWord,sizeof(LWord));
  if LWord = $ffff then
    begin
    AStream.ReadBuffer(LWord,sizeof(LWord));
    result := PChar(LWord);
    end
  else
    begin
    LString := '';
    while LWord <> 0 do
      begin
      LString := LString + Char(LWord);
      AStream.ReadBuffer(LWord,sizeof(LWord));
      end;
    Result := CopyInternalResourceType(@LString[1]);
    end;
end;

procedure SaveIdent(AStream: TFileStream; AData: PChar);
var
  LCardinal: Cardinal;
  LErr: Integer;
  LWord: Word;
  LWideChar: WideChar;
  LWideString: WideString;
begin
  Assert(AData <> '','You must have a non empty string for a TYPE or resource NAME');
  if (Cardinal(AData) and $ffff0000) = 0 then
    begin
    LWord := $ffff;
    AStream.WriteBuffer(LWord,sizeof(LWord));
    LWord := Cardinal(AData) and $ffff;
    AStream.WriteBuffer(LWord,sizeof(LWord));
    end
  else if copy(AData,1,1) = '#' then  // its a number
    begin
    val(copy(AData,2,MaxInt),LCardinal,LErr);
    if LErr <> 0 then
      begin
      raise Exception.Create('Invalid number for resource name "' + AData + '"');
      end;
    if LCardinal > $ffff then
      begin
      raise Exception.Create('Invalid WORD size "' + AData + '"');
      end;
    LWord := $ffff;
    AStream.WriteBuffer(LWord,sizeof(LWord));
    AStream.WriteBuffer(LCardinal,sizeof(Word));  // only write a word size here
    end
  else
    begin
    LWideString := '';
    repeat
      LWideChar := WideChar(ord(AData^));
      if LWideChar <> #0 then
        begin
        LWideString := LWideString + LWideChar;
        end;
      inc(AData);
      until LWideChar = #0;
    AStream.WriteBuffer(LWideString[1],(length(LWideString)+1) * Sizeof(WideChar));
    end;
end;

procedure TIdSoapResourceFile.LoadFromFile(AFilename: String);
var
  LStream: TFileStream;
  LEntry: TIdSoapResourceEntry;
  LCardinal: Cardinal;
  LTemp: ResourceHeaderArray;
  LNextPosition: Cardinal;
  LPChar: PChar;
begin
  LStream := TFileStream.Create(AFilename,fmOpenRead);
  try
    LStream.ReadBuffer(LTemp,sizeof(LTemp));  // read resource header
    if not SameHeader(LTemp,GValidResourceHeader) then
      begin
      Raise Exception.Create('Invalid resource file');
      end;
    while LStream.Position < LStream.Size do
      begin
      LEntry := TIdSoapResourceEntry.Create;
      try
        LNextPosition := LStream.Position;
        LStream.ReadBuffer(LCardinal,sizeof(LCardinal));
        LEntry.Size := LCardinal;
        LStream.ReadBuffer(LEntry.FHeaderSize,sizeof(LEntry.FHeaderSize));
        LNextPosition := LNextPosition + LEntry.FHeaderSize;
        LPChar := LoadIdent(LStream);
        LEntry.ResType := LPChar;
        FreeInternalResType(LPChar);
        LEntry.Name := LoadIdent(LStream);
        LStream.ReadBuffer(LEntry.FDataVersion,sizeof(LEntry.FDataVersion));
        LStream.ReadBuffer(LEntry.FFlags,sizeof(LEntry.FFlags));
        LStream.ReadBuffer(LEntry.FLanguage,sizeof(LEntry.FLanguage));
        LStream.ReadBuffer(LEntry.FVersion,sizeof(LEntry.FVersion));
        LStream.ReadBuffer(LEntry.FCharacteristics,sizeof(LEntry.FCharacteristics));
        LStream.Position := LNextPosition;
        LStream.ReadBuffer(LEntry.FData^,LEntry.Size);
        Add(LEntry);
      except
        FreeAndNil(LEntry);
        raise;
        end;
      end;
  finally
    FreeAndNil(LStream);
    end;
end;

procedure TIdSoapResourceFile.SaveToFile(AFilename: String);
var
  LStream: TFileStream;
  LEntry: TIdSoapResourceEntry;
  LMark,LEnd: Integer;
  i: Integer;
  b: Byte;
begin
  LStream := TFileStream.Create(AFileName,fmCreate or fmOpenWrite);
  try
    LStream.WriteBuffer(GValidResourceHeader,Sizeof(GValidResourceHeader));
    for i:=0 to Count-1 do
      begin
      LEntry := Resources[i];
      LStream.WriteBuffer(LEntry.FSize,sizeof(LEntry.FSize));
      LMark := LStream.Position;  // might need to come back here to align stream
      LStream.WriteBuffer(LEntry.FHeaderSize,sizeof(LEntry.FHeaderSize));
      SaveIdent(LStream,LEntry.ResType);
      SaveIdent(LStream,@LEntry.Name[1]);
      LStream.WriteBuffer(LEntry.FDataVersion,sizeof(LEntry.FDataVersion));
      LStream.WriteBuffer(LEntry.FLags,sizeof(LEntry.FFlags));
      LStream.WriteBuffer(LEntry.FLanguage,sizeof(LEntry.FLanguage));
      LStream.WriteBuffer(LEntry.FVersion,sizeof(LEntry.FVersion));
      LStream.WriteBuffer(LEntry.FCharacteristics,sizeof(LEntry.FCharacteristics));
      while (LStream.Position and 7) <> 0 do  // we should be good and DWORD align it
        begin
        b := 0;
        LStream.WriteBuffer(b,sizeof(b));
        end;
      LEnd := LStream.Position;
      LStream.Position := LMark;
      LEntry.FHeaderSize := LEnd - LMark + sizeof(Cardinal);  // dont forget the Size
      if LEntry.FHeaderSize < 32 then  // must have at least 32 bytes
        begin
        LEntry.FHeaderSize := 32;
        end;
      LStream.WriteBuffer(LEntry.FHeaderSize,sizeof(LEntry.FHeaderSize));
      LStream.Position := LEnd;
      if LEntry.Size <> 0 then
        begin
        LStream.WriteBuffer(LEntry.Data^,LEntry.Size);
        end;
      end;
  finally
    FreeAndNil(LStream);
    end;
end;

end.

