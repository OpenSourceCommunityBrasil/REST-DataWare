unit uDWConstsCharset;

interface

uses
  Classes, SysUtils, Db;

Type
 TDatabaseCharSet = (csUndefined, csWin1250, csWin1251, csWin1252,
                     csWin1253,   csWin1254, csWin1255, csWin1256,
                     csWin1257,   csWin1258, csUTF8, csISO_8859_1,
                     csISO_8859_2);
 TEncodeSelect    = (esASCII,     esUtf8, esANSI);
 TObjectDirection = (odIN, odOUT, odINOUT);
 TSendEvent       = (seGET,       sePOST,
                     sePUT,       seDELETE,
                     sePatch);
 TWideChars       = Array of WideChar;
 TTypeRequest     = (trHttp,      trHttps);
 TDatasetEvents   = Procedure (DataSet: TDataSet) Of Object;

Type
 TDWAboutInfo    = (DWAbout);
 TMassiveDataset = Class
End;
Type
 TResultErro = Record
  Status,
  MessageText: String;
End;

Type
 TFieldDefinition = Class
 Public
  FieldName : String;
  DataType  : TFieldType;
  Size,
  Precision : Integer;
  Required  : Boolean;
End;

Type
 TFieldsList = Array of TFieldDefinition;

 Type
  TRESTDWClientInfo = Class(TObject)
 Private
  vip,
  vipVersion,
  vUserAgent,
  vBaseRequest,
  vToken,
  vRequest       : String;
  vport          : Integer;
 Public
  Procedure  SetClientInfo(ip, ipVersion,
                           UserAgent,
                           BaseRequest, Request : String;
                           port                 : Integer);
  Procedure  SetToken     (aToken : String);
  Constructor Create;
//  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property BaseRequest : String  Read vBaseRequest;
  Property Request     : String  Read vRequest;
  Property ip          : String  Read vip;
  Property UserAgent   : String  Read vUserAgent;
  Property port        : Integer Read vport;
  Property Token       : String  Read vToken;
 End;

Function URLDecode(ASrc : string) : String;

implementation

Uses uDWConsts;

Function URLDecode(ASrc : string) : String;
{$IFNDEF FPC}
 {$IF CompilerVersion < 25}
  Type
   TBytes = Array of Byte;
 {$IFEND}
{$ENDIF}
Var
 i: Integer;
 ESC: string;
 LChars : TWideChars;
 LBytes : TBytes;
 Function GetBytes(Const AChars: TWideChars): TBytes;
 Begin
  If AChars <> Nil Then
   Begin
    {$IF Defined(HAS_UTF8)}
     Result := TEncoding.ANSI.GetBytes(AChars); //TEncoding.ANSI.GetBytes(S));
    {$ELSE}
     {$IFDEF FPC}
      Result := TEncoding.ANSI.GetBytes(AChars); //TEncoding.ANSI.GetBytes(S));
     {$ELSE}
      {$IF CompilerVersion < 25}
       Move(Pointer(@AChars[InitStrPos])^, Result, Length(AChars));
      {$ELSE}
       Result :=  TEncoding.ANSI.GetBytes(AChars);
      {$IFEND}
     {$ENDIF}
    {$IFEND}
   End
  Else
   Result := nil;
 End;
 Procedure AppendByte(Var vBytes: TBytes; const AByte: Byte);
 Var
  LOldLen: Integer;
 Begin
  LOldLen := Length(VBytes);
  SetLength(VBytes, LOldLen + 1);
  VBytes[LOldLen] := AByte;
 End;
 Function IndyStrToInt(Const S : String): Integer;{$IFDEF USE_INLINE}inline;{$ENDIF}
 Begin
  Result := StrToInt(Trim(S));
 End;
 Function CharPosInSet(Const AString  : String;
                       Const ACharPos : Integer;
                       Const ASet     : String) : Integer;{$IFDEF USE_INLINE}inline;{$ENDIF}
 {$IFNDEF DOTNET}
 Var
  LChar: Char;
  I: Integer;
 {$ENDIF}
 Begin
  Result := 0;
  If ACharPos < 1 Then
   Raise  Exception.Create(PChar('Invalid ACharPos'));
  If ACharPos <= Length(AString) Then
   Begin
    {$IFDEF DOTNET}
    Result := ASet.IndexOf(AString[ACharPos]) + 1;
    {$ELSE}
    LChar := AString[ACharPos];
    For I := 1 To Length(ASet) Do
     Begin
      If ASet[I] = LChar Then
       Begin
        Result := I;
        Exit;
       End;
     End;
    {$ENDIF}
   End;
 End;
 Procedure CopyBytes(Const ASource      : TBytes;
                     Const ASourceIndex : Integer;
                     Var   VDest        : TBytes;
                     Const ADestIndex   : Integer;
                     Const ALength      : Integer);{$IFDEF USE_INLINE}Inline;{$ENDIF}
 Begin
  {$IFDEF DOTNET}
  System.array.Copy(ASource, ASourceIndex, VDest, ADestIndex, ALength);
  {$ELSE}
  Assert(ASourceIndex >= 0);
  Assert((ASourceIndex+ALength) <= Length(ASource));
  Move(ASource[ASourceIndex], VDest[ADestIndex], ALength);
  {$ENDIF}
 End;
 Procedure AppendBytes(Var   vBytes  : TBytes;
                       Const AToAdd  : TBytes;
                       Const AIndex  : Integer = 0;
                       Const ALength : Integer = -1);
 Var
  LOldLen, LAddLen: Integer;
  Function SizeMax(Const AValueOne,
                   AValueTwo        : Int64) : Int64;{$IFDEF USE_INLINE}inline;{$ENDIF}
  Begin
   If AValueOne < AValueTwo Then
    Result := AValueTwo
   Else
    Result := AValueOne;
  End;
  Function SizeMin(Const AValueOne,
                   AValueTwo        : Int64) : Int64;{$IFDEF USE_INLINE}inline;{$ENDIF}
  Begin
   If AValueOne > AValueTwo Then
    Result := AValueTwo
   Else
    Result := AValueOne;
  End;
  Function BytesLength(Const ABuffer : TBytes;
                       Const ALength : Integer = -1;
                       Const AIndex  : Integer = 0): Integer;{$IFDEF USE_INLINE}inline;{$ENDIF}
  Var
   LAvailable: Integer;
  Begin
   Assert(AIndex >= 0);
   LAvailable := SizeMax(Length(ABuffer)-AIndex, 0);
   If ALength < 0 Then
    Result := LAvailable
   Else
    Result := SizeMin(LAvailable, ALength);
  end;
 Begin
  LAddLen := BytesLength(AToAdd, ALength, AIndex);
  If LAddLen > 0 Then
   Begin
    LOldLen := Length(VBytes);
    SetLength(VBytes, LOldLen + LAddLen);
    CopyBytes(AToAdd, AIndex, VBytes, LOldLen, LAddLen);
   End;
 End;
 Function CharIsInSet(Const AString  : String;
                      Const ACharPos : Integer;
                      Const ASet     :  String) : Boolean;{$IFDEF USE_INLINE}Inline;{$ENDIF}
 Begin
  Result := CharPosInSet(AString, ACharPos, ASet) > 0;
 End;
Begin
 Result := '';
 LChars := Nil;
 LBytes := Nil;
 I := 1;
 While I <= Length(ASrc) Do
  Begin
   If ASrc[i] <> '%' Then
    Begin
     AppendByte(LBytes, Ord(ASrc[i])); // Copy the char
     Inc(i); // Then skip it
    End
   Else
    Begin
     Inc(i); //skip the % char
     If Not CharIsInSet(ASrc, i, 'uU') Then
      Begin  {do not localize}
       // simple ESC char
       ESC := Copy(ASrc, i, 2); // Copy the escape code
       Inc(i, 2); // Then skip it.
       Try
        AppendByte(LBytes, Byte(IndyStrToInt('$' + ESC))); {do not localize}
       Except
       End;
      End
     Else
      Begin
       ESC := Copy(ASrc, i+1, 4); // Copy the escape code
       Inc(i, 5); // Then skip it.
       Try
        If LChars = Nil Then
         SetLength(LChars, 1);
        LChars[0] := WideChar(IndyStrToInt('$' + ESC));  {do not localize}
        AppendBytes(LBytes, GetBytes(LChars));
       Except
       End;
      End;
    End;
  End;
  {$IFDEF STRING_IS_ANSI}
   SetString(Result, PAnsiChar(LBytes), Length(LBytes));
  {$ELSE}
   {$IFDEF FPC}
    Result := TEncoding.ANSI.GetString(LBytes);
   {$ELSE}
    {$IF CompilerVersion < 25}
     SetLength(Result, Length(PAnsiChar(LBytes)));
     Move(LBytes, Result[InitStrPos], Length(LBytes));
    {$ELSE}
     Result := TEncoding.ANSI.GetString(LBytes);
    {$IFEND}
   {$ENDIF}
  {$ENDIF}
 End;

Procedure  TRESTDWClientInfo.SetToken    (aToken : String);
Begin
 vToken := aToken;
End;

Procedure TRESTDWClientInfo.SetClientInfo(ip, ipVersion,
                                          UserAgent,
                                          BaseRequest, Request : String;
                                          port                 : Integer);
Begin
 vip          := Trim(ip);
 vUserAgent   := Trim(UserAgent);
 vipVersion   := Trim(ipVersion);
 vport        := Port;
 vBaseRequest := Request;
 vRequest     := BaseRequest;
End;

Constructor TRESTDWClientInfo.Create;
Begin
 Inherited;
 vip          := '0.0.0.0';
 vUserAgent   := 'Undefined';
 vport        := 0;
 vBaseRequest := '';
 vRequest     := '';
 vToken       := '';
 vipVersion   := '';
 vBaseRequest := '';
 vRequest     := '';
End;

end.


