unit uRESTDWDynamic;

{$I ..\Includes\uRESTDW.inc}

Interface

Uses
  {$IFDEF RESTDWWINDOWS}Windows,{$ENDIF}
  SysUtils, Classes, TypInfo, RTLConsts;

Type
 {$IF not Defined(RESTDWLAZARUS) AND not Defined(DELPHIXEUP)}
 NativeInt             = Integer;
 NativeUInt            = Cardinal;
 PNativeInt            = ^NativeInt;
 PNativeUInt           = ^NativeUInt;
 {$IFEND}
 RDWSize                = NativeInt;
 PRDWPointerMath        = ^RDWPointerMath;
 RDWPointerMath         = NativeUInt;
 PRDWStrLen             = ^RDWStrLen;
 RDWStrLen              = Integer;
 PRDWArrayLen           = ^RDWArrayLen;
 RDWArrayLen            = NativeInt;
 PRDWArrayLen86         = ^RDWArrayLen86;
 RDWArrayLen86          = RDWStrLen;
 {$IF Declared(UnicodeString)}
 RDWUnicodeString       = UnicodeString;
 {$ELSE}
 RDWUnicodeString       = WideString;
 {$IFEND}
 TRESTDWDynamicOption  = (rdwAnsiStringCodePage, rdwUTF16ToUTF8, rdwLimitToWordSize, rdwCPUArchCompatibility);
 TRESTDWDynamicOptions = Set of TRESTDWDynamicOption;

Const
 TRESTDWDynamicDefaultOptions       = [rdwAnsiStringCodePage{$IFDEF RDWDYNAMIC_DEFAULT_UTF8}, rdwUTF16ToUTF8{$ENDIF}
                                       {$IFDEF RDWDYNAMIC_DEFAULT_WORDSIZE}, rdwLimitToWordSize{$ENDIF}
                                       {$IFDEF RDWDYNAMIC_DEFAULT_CPUARCH}, rdwCPUArchCompatibility{$ENDIF}];
 TRESTDWDynamicNetworkSafeOptions   = [rdwAnsiStringCodePage, rdwUTF16ToUTF8];
 TRESTDWDynamicNetworkUnsafeOptions = [rdwUTF16ToUTF8,        rdwLimitToWordSize];

Type
  RDWDynamic = class(Exception);
  RDWDynamicInvalidType = Class(RDWDynamic)
  Private
   FTypeKind : TTypeKind;
  Public
   Constructor Create(ATypeKind: TTypeKind);
   Property TypeKind: TTypeKind read FTypeKind;
  End;
  RDWDynamicLimit = Class(RDWDynamic)
  Public
   Constructor Create(ALen, AMaxLen: RDWArrayLen); Reintroduce;
  End;
  RDWDynamicWordLimit = Class(RDWDynamicLimit)
  Public
   Constructor Create(ALen: RDWArrayLen); Reintroduce;
  End;
  TRESTDWDynamic = Class
    Class Function  Compare(Const ADynamicType1,
                            ADynamicType2;
                            ATypeInfo            : PTypeInfo) : Boolean;
    Class Function  GetSize(Const ADynamicType;
                            ATypeInfo            : PTypeInfo;
                            Const AOptions       : TRESTDWDynamicOptions = TRESTDWDynamicDefaultOptions) : RDWSize;
    Class Procedure WriteTo(AStream              : TStream;
                            Const ADynamicType;
                            ATypeInfo            : PTypeInfo;
                            AVersion             : Word = 1;
                            Const AOptions       : TRESTDWDynamicOptions = TRESTDWDynamicDefaultOptions;
                            APreAllocSize        : Boolean = True);
    Class Function ReadFrom(AStream              : TStream;
                            Const ADynamicType;
                            ATypeInfo            : PTypeInfo;
                            AVersion             : Word = 1;
                            AForceCPUArchCompatibilityOnStreamV1: Boolean = False) : Boolean;
    Class Function GetSizeNH(Const ADynamicType;
                             ATypeInfo           : PTypeInfo;
                             Const AOptions      : TRESTDWDynamicOptions = TRESTDWDynamicDefaultOptions) : RDWSize;
    Class Procedure WriteToNH(AStream            : TStream;
                              Const ADynamicType;
                              ATypeInfo          : PTypeInfo;
                              Const AOptions     : TRESTDWDynamicOptions = TRESTDWDynamicDefaultOptions);
    Class Procedure ReadFromNH(AStream           : TStream;
                               Const ADynamicType;
                               ATypeInfo         : PTypeInfo;
                               Const AOptions    : TRESTDWDynamicOptions = TRESTDWDynamicDefaultOptions);
  End;
  TRESTDWDynamicHeader = Packed Record
    Stream      : Record
      Version,
      Options   : Byte;
    End;
    TypeVersion : Word;
  End;

Const
 cRDWDYNAMIC_STREAM_VERSION_v1   = $01;
 cRDWDYNAMIC_STREAM_VERSION_v2   = $02;
 cRDWDYNAMIC_STREAM_CFG_UNICODE  = $01;
 cRDWDYNAMIC_STREAM_CFG_UTF8     = $02;
 cRDWDYNAMIC_STREAM_CFG_WORDSIZE = $04;
 cRDWDYNAMIC_STREAM_CFG_CODEPAGE = $08;
 cRDWDYNAMIC_STREAM_CFG_CPUARCH  = $10;

Implementation

Const
 MAXWORD = 65535;

Type
 PPTypeInfo  = ^PTypeInfo;
 TFieldInfo  = Packed Record
  TypeInfo   : PPTypeInfo;
  Offset     : RDWPointerMath;
 End;
 PFieldTable = ^TFieldTable;
 TFieldTable = Packed Record
  X          : Word;
  Size,
  Count      : Cardinal;
  Fields     : Array [0..65535] Of TFieldInfo;
 End;
 PDynArrayTypeInfo = ^TDynArrayTypeInfo;
 TDynArrayTypeInfo = Packed Record
  kind,
  name       : Byte;
  elSize     : RDWArrayLen86;
  elType     : ^PDynArrayTypeInfo;
  varType    : Integer;
 End;

Function DynamicCompare_Array(ADynamic1,
                              ADynamic2    : Pointer;
                              ATypeInfo    : PTypeInfo;
                              ALength      : RDWArrayLen) : Boolean; forward;

Function DynamicCompare_Record(ADynamic1,
                               ADynamic2   : Pointer;
                               AFieldTable : PFieldTable) : Boolean;
Var
 lCompare  : RDWPointerMath;
 lOffset   : RDWPointerMath;
 lIdx      : RDWPointerMath;
 lTypeInfo : PTypeInfo;
Begin
 If AFieldTable^.Count = 0 Then
  Begin
   Result := CompareMem(ADynamic1, ADynamic2, AFieldTable^.Size);
   Exit;
  End;
 Result    := False;
 lCompare := 0;
 lIdx     := 0;
 While (lCompare < AFieldTable^.Size) And
       (lIdx < AFieldTable^.Count)    Do
  Begin
   lOffset := AFieldTable^.Fields[lIdx].Offset;
   If lCompare < lOffset Then
    If CompareMem(Pointer(RDWPointerMath(ADynamic1) + lCompare),
                  Pointer(RDWPointerMath(ADynamic2) + lCompare),
                  lOffset - lCompare) Then
     Inc(lCompare, lOffset - lCompare)
    Else
     Exit;
   lTypeInfo := AFieldTable^.Fields[lIdx].TypeInfo^;
   If DynamicCompare_Array(Pointer(RDWPointerMath(ADynamic1) + lOffset),
                           Pointer(RDWPointerMath(ADynamic2) + lOffset),
                           lTypeInfo, 1) Then
    Begin
     Case lTypeInfo^.Kind Of
      tkArray,
      tkRecord : Inc(lCompare, PFieldTable(RDWPointerMath(lTypeInfo) + PByte(@lTypeInfo^.Name)^)^.Size);
      Else Inc(lCompare, SizeOf(Pointer));
     End;
    End
   Else
    Exit;
   Inc(lIdx);
  End;
 If lCompare < AFieldTable^.Size Then
  If Not CompareMem(Pointer(RDWPointerMath(ADynamic1) + lCompare),
                    Pointer(RDWPointerMath(ADynamic2) + lCompare),
                    AFieldTable^.Size - lCompare) Then
   Exit;
 Result := True;
End;

Function DynamicCompare_DynArray(ADynamic1,
                                 ADynamic2 : Pointer;
                                 ATypeInfo : PTypeInfo) : Boolean;
Var
 lDyn  : PDynArrayTypeInfo;
 lLen,
 lLen2 : RDWArrayLen;
Begin
 Result := ADynamic1 = ADynamic2;
 If Result Then
  Exit;
 If PPointer(ADynamic1)^ = Nil Then
  lLen := 0
 Else
  lLen := PRDWArrayLen(PRDWPointerMath(ADynamic1)^ - SizeOf(RDWArrayLen))^;
 If PPointer(ADynamic2)^ = Nil Then
  lLen2 := 0
 Else
  lLen2 := PRDWArrayLen(PRDWPointerMath(ADynamic2)^ - SizeOf(RDWArrayLen))^;
 Result := lLen = lLen2;
 If (Not Result) Or (lLen = 0) Then
  Exit;
 lDyn := PDynArrayTypeInfo(RDWPointerMath(ATypeInfo) + PByte(@ATypeInfo^.Name)^);
 If lDyn^.elType = Nil Then
  Result := CompareMem(PPointer(ADynamic1)^, PPointer(ADynamic2)^, lLen * lDyn^.elSize)
 Else
  Result := DynamicCompare_Array(PPointer(ADynamic1)^,
                                 PPointer(ADynamic2)^,
                                 PTypeInfo(lDyn^.elType^),
                                 lLen);
End;

Function DynamicCompare_Array(ADynamic1,
                              ADynamic2  : Pointer;
                              ATypeInfo  : PTypeInfo;
                              ALength    : RDWArrayLen) : Boolean;
Var
 lFieldTable : PFieldTable;
Begin
 Result := (ALength = 0) or (ADynamic1 = ADynamic2);
 If Result Then
  Exit;
 Case ATypeInfo^.Kind Of
  {$IF Declared(AnsiString)}
  tkLString : Begin
               While ALength > 0 Do
                Begin
                 If ADynamic1 <> ADynamic2 Then
                  If PAnsiString(ADynamic1)^ <> PAnsiString(ADynamic2)^ Then
                   Exit;
                 Inc(PPointer(ADynamic1));
                 Inc(PPointer(ADynamic2));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  {$IF Declared(WideString)}
  tkWString : Begin
               While ALength > 0 Do
                Begin
                 If ADynamic1 <> ADynamic2 Then
                  If PWideString(ADynamic1)^ <> PWideString(ADynamic2)^ Then
                   Exit;
                 Inc(PPointer(ADynamic1));
                 Inc(PPointer(ADynamic2));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  {$IF Declared(UnicodeString)}
  tkUString : Begin
               While ALength > 0 Do
                Begin
                 If ADynamic1 <> ADynamic2 Then
                  If PUnicodeString(ADynamic1)^ <> PUnicodeString(ADynamic2)^ Then
                    Exit;
                 Inc(PPointer(ADynamic1));
                 Inc(PPointer(ADynamic2));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  tkArray   : Begin
               lFieldTable := PFieldTable(RDWPointerMath(ATypeInfo) + PByte(@PTypeInfo(ATypeInfo)^.Name)^);
               While ALength > 0 Do
                Begin
                 If Not DynamicCompare_Array(ADynamic1, ADynamic2, lFieldTable^.Fields[0].TypeInfo^, lFieldTable^.Count) Then
                  Exit;
                 Inc(RDWPointerMath(ADynamic1), lFieldTable^.Size);
                 Inc(RDWPointerMath(ADynamic2), lFieldTable^.Size);
                 Dec(ALength);
                End;
              End;
  tkRecord  : Begin
               lFieldTable := PFieldTable(RDWPointerMath(ATypeInfo) + PByte(@PTypeInfo(ATypeInfo)^.Name)^);
               While ALength > 0 Do
                Begin
                 If not DynamicCompare_Record(ADynamic1, ADynamic2, lFieldTable) Then
                  Exit;
                 Inc(RDWPointerMath(ADynamic1), lFieldTable^.Size);
                 Inc(RDWPointerMath(ADynamic2), lFieldTable^.Size);
                 Dec(ALength);
                End;
              End;
  tkDynArray : Begin
                While ALength > 0 Do
                 Begin
                  If Not DynamicCompare_DynArray(ADynamic1, ADynamic2, ATypeInfo) Then
                   Exit;
                  Inc(PPointer(ADynamic1));
                  Inc(PPointer(ADynamic2));
                  Dec(ALength);
                 End;
               End
  Else
   Raise RDWDynamicInvalidType.Create(ATypeInfo^.Kind);
 End;
 Result := True;
End;

Function DynamicGetSize_Array(ADynamic        : Pointer;
                              ATypeInfo       : PTypeInfo;
                              ALength         : RDWArrayLen;
                              Const AOptions  : TRESTDWDynamicOptions) : RDWSize; Forward;

Function DynamicGetSize_Record(ADynamic       : Pointer;
                               AFieldTable    : PFieldTable;
                               Const AOptions : TRESTDWDynamicOptions) : RDWSize;
Var
 lCompare,
 lOffset,
 lIdx      : RDWPointerMath;
 lTypeInfo : PTypeInfo;
Begin
 If AFieldTable^.Count = 0 Then
  Begin
   Result := AFieldTable^.Size;
   Exit;
  End;
 lCompare := 0;
 lIdx := 0;
 Result := 0;
 While (lCompare < AFieldTable^.Size) And
       (lIdx < AFieldTable^.Count)    Do
  Begin
   lOffset := AFieldTable^.Fields[lIdx].Offset;
   If lCompare < lOffset Then
    Begin
     Inc(Result, lOffset - lCompare);
     Inc(lCompare, lOffset - lCompare)
    End;
   lTypeInfo := AFieldTable^.Fields[lIdx].TypeInfo^;
   Inc(Result, DynamicGetSize_Array(Pointer(RDWPointerMath(ADynamic) + lOffset),
                                    lTypeInfo, 1, AOptions));
   Case lTypeInfo^.Kind Of
    tkArray,
    tkRecord : Inc(lCompare, PFieldTable(RDWPointerMath(lTypeInfo) + PByte(@lTypeInfo^.Name)^)^.Size);
    Else Inc(lCompare, SizeOf(Pointer));
   End;
   Inc(lIdx);
  End;
 If lCompare < AFieldTable^.Size Then
  Inc(Result, AFieldTable^.Size - lCompare);
End;

Function DynamicGetSize_DynArray(ADynamic       : Pointer;
                                 ATypeInfo      : PTypeInfo;
                                 Const AOptions : TRESTDWDynamicOptions) : RDWSize;
Var
 lDyn : PDynArrayTypeInfo;
 lLen : RDWArrayLen;
Begin
 If rdwLimitToWordSize in AOptions Then
  Result := SizeOf(Word)
 Else
  Begin
   If rdwCPUArchCompatibility in AOptions Then
    Result := SizeOf(RDWArrayLen86)
   Else
    Result := SizeOf(RDWArrayLen); // dynamic array length
  End;
 If PPointer(ADynamic)^ = Nil Then
  Exit;
 lLen := PRDWArrayLen(PRDWPointerMath(ADynamic)^ - SizeOf(RDWArrayLen))^;
 If (rdwLimitToWordSize in AOptions) And (lLen > MAXWORD) Then
  Raise RDWDynamicWordLimit.Create(lLen);
 {$IFDEF CPUX64}
  If (rdwCPUArchCompatibility In AOptions) And (lLen > MaxInt) Then
   Raise RDWDynamicLimit.Create(lLen, MaxInt);
 {$ENDIF}
 lDyn := PDynArrayTypeInfo(RDWPointerMath(ATypeInfo) + PByte(@ATypeInfo^.Name)^);
 If lDyn^.elType = Nil Then
  Inc(Result, lLen * lDyn^.elSize)
 Else
  Inc(Result, DynamicGetSize_Array(PPointer(ADynamic)^,
                                   PTypeInfo(lDyn^.elType^),
                                   lLen, AOptions));
End;

Function DynamicGetSize_Array(ADynamic       : Pointer;
                              ATypeInfo      : PTypeInfo;
                              ALength        : RDWArrayLen;
                              Const AOptions : TRESTDWDynamicOptions) : RDWSize;
Var
 lFieldTable : PFieldTable;
 lStrLen     : RDWStrLen;
Begin
 Result := 0;
 If ALength = 0 Then
  Exit;
 Case ATypeInfo^.Kind of
  {$IF Declared(AnsiString)}
  tkLString : Begin
               While ALength > 0 Do
                Begin
                 If rdwLimitToWordSize In AOptions Then
                  Inc(Result, SizeOf(Word))
                 Else
                  Inc(Result, SizeOf(RDWStrLen));
                 If PPointer(ADynamic)^ <> nil then
                  Begin
                   lStrLen := Length(PAnsiString(ADynamic)^);
                   If lStrLen > 0 Then
                    Begin
                     If (rdwLimitToWordSize In AOptions) And (lStrLen > MAXWORD) Then
                      Raise RDWDynamicWordLimit.Create(lStrLen);
                     Inc(Result, lStrLen * SizeOf(AnsiChar));
                     If rdwAnsiStringCodePage In AOptions Then
                      Inc(Result, SizeOf(Word));
                    End;
                  End;
                 Inc(PPointer(ADynamic));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  {$IF Declared(WideString)}
  tkWString : Begin
               While ALength > 0 do
                Begin
                 If rdwLimitToWordSize In AOptions Then
                  Inc(Result, SizeOf(Word))
                 Else
                  Inc(Result, SizeOf(RDWStrLen));
                 If PPointer(ADynamic)^ <> Nil Then
                  Begin
                   lStrLen := Length(PWideString(ADynamic)^);
                   If lStrLen > 0 Then
                    Begin
                     If rdwUTF16ToUTF8 In AOptions Then
                      Begin
                       lStrLen := UnicodeToUtf8(nil, MaxInt, PWideChar(ADynamic^), lStrLen);
                       If lStrLen = 0 Then
                        Raise RDWDynamic.Create('UnicodeToUtf8 failed!');
                      End;
                     If (rdwLimitToWordSize In AOptions) And (lStrLen > MAXWORD) Then
                      Raise RDWDynamicWordLimit.Create(lStrLen);
                     If rdwUTF16ToUTF8 In AOptions Then
                      Inc(Result, lStrLen)
                     Else
                      Inc(Result, lStrLen * SizeOf(WideChar));
                    End;
                  End;
                 Inc(PPointer(ADynamic));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  {$IF Declared(UnicodeString)}
  tkUString : Begin
               While ALength > 0 Do
                Begin
                 If rdwLimitToWordSize In AOptions Then
                  Inc(Result, SizeOf(Word))
                 Else
                  Inc(Result, SizeOf(RDWStrLen));
                 If PPointer(ADynamic)^ <> Nil Then
                  Begin
                   lStrLen := Length(PUnicodeString(ADynamic)^);
                   If lStrLen > 0 Then
                    Begin
                     If rdwUTF16ToUTF8 In AOptions Then
                      Begin
                       lStrLen := UnicodeToUtf8(nil, MaxInt, PWideChar(ADynamic^), lStrLen);
                       If lStrLen = 0 then
                        Raise RDWDynamic.Create('UnicodeToUtf8 failed!');
                      End;
                     If (rdwLimitToWordSize in AOptions) And (lStrLen > MAXWORD) Then
                      Raise RDWDynamicWordLimit.Create(lStrLen);
                     If rdwUTF16ToUTF8 In AOptions Then
                      Inc(Result, lStrLen)
                     Else
                      Inc(Result, lStrLen * SizeOf(WideChar));
                    End;
                  End;
                 Inc(PPointer(ADynamic));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  tkArray : Begin
             lFieldTable := PFieldTable(RDWPointerMath(ATypeInfo) + PByte(@PTypeInfo(ATypeInfo)^.Name)^);
             While ALength > 0 Do
              Begin
               Inc(Result, DynamicGetSize_Array(ADynamic,
                                                lFieldTable^.Fields[0].TypeInfo^,
                                                lFieldTable^.Count,
                                                AOptions));
               Inc(RDWPointerMath(ADynamic), lFieldTable^.Size);
               Dec(ALength);
              End;
            End;

  tkRecord : Begin
              lFieldTable := PFieldTable(RDWPointerMath(ATypeInfo) + PByte(@PTypeInfo(ATypeInfo)^.Name)^);
              While ALength > 0 do
               Begin
                Inc(Result, DynamicGetSize_Record(ADynamic, lFieldTable, AOptions));
                Inc(RDWPointerMath(ADynamic), lFieldTable^.Size);
                Dec(ALength);
               End;
             End;
  tkDynArray : Begin
                While ALength > 0 Do
                 Begin
                  Inc(Result, DynamicGetSize_DynArray(ADynamic, ATypeInfo, AOptions));
                  Inc(RDWPointerMath(ADynamic), SizeOf(Pointer));
                  Dec(ALength);
                 End;
               End
  Else
   Raise RDWDynamicInvalidType.Create(ATypeInfo^.Kind);
 End;
End;

Procedure TStream_WriteBuffer(AStream : TStream;
                              Var ABuffer;
                              ACount  : Integer);
Begin
 If (ACount <> 0)                              And
    (AStream.Write(ABuffer, ACount) <> ACount) Then
  Raise EWriteError.CreateRes(@SWriteError);
End;

Procedure DynamicWrite_Array(AStream         : TStream;
                             ADynamic        : Pointer;
                             ATypeInfo       : PTypeInfo;
                             ALength         : RDWArrayLen;
                             Const AOptions  : TRESTDWDynamicOptions); Forward;

Procedure DynamicWrite_Record(AStream        : TStream;
                              ADynamic       : Pointer;
                              AFieldTable    : PFieldTable;
                              Const AOptions : TRESTDWDynamicOptions);
Var
 lCompare,
 lOffset,
 lIdx      : RDWPointerMath;
 lTypeInfo : PTypeInfo;
Begin
 If AFieldTable^.Count = 0 Then
  Begin
   TStream_WriteBuffer(AStream, PByte(ADynamic)^, AFieldTable^.Size);
   Exit;
  End;
 lCompare := 0;
 lIdx := 0;
 While (lCompare < AFieldTable^.Size) And
       (lIdx < AFieldTable^.Count)    Do
  Begin
   lOffset := AFieldTable^.Fields[lIdx].Offset;
   If lCompare < lOffset Then
    Begin
     TStream_WriteBuffer(AStream, PByte((RDWPointerMath(ADynamic) + lCompare))^, lOffset - lCompare);
     Inc(lCompare, lOffset - lCompare);
    End;
   lTypeInfo := AFieldTable^.Fields[lIdx].TypeInfo^;
   DynamicWrite_Array(AStream, Pointer(RDWPointerMath(ADynamic) + lOffset), lTypeInfo, 1, AOptions);
   Case lTypeInfo^.Kind Of
    tkArray,
    tkRecord : Inc(lCompare, PFieldTable(RDWPointerMath(lTypeInfo) + PByte(@lTypeInfo^.Name)^)^.Size);
    Else Inc(lCompare, SizeOf(Pointer));
   End;
   Inc(lIdx);
  End;
 If lCompare < AFieldTable^.Size Then
  TStream_WriteBuffer(AStream, PByte(RDWPointerMath(ADynamic) + lCompare)^, AFieldTable^.Size - lCompare);
End;

Procedure DynamicWrite_DynArray(AStream        : TStream;
                                ADynamic       : Pointer;
                                ATypeInfo      : PTypeInfo;
                                Const AOptions : TRESTDWDynamicOptions);
Var
 lDyn : PDynArrayTypeInfo;
 lLen : RDWArrayLen;
Begin
 If PPointer(ADynamic)^ = Nil Then
  lLen := 0
 Else
  lLen := PRDWArrayLen(PRDWPointerMath(ADynamic)^ - SizeOf(RDWArrayLen))^;
 If rdwLimitToWordSize In AOptions Then
  Begin
   If lLen > MAXWORD Then
    Raise RDWDynamicWordLimit.Create(lLen);
   TStream_WriteBuffer(AStream, lLen, SizeOf(Word));
  End
 Else
  Begin
   If rdwCPUArchCompatibility In AOptions Then
    Begin
     {$IFDEF CPUX64}
     If lLen > MaxInt Then
      Raise RDWDynamicLimit.Create(lLen, MaxInt);
     {$ENDIF}
     TStream_WriteBuffer(AStream, lLen, SizeOf(RDWArrayLen86));
    End
   Else
    TStream_WriteBuffer(AStream, lLen, SizeOf(RDWArrayLen));
  End;
 If lLen = 0 Then
  Exit;
 lDyn := PDynArrayTypeInfo(RDWPointerMath(ATypeInfo) + PByte(@ATypeInfo^.Name)^);
 If lDyn^.elType = Nil Then
  TStream_WriteBuffer(AStream, PByte(ADynamic^)^, lLen * lDyn^.elSize)
 Else
  DynamicWrite_Array(AStream, PPointer(ADynamic)^, PTypeInfo(lDyn^.elType^), lLen, AOptions);
End;

Procedure DynamicWrite_UTF16AsUFT8(AStream        : TStream;
                                   APWideChar     : PPWideChar;
                                   ALen           : RDWStrLen;
                                   Const AOptions : TRESTDWDynamicOptions);
Var
 lUTF8   : Pointer;
 lStrLen : RDWStrLen;
Begin
 If ALen = 0 Then
  Begin
   If rdwLimitToWordSize In AOptions Then
    TStream_WriteBuffer(AStream, ALen, SizeOf(Word))
   Else
    TStream_WriteBuffer(AStream, ALen, SizeOf(RDWStrLen));
   Exit;
  End;
 lStrLen := UnicodeToUtf8(Nil, MaxInt, APWideChar^, ALen);
 If lStrLen = 0 Then
  Raise RDWDynamic.Create('UnicodeToUtf8 failed!');
 GetMem(lUTF8, lStrLen + 1);
 If UnicodeToUtf8(lUTF8, lStrLen + 1, APWideChar^, ALen) <> Cardinal(lStrLen + 1) Then
  Begin
   FreeMem(lUTF8);
   Raise RDWDynamic.Create('UnicodeToUtf8 failed!');
  End;
 If rdwLimitToWordSize In AOptions Then
  Begin
   If lStrLen > MAXWORD Then
    Begin
     FreeMem(lUTF8);
     Raise RDWDynamicWordLimit.Create(lStrLen);
    End;
   If AStream.Write(lStrLen, SizeOf(Word)) <> SizeOf(Word) Then
    Begin
     FreeMem(lUTF8);
     Raise EWriteError.CreateRes(@SWriteError);
    End;
  End
 Else
  Begin
   If AStream.Write(lStrLen, SizeOf(RDWStrLen)) <> SizeOf(RDWStrLen) Then
    Begin
     FreeMem(lUTF8);
     Raise EWriteError.CreateRes(@SWriteError);
    End;
  End;
 If AStream.Write(lUTF8^, lStrLen) <> lStrLen Then
  Begin
   FreeMem(lUTF8);
   Raise EWriteError.CreateRes(@SWriteError);
  End;
 FreeMem(lUTF8);
End;

Procedure DynamicWrite_Array(AStream        : TStream;
                             ADynamic       : Pointer;
                             ATypeInfo      : PTypeInfo;
                             ALength        : RDWArrayLen;
                             Const AOptions : TRESTDWDynamicOptions);
Var
 lFieldTable : PFieldTable;
 lStrLen     : RDWStrLen;
 {$IF Declared(AnsiString)}
  lCP        : Word;
 {$IFEND}
Begin
 If ALength = 0 Then
  Exit;
 Case ATypeInfo^.Kind Of
  {$IF Declared(AnsiString)}
  tkLString : Begin
               While ALength > 0 Do
                Begin
                 If PPointer(ADynamic)^ = Nil Then
                  lStrLen := 0
                 Else
                  lStrLen := Length(PAnsiString(ADynamic)^);
                 If rdwLimitToWordSize In AOptions Then
                  Begin
                   If lStrLen > MAXWORD Then
                    Raise RDWDynamicWordLimit.Create(lStrLen);
                   TStream_WriteBuffer(AStream, lStrLen, SizeOf(Word));
                  End
                 Else
                  TStream_WriteBuffer(AStream, lStrLen, SizeOf(RDWStrLen));
                 If lStrLen > 0 Then
                  Begin
                   TStream_WriteBuffer(AStream, PByte(ADynamic^)^, lStrLen * SizeOf(AnsiChar));
                   If rdwAnsiStringCodePage In AOptions Then
                    Begin
                     {$IF Declared(UnicodeString)}
                      lCP := PWord(PRDWPointerMath(ADynamic)^ - 12)^;
                     {$ELSE}
                      lCP := GetACP;
                     {$IFEND}
                     TStream_WriteBuffer(AStream, lCP, SizeOf(Word));
                    End;
                  End;
                 Inc(PPointer(ADynamic));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  {$IF Declared(WideString)}
  tkWString : Begin
               While ALength > 0 Do
                Begin
                 If PPointer(ADynamic)^ = Nil Then
                  lStrLen := 0
                 Else
                  lStrLen := Length(PWideString(ADynamic)^);
                 If rdwUTF16ToUTF8 In AOptions Then
                  DynamicWrite_UTF16AsUFT8(AStream, ADynamic, lStrLen, AOptions)
                 Else
                  Begin
                   If rdwLimitToWordSize In AOptions Then
                    Begin
                     If lStrLen > MAXWORD Then
                      Raise RDWDynamicWordLimit.Create(lStrLen);
                     TStream_WriteBuffer(AStream, lStrLen, SizeOf(Word));
                    End
                   Else
                    TStream_WriteBuffer(AStream, lStrLen, SizeOf(RDWStrLen));
                   If lStrLen > 0 Then
                    TStream_WriteBuffer(AStream, PByte(ADynamic^)^, lStrLen * SizeOf(WideChar));
                  End;
                 Inc(PPointer(ADynamic));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  {$IF Declared(UnicodeString)}
  tkUString : Begin
               While ALength > 0 Do
                Begin
                 If PPointer(ADynamic)^ = Nil Then
                  lStrLen := 0
                 Else
                  lStrLen := Length(PUnicodeString(ADynamic)^);
                 If rdwUTF16ToUTF8 In AOptions Then
                  DynamicWrite_UTF16AsUFT8(AStream, ADynamic, lStrLen, AOptions)
                 Else
                  Begin
                   If rdwLimitToWordSize In AOptions Then
                    Begin
                     If lStrLen > MAXWORD Then
                      Raise RDWDynamicWordLimit.Create(lStrLen);
                     TStream_WriteBuffer(AStream, lStrLen, SizeOf(Word));
                    End
                   Else
                    TStream_WriteBuffer(AStream, lStrLen, SizeOf(RDWStrLen));
                   If lStrLen > 0 Then
                    TStream_WriteBuffer(AStream, PByte(ADynamic^)^, lStrLen * SizeOf(WideChar));
                  End;
                 Inc(PPointer(ADynamic));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  tkArray : Begin
             lFieldTable := PFieldTable(RDWPointerMath(ATypeInfo) + PByte(@PTypeInfo(ATypeInfo)^.Name)^);
             While ALength > 0 Do
              Begin
               DynamicWrite_Array(AStream, ADynamic, lFieldTable^.Fields[0].TypeInfo^, lFieldTable^.Count, AOptions);
               Inc(RDWPointerMath(ADynamic), lFieldTable^.Size);
               Dec(ALength);
              End;
            End;
  tkRecord : Begin
              lFieldTable := PFieldTable(RDWPointerMath(ATypeInfo) + PByte(@PTypeInfo(ATypeInfo)^.Name)^);
              While ALength > 0 Do
               Begin
                DynamicWrite_Record(AStream, ADynamic, lFieldTable, AOptions);
                Inc(RDWPointerMath(ADynamic), lFieldTable^.Size);
                Dec(ALength);
               End;
             End;
  tkDynArray : Begin
                While ALength > 0 Do
                 Begin
                  DynamicWrite_DynArray(AStream, ADynamic, ATypeInfo, AOptions);
                  Inc(RDWPointerMath(ADynamic), SizeOf(Pointer));
                  Dec(ALength);
                 End;
               End
  Else
   Raise RDWDynamicInvalidType.Create(ATypeInfo^.Kind);
 End;
End;

Procedure TStream_ReadBuffer(AStream      : TStream;
                             Var ABuffer;
                             ACount       : Integer);
Begin
 If (ACount <> 0)                             And
    (AStream.Read(ABuffer, ACount) <> ACount) Then
  Raise EReadError.CreateRes(@SReadError);
End;

Procedure DynamicRead_Array(AStream         : TStream;
                            ADynamic        : Pointer;
                            ATypeInfo       : PTypeInfo;
                            ALength         : RDWArrayLen;
                            Const AOptions  : TRESTDWDynamicOptions); Forward;

Procedure DynamicRead_Record(AStream        : TStream;
                             ADynamic       : Pointer;
                             AFieldTable    : PFieldTable;
                             Const AOptions : TRESTDWDynamicOptions);
Var
 lCompare,
 lOffset,
 lIdx      : RDWPointerMath;
 lTypeInfo : PTypeInfo;
Begin
 If AFieldTable^.Count = 0 Then
  Begin
   TStream_ReadBuffer(AStream, PByte(ADynamic)^, AFieldTable^.Size);
   Exit;
  End;
 lCompare := 0;
 lIdx := 0;
 While (lCompare < AFieldTable^.Size) And
       (lIdx < AFieldTable^.Count)    Do
  Begin
   lOffset := AFieldTable^.Fields[lIdx].Offset;
   If lCompare < lOffset Then
    Begin
     TStream_ReadBuffer(AStream, PByte(RDWPointerMath(ADynamic) + lCompare)^, lOffset - lCompare);
     Inc(lCompare, lOffset - lCompare);
    End;
   lTypeInfo := AFieldTable^.Fields[lIdx].TypeInfo^;
   DynamicRead_Array(AStream,
                     Pointer(RDWPointerMath(ADynamic) + lOffset),
                     lTypeInfo, 1, AOptions);
   Case lTypeInfo^.Kind Of
    tkArray,
    tkRecord : Inc(lCompare, PFieldTable(RDWPointerMath(lTypeInfo) + PByte(@lTypeInfo^.Name)^)^.Size);
    Else Inc(lCompare, SizeOf(Pointer));
   End;
   Inc(lIdx);
  End;
 If lCompare < AFieldTable^.Size Then
  TStream_ReadBuffer(AStream, PByte(RDWPointerMath(ADynamic) + lCompare)^, AFieldTable^.Size - lCompare);
End;

Procedure DynamicRead_DynArray(AStream        : TStream;
                               ADynamic       : Pointer;
                               ATypeInfo      : PTypeInfo;
                               Const AOptions : TRESTDWDynamicOptions);
Var
 lDyn : PDynArrayTypeInfo;
 lLen : RDWArrayLen;
Begin
 If rdwLimitToWordSize In AOptions Then
  Begin
   lLen := 0;
   TStream_ReadBuffer(AStream, lLen, SizeOf(Word));
  End
 Else
  Begin
   If rdwCPUArchCompatibility In AOptions Then
    Begin
     lLen := 0;
     TStream_ReadBuffer(AStream, lLen, SizeOf(RDWArrayLen86));
    End
   Else
    TStream_ReadBuffer(AStream, lLen, SizeOf(RDWArrayLen));
  End;
 DynArraySetLength(PPointer(ADynamic)^, ATypeInfo, 1, @lLen);
 If lLen = 0 Then
  Exit;
 lDyn := PDynArrayTypeInfo(RDWPointerMath(ATypeInfo) + PByte(@ATypeInfo^.Name)^);
 If lDyn^.elType = Nil Then
  TStream_ReadBuffer(AStream, PByte(ADynamic^)^, lLen * lDyn^.elSize)
 Else
    DynamicRead_Array(AStream,
                      PPointer(ADynamic)^,
                      PTypeInfo(lDyn^.elType^),
                      lLen, AOptions);
End;

Procedure DynamicRead_Array(AStream        : TStream;
                            ADynamic       : Pointer;
                            ATypeInfo      : PTypeInfo;
                            ALength        : RDWArrayLen;
                            Const AOptions : TRESTDWDynamicOptions);
Var
 lFieldTable : PFieldTable;
 lStrLen     : RDWStrLen;
 lUTF8       : Pointer;
Begin
 If ALength = 0 Then
  Exit;
 Case ATypeInfo^.Kind of
  {$IF Declared(AnsiString)}
  tkLString : Begin
               While ALength > 0 Do
                Begin
                 If rdwLimitToWordSize In AOptions Then
                  Begin
                   lStrLen := 0;
                   TStream_ReadBuffer(AStream, lStrLen, SizeOf(Word));
                  End
                 Else
                  TStream_ReadBuffer(AStream, lStrLen, SizeOf(RDWStrLen));
                 SetLength(PAnsiString(ADynamic)^, lStrLen);
                 If lStrLen > 0 Then
                  Begin
                   TStream_ReadBuffer(AStream, PByte(ADynamic^)^, lStrLen * SizeOf(AnsiChar));
                   If rdwAnsiStringCodePage In AOptions Then
                    Begin
                      {$IF Declared(UnicodeString)}
                      TStream_ReadBuffer(AStream, PWord(PRDWPointerMath(ADynamic)^ - 12)^, SizeOf(Word));   // StrRec.codePage
                      {$ELSE}
                      AStream.Seek(SizeOf(Word), soFromCurrent); // TODO: try to convert from one codepage to another
                      {$IFEND}
                    End;
                  End;
                 Inc(PPointer(ADynamic));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  {$IF Declared(WideString)}
  tkWString : Begin
               While ALength > 0 Do
                Begin
                 If rdwLimitToWordSize In AOptions Then
                  Begin
                   lStrLen := 0;
                   TStream_ReadBuffer(AStream, lStrLen, SizeOf(Word));
                  End
                 Else
                  TStream_ReadBuffer(AStream, lStrLen, SizeOf(RDWStrLen));
                 If lStrLen = 0 Then
                  SetLength(PWideString(ADynamic)^, 0)
                 Else
                  Begin
                   If rdwUTF16ToUTF8 In AOptions Then
                    Begin
                     GetMem(lUTF8, lStrLen);
                     If AStream.Read(lUTF8^, lStrLen) <> lStrLen Then
                      Begin
                       FreeMem(lUTF8);
                       Raise EReadError.CreateRes(@SReadError);
                      End;
                     SetLength(PWideString(ADynamic)^, Utf8ToUnicode(nil, MaxInt, lUTF8, lStrLen));
                     If Length(PWideString(ADynamic)^) = 0 Then
                      Begin
                       FreeMem(lUTF8);
                       Raise RDWDynamic.Create('Utf8ToUnicode failed!');
                      End;
                     Utf8ToUnicode(@PWideString(ADynamic)^[1], Length(PWideString(ADynamic)^) + 1, lUTF8, lStrLen);
                     FreeMem(lUTF8);
                    End
                   Else
                    Begin
                     SetLength(PWideString(ADynamic)^, lStrLen);
                     TStream_ReadBuffer(AStream, PByte(ADynamic^)^, lStrLen * SizeOf(WideChar));
                    End;
                  End;
                 Inc(PPointer(ADynamic));
                 Dec(ALength);
                End;
              End;
  {$IFEND}
  {$IF Declared(UnicodeString)}
  tkUString : Begin
               While ALength > 0 Do
                Begin
                 If rdwLimitToWordSize In AOptions Then
                  Begin
                   lStrLen := 0;
                   TStream_ReadBuffer(AStream, lStrLen, SizeOf(Word));
                  End
                 Else
                  TStream_ReadBuffer(AStream, lStrLen, SizeOf(RDWStrLen));
                 If lStrLen = 0 Then
                  SetLength(PUnicodeString(ADynamic)^, 0)
                 Else
                  Begin
                   If rdwUTF16ToUTF8 In AOptions Then
                    Begin
                     GetMem(lUTF8, lStrLen);
                     If AStream.Read(lUTF8^, lStrLen) <> lStrLen Then
                      Begin
                       FreeMem(lUTF8);
                       Raise EReadError.CreateRes(@SReadError);
                      End;
                     SetLength(PUnicodeString(ADynamic)^, Utf8ToUnicode(nil, MaxInt, lUTF8, lStrLen));
                     If Length(PUnicodeString(ADynamic)^) = 0 Then
                      Begin
                       FreeMem(lUTF8);
                       Raise RDWDynamic.Create('Utf8ToUnicode failed!');
                      End;
                     Utf8ToUnicode(@PUnicodeString(ADynamic)^[1], Length(PUnicodeString(ADynamic)^) + 1, lUTF8, lStrLen);
                     FreeMem(lUTF8);
                    End
                   Else
                    Begin
                     SetLength(PUnicodeString(ADynamic)^, lStrLen);
                     TStream_ReadBuffer(AStream, PByte(ADynamic^)^, lStrLen * SizeOf(WideChar));
                    End;
                  End;
                 Inc(PPointer(ADynamic));
                 Dec(ALength);
                end;
              End;
  {$IFEND}
  tkArray : Begin
             lFieldTable := PFieldTable(RDWPointerMath(ATypeInfo) + PByte(@PTypeInfo(ATypeInfo)^.Name)^);
             While ALength > 0 Do
              Begin
               DynamicRead_Array(AStream, ADynamic,
                                 lFieldTable^.Fields[0].TypeInfo^,
                                 lFieldTable^.Count, AOptions);
               Inc(RDWPointerMath(ADynamic), lFieldTable^.Size);
               Dec(ALength);
              End;
            End;

  tkRecord : Begin
              lFieldTable := PFieldTable(RDWPointerMath(ATypeInfo) + PByte(@PTypeInfo(ATypeInfo)^.Name)^);
              While ALength > 0 do
               Begin
                DynamicRead_Record(AStream, ADynamic, lFieldTable, AOptions);
                Inc(RDWPointerMath(ADynamic), lFieldTable^.Size);
                Dec(ALength);
               End;
             End;
  tkDynArray : Begin
                While ALength > 0 Do
                 Begin
                  DynamicRead_DynArray(AStream, ADynamic, ATypeInfo, AOptions);
                  Inc(RDWPointerMath(ADynamic), SizeOf(Pointer));
                  Dec(ALength);
                 End;
               End
  Else
   Raise RDWDynamicInvalidType.Create(ATypeInfo^.Kind);
 End;
End;

Class Function TRESTDWDynamic.Compare(Const ADynamicType1,
                                      ADynamicType2;
                                      ATypeInfo            : PTypeInfo) : Boolean;
Begin
 Result := DynamicCompare_Array(@ADynamicType1, @ADynamicType2, ATypeInfo, 1);
End;

Class Function TRESTDWDynamic.GetSize(Const ADynamicType;
                                      ATypeInfo      : PTypeInfo;
                                      Const AOptions : TRESTDWDynamicOptions) : RDWSize;
Begin
 Result := SizeOf(TRESTDWDynamicHeader) + GetSizeNH(ADynamicType, ATypeInfo, AOptions);
End;

Class Function TRESTDWDynamic.GetSizeNH(Const ADynamicType;
                                        ATypeInfo      : PTypeInfo;
                                        Const AOptions : TRESTDWDynamicOptions) : RDWSize;
Begin
 Result := DynamicGetSize_Array(@ADynamicType, ATypeInfo, 1, AOptions);
End;

Class Procedure TRESTDWDynamic.WriteTo (AStream        : TStream;
                                        Const ADynamicType;
                                        ATypeInfo      : PTypeInfo;
                                        AVersion       : Word;
                                        Const AOptions : TRESTDWDynamicOptions;
                                        APreAllocSize  : Boolean);
Var
 lHeader  : TRESTDWDynamicHeader;
 lNewSize,
 lOldPos  : Int64;
 lOptions : Byte;
Begin
 If APreAllocSize Then
  Begin
   lNewSize := AStream.Position + TRESTDWDynamic.GetSize(ADynamicType, ATypeInfo, AOptions);
   If lNewSize > AStream.Size Then
    Begin
     lOldPos          := AStream.Position;
     AStream.Size     := lNewSize;
     AStream.Position := lOldPos;
    End;
  End;
 lOptions := 0;
 {$IF Declared(UnicodeString)}
  lOptions := lOptions or cRDWDYNAMIC_STREAM_CFG_UNICODE;
 {$IFEND}
 If rdwUTF16ToUTF8 In AOptions Then
  lOptions := lOptions Or cRDWDYNAMIC_STREAM_CFG_UTF8;
 If rdwLimitToWordSize In AOptions Then
  lOptions := lOptions Or cRDWDYNAMIC_STREAM_CFG_WORDSIZE;
 If rdwAnsiStringCodePage In AOptions Then
  lOptions := lOptions Or cRDWDYNAMIC_STREAM_CFG_CODEPAGE;
 If rdwCPUArchCompatibility In AOptions Then
  lOptions := lOptions Or cRDWDYNAMIC_STREAM_CFG_CPUARCH;
 {$IFDEF CPUX64}
  If rdwCPUArchCompatibility In AOptions Then
   lHeader.Stream.Version := cRDWDYNAMIC_STREAM_VERSION_v1
  Else
   lHeader.Stream.Version := cRDWDYNAMIC_STREAM_VERSION_v2;
 {$ELSE}
  lHeader.Stream.Version := cRDWDYNAMIC_STREAM_VERSION_v1;
 {$ENDIF}
 lHeader.Stream.Options := lOptions;
 lHeader.TypeVersion := AVersion;
 TStream_WriteBuffer(AStream, lHeader, SizeOf(lHeader));
 WriteToNH(AStream, ADynamicType, ATypeInfo, AOptions);
End;

Class Procedure TRESTDWDynamic.WriteToNH(AStream            : TStream;
                                         Const ADynamicType;
                                         ATypeInfo          : PTypeInfo;
                                         Const AOptions     : TRESTDWDynamicOptions);
Begin
 DynamicWrite_Array(AStream, @ADynamicType, ATypeInfo, 1, AOptions);
End;

Class Function TRESTDWDynamic.ReadFrom  (AStream            : TStream;
                                         Const ADynamicType;
                                         ATypeInfo          : PTypeInfo;
                                         AVersion           : Word;
                                         AForceCPUArchCompatibilityOnStreamV1 : Boolean) : Boolean;
Var
 lHeader  : TRESTDWDynamicHeader;
 lOptions : TRESTDWDynamicOptions;
Begin
 lOptions := [];
 TStream_ReadBuffer(AStream, lHeader, SizeOf(lHeader));
 Result := lHeader.TypeVersion = AVersion;
 If Result Then
  Begin
   If cRDWDYNAMIC_STREAM_CFG_UTF8     And lHeader.Stream.Options = cRDWDYNAMIC_STREAM_CFG_UTF8     Then
    Include(lOptions, rdwUTF16ToUTF8);
   If cRDWDYNAMIC_STREAM_CFG_WORDSIZE And lHeader.Stream.Options = cRDWDYNAMIC_STREAM_CFG_WORDSIZE Then
    Include(lOptions, rdwLimitToWordSize);
   If cRDWDYNAMIC_STREAM_CFG_CODEPAGE And lHeader.Stream.Options = cRDWDYNAMIC_STREAM_CFG_CODEPAGE Then
    Include(lOptions, rdwAnsiStringCodePage);
   If (cRDWDYNAMIC_STREAM_CFG_CPUARCH And lHeader.Stream.Options = cRDWDYNAMIC_STREAM_CFG_CPUARCH) Or
      (AForceCPUArchCompatibilityOnStreamV1 And (lHeader.Stream.Version = cRDWDYNAMIC_STREAM_VERSION_v1)) Then
    Include(lOptions, rdwCPUArchCompatibility);
   {$IFDEF CPUX64}
    If rdwCPUArchCompatibility in lOptions Then
     Result := lHeader.Stream.Version = cRDWDYNAMIC_STREAM_VERSION_v1
    Else
     Result := lHeader.Stream.Version = cRDWDYNAMIC_STREAM_VERSION_v2;
   {$ELSE}
    Result := lHeader.Stream.Version = cRDWDYNAMIC_STREAM_VERSION_v1;
   {$ENDIF}
  End;
 If Result Then
  ReadFromNH(AStream, ADynamicType, ATypeInfo, lOptions)
 Else
  AStream.Seek(-SizeOf(lHeader), soCurrent);
End;

Class Procedure TRESTDWDynamic.ReadFromNH(AStream            : TStream;
                                          Const ADynamicType;
                                          ATypeInfo          : PTypeInfo;
                                          Const AOptions     : TRESTDWDynamicOptions);
Begin
 DynamicRead_Array(AStream, @ADynamicType, ATypeInfo, 1, AOptions);
End;

Constructor RDWDynamicInvalidType.Create(ATypeKind: TTypeKind);
Begin
 FTypeKind := ATypeKind;
 Inherited CreateFmt('Unsupported field type %s', [GetEnumName(TypeInfo(TTypeKind), Ord(ATypeKind))]);
End;

Constructor RDWDynamicLimit.Create(ALen, AMaxLen: RDWArrayLen);
Begin
 Inherited CreateFmt('Invalid dynamic array size %d (max %d)', [ALen, AMaxLen]);
End;

Constructor RDWDynamicWordLimit.Create(ALen: RDWArrayLen);
Begin
 Inherited Create(ALen, MAXWORD);
End;

End.
