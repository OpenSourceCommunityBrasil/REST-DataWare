Unit uRESTDWABMemDBFilterExpr;

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

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do pacote.
 Alberto Brito              - Admin - Criador e Administrador do pacote.

 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

Interface
Uses
  SysUtils, Classes, Variants, DB{$IFNDEF FPC}, DBCommon, SqlTimSt, Masks {$ENDIF}, FmtBcd;
Type
  TRDWABExprParser = Class(TExprParser)
  Private
     FDataset:TDataSet;
  Public
     Constructor Create(DataSet: TDataSet; Const Text: string;
                        Options: TFilterOptions);
     Function Evaluate:boolean;
  End;



Implementation

Const
  // Field mappings needed for filtering. (What field type should be compared with what internal type).
  FldTypeMap: TFieldMap = (
     ord(DB.ftUnknown)     // ftUnknown
    ,ord(DB.ftString)      // ftString
    ,ord(DB.ftSmallInt)    // ftSmallInt
    ,ord(DB.ftInteger)     // ftInteger
    ,ord(DB.ftWord)        // ftWord
    ,ord(DB.ftBoolean)     // ftBoolean
    ,ord(DB.ftFloat)       // ftFloat
    ,ord(DB.ftFloat)       // ftCurrency
    ,ord(DB.ftBCD)         // ftBCD
    ,ord(DB.ftDate)        // ftDate
    ,ord(DB.ftTime)        // ftTime
    ,ord(DB.ftDateTime)    // ftDateTime
    ,ord(DB.ftBytes)       // ftBytes
    ,ord(DB.ftVarBytes)    // ftVarBytes
    ,ord(DB.ftInteger)     // ftAutoInc
    ,ord(DB.ftBlob)        // fBlob
    ,ord(DB.ftBlob)        // ftMemo
    ,ord(DB.ftBlob)        // ftGraphic
    ,ord(DB.ftBlob)        // ftFmtMemo
    ,ord(DB.ftBlob)        // ftParadoxOle
    ,ord(DB.ftBlob)        // ftDBaseOle
    ,ord(DB.ftBlob)        // ftTypedBinary
    ,ord(DB.ftUnknown)     // ftCursor
    ,ord(DB.ftString)      // ftFixedChar
    ,ord(DB.ftWideString)  // ftWideString
    ,ord(DB.ftLargeInt)    // ftLargeInt
    ,ord(DB.ftADT)         // ftADT
    ,ord(DB.ftArray)       // ftArray
    ,ord(DB.ftUnknown)     // ftReference
    ,ord(DB.ftUnknown)     // ftDataset
    ,ord(DB.ftBlob)        // ftOraBlob
    ,ord(DB.ftBlob)        // ftOraClob
    ,ord(DB.ftUnknown)     // ftVariant
    ,ord(DB.ftUnknown)     // ftInterface
    ,ord(DB.ftUnknown)     // ftIDispatch
    ,ord(DB.ftGUID)        // ftGUID
    ,ord(DB.ftTimeStamp)   // ftTimeStamp
    ,ord(DB.ftFmtBCD)      // ftFmtBCD
    {$IFNDEF FPC}
     {$IFDEF DELPHI2010UP}
      ,ord(DB.ftWideString)  // ftFixedWideChar
      ,ord(DB.ftWideString)  // ftWideMemo
      ,ord(DB.ftTimeStamp)   // ftOraTimeStamp
      ,ord(DB.ftString)      // ftOraInterval)
      ,ord(DB.ftLongWord)
      ,ord(DB.ftShortint)
      ,ord(DB.ftByte)
      ,ord(DB.ftExtended)
     {$ENDIF}
    {$ELSE}
     ,ord(DB.ftWideString)  // ftFixedWideChar
     ,ord(DB.ftWideString)  // ftWideMemo
     ,ord(DB.ftTimeStamp)   // ftOraTimeStamp
     ,ord(DB.ftString)      // ftOraInterval)
     ,ord(DB.ftLongWord)
     ,ord(DB.ftShortint)
     ,ord(DB.ftByte)
     ,ord(DB.ftExtended)
    {$ENDIF}
    {$IFNDEF FPC}
     {$IFDEF DELPHI2010UP}
      ,ord(DB.ftUnknown)     // ftConnection
      ,ord(DB.ftUnknown)     // ftParams
      ,ord(DB.ftUnknown)     // ftStream
      ,ord(DB.ftUnknown)     // ftTimeStampOffset
      ,ord(DB.ftUnknown)     // ftObject
     {$ENDIF}
    {$ELSE}
     ,ord(DB.ftUnknown)     // ftConnection
     ,ord(DB.ftUnknown)     // ftParams
     ,ord(DB.ftUnknown)     // ftStream
     ,ord(DB.ftUnknown)     // ftTimeStampOffset
     ,ord(DB.ftUnknown)     // ftObject
    {$ENDIF}
    {$IFNDEF FPC}
     {$IFDEF DELPHI2010UP}
      ,ord(DB.ftSingle)      // ftSingle
     {$ENDIF}
     {$IFDEF DELPHI2025UP}
      ,ord(DB.ftLargeint)      // ftSingle
     {$ENDIF}
    {$ELSE}
     ,ord(DB.ftUnknown)     // ftObject
    {$ENDIF}
    );

{ TRDWABExprParser }

Constructor TRDWABExprParser.Create(DataSet: TDataSet;
  Const Text: string; Options: TFilterOptions);
Begin
Inherited Create(DataSet,Text,Options,[poExtSyntax],'',nil,FldTypeMap);
     FDataset:=DataSet;
End;

Function TRDWABExprParser.Evaluate: boolean;
  Function VIsNull(AVariant:Variant):Boolean;
  Begin
       Result:=VarIsNull(AVariant) or VarIsEmpty(AVariant);
  End;
Var

   iLiteralStart:Word;
   format:TFormatSettings;


   Function GetUnicodeString(pft:PByte) : Utf8String;
   Var
      len:word;
      pWords:PWord;
      pR:Pointer;
   Begin
        pWords:=PWord(pft);
        len:=pWords^ div 2;
        inc(pWords);
        SetLength(Result,len);
        pR:=pointer(@Result[1]); //Substituir Stringindex 1 pela variavel para android e ARms compiles
        Move(pWords^,pR^,len * 2);
   End;


   Function ParseNode(pfdStart,pfd:PByte):variant;
   Var
      b:WordBool;
      i : Integer;
      z:nativeint;
      year,mon,day,hour,min,sec,msec:word;

      iClass:NODEClass;
      iOperator:TCANOperator;
      pArg1,pArg2:PByte;
      sFunc,
      sArg1,
      sArg2,
      sLike :string;
      Arg1,Arg2:variant;

      //     FieldNo:integer;
      FieldName:String;
      DataType:word;
      DataOfs:integer;
//      DataSize:integer;

      ts:TTimeStamp;
      dt:TDateTime;
      cdt:Comp;
      bcd:TBCD;
      cur:Currency;

      PartLength:word;
      IgnoreCase:word;
      S1,S2:string;
   Type
      PDouble=^Double;
      PTimeStamp=^TTimeStamp;
      PComp=^Comp;
      PWordBool=^WordBool;
      PBCD=^TBCD;
   Begin

        // Get node class.
     {$IFNDEF FPC}
      {$IFDEF DELPHI2010UP}
       iClass    := NODEClass(PInteger(@pfd[0])^);
       iOperator := TCANOperator(PInteger(@pfd[4])^);
      {$ENDIF}
     {$ELSE}
      iClass    := NODEClass(PInteger(@pfd[0])^);
      iOperator := TCANOperator(PInteger(@pfd[4])^);
     {$ENDIF}

        inc(pfd,CANHDRSIZE);

        //ShowMessage(Format('Class=%d, Operator=%d',[ord(iClass),ord(iOperator)]));

        // Check class.
        Case iClass Of
            nodeFIELD:
               Begin
                    Case iOperator Of
                         coFIELD2:
                           Begin
//                                FieldNo:=PWord(@pfd[0])^ - 1;
                               {$IFNDEF FPC}
                                {$IFDEF DELPHI2010UP}
                                 DataOfs:=iLiteralStart+PWord(@pfd[2])^;
                                {$ENDIF}
                               {$ELSE}
                                DataOfs:=iLiteralStart+PWord(@pfd[2])^;
                               {$ENDIF}

                                pArg1:=pfdStart;
                                inc(pArg1,DataOfs);
{$IFDEF NEXTGEN}
                                FieldName:=TMarshal.ReadStringAsUtf8(TPtrWrapper.Create(pArg1));
{$ELSE}
                                FieldName:=string(PAnsiChar(pArg1));
{$ENDIF}
                                Result:=FDataset.FieldByName(FieldName).Value;
                           End;
                         Else
                             raise exception.create('Error %s'+inttostr(ord(iOperator)));
                    End;
               End;

            nodeCONST:
               Begin
                    Case iOperator Of
                         coCONST2:
                           Begin
                               {$IFNDEF FPC}
                                {$IFDEF DELPHI2010UP}
                                 DataType:=PWord(@pfd[0])^;
                                 DataOfs:=iLiteralStart+PWord(@pfd[4])^;
                                {$ENDIF}
                               {$ELSE}
                                DataType:=PWord(@pfd[0])^;
                                DataOfs:=iLiteralStart+PWord(@pfd[4])^;
                               {$ENDIF}
                                pArg1:=pfdStart;
                                inc(pArg1,DataOfs);

                                // Check type.
                                Case DataType Of
                                     ord(DB.ftSmallInt): Result:=PSmallInt(pArg1)^;
                                     ord(DB.ftWord): Result:=PWord(pArg1)^;
                                     {$IFNDEF FPC}
                                      {$IFDEF DELPHI2010UP}
                                       ord(DB.ftShortint): Result:=PShortInt(pArg1)^;
                                       ord(DB.ftByte): Result:=PByte(pArg1)^;
                                       ord(DB.ftSingle) : Result:=PDouble(pArg1)^;
                                       ord(DB.ftFixedWideChar),
                                       ord(DB.ftWideString): {$IFDEF NEXTGEN}
                                                              Result:=PString(pArg1)^;
                                                             {$ELSE}
                                                              Result:=PWideString(pArg1)^;
                                                             {$ENDIF}
                                      ord(DB.ftOraInterval):{$IFDEF NEXTGEN}
                                                              Result:=PString(pArg1)^;
                                                            {$ELSE}
                                                             Result:=String(AnsiString(PAnsiChar(pArg1)));
                                                            {$ENDIF}
                                      ord(DB.ftOraTimeStamp): Result:=VarSQLTimeStampCreate(PSQLTimeStamp(pArg1)^);
                                      ord(DB.ftLongWord): Result:=PLongWord(pArg1)^;
                                      ord(DB.ftExtended): Result:=PExtended(pArg1)^;
                                     {$ENDIF}
                                     {$ELSE}
                                      ord(DB.ftShortint): Result:=PShortInt(pArg1)^;
                                      ord(DB.ftByte): Result:=PByte(pArg1)^;
                                      ord(DB.ftSingle) : Result:=PDouble(pArg1)^;
                                      ord(DB.ftFixedWideChar),
                                      ord(DB.ftWideString): {$IFDEF NEXTGEN}
                                                             Result:=PString(pArg1)^;
                                                            {$ELSE}
                                                             Result:=PWideString(pArg1)^;
                                                            {$ENDIF}
                                      ord(DB.ftOraInterval):{$IFDEF NEXTGEN}
                                                              Result:=PString(pArg1)^;
                                                            {$ELSE}
                                                             Result:=String(AnsiString(PAnsiChar(pArg1)));
                                                            {$ENDIF}
                                      ord(DB.ftOraTimeStamp): Result:=VarSQLTimeStampCreate(PSQLTimeStamp(pArg1)^);
                                      ord(DB.ftLongWord): Result:=PLongWord(pArg1)^;
                                      ord(DB.ftExtended): Result:=PExtended(pArg1)^;
                                     {$ENDIF}

                                     ord(DB.ftInteger),
                                     ord(DB.ftAutoInc):  Result:=PInteger(pArg1)^;

                                     ord(DB.ftLargeInt): Result:=PInt64(pArg1)^;


                                     ord(DB.ftFloat), ord(ftCurrency): Result:=PDouble(pArg1)^;

                                     ord(DB.ftGUID):
{$IFDEF NEXTGEN}
                                        Result:=PString(pArg1)^;
{$ELSE}
                                        Result:=PWideString(pArg1)^;
{$ENDIF}


                                     ord(DB.ftString),
                                     ord(DB.ftFixedChar):
{$IFDEF NEXTGEN}
                                        Result:=PString(pArg1)^;
{$ELSE}
                                        Result:=String(AnsiString(PAnsiChar(pArg1)));
{$ENDIF}
                                     ord(DB.ftDate):
                                       Begin
                                            ts.Date:=PInteger(pArg1)^;
                                            ts.Time:=0;
                                            dt:=TimeStampToDateTime(ts);
                                            Result:=dt;
                                       End;
                                     ord(DB.ftTime):
                                       Begin
                                            ts.Date:=0;
                                            ts.Time:=PInteger(pArg1)^;;
                                            dt:=TimeStampToDateTime(ts);
                                            Result:=dt;
                                       End;
                                     ord(DB.ftDateTime):
                                       Begin
                                            cdt:=PDouble(pArg1)^;
                                            ts:=MSecsToTimeStamp(cdt);
                                            dt:=TimeStampToDateTime(ts);
                                            Result:=dt;
                                       End;
                                     ord(DB.ftBoolean): Result:=PWordBool(pArg1)^;

                                     ord(DB.ftTimeStamp): Result:=VarSQLTimeStampCreate(PSQLTimeStamp(pArg1)^);
                                     ord(DB.ftBCD),
                                     ord(DB.ftFmtBCD):
                                       Begin
                                            bcd:=TBCD(PBCD(pArg1)^);
                                            BCDToCurr(bcd,Cur);
                                            Result:=Cur;
                                       End;

                                     $1007:                       // Midas Unicode.
                                          Result:=GetUnicodeString(PByte(pArg1));

                                     Else
                                         raise exception.Create('Tipo Campo Desconhecido, '+inttostr(DataType));
                                End;
                           End;
                    End;
               End;

            nodeUNARY:
               Begin
                    pArg1:=pfdStart;
                   {$IFNDEF FPC}
                    {$IFDEF DELPHI2010UP}
                     inc(pArg1,CANEXPRSIZE+PWord(@pfd[0])^);
                    {$ENDIF}
                   {$ELSE}
                    inc(pArg1,CANEXPRSIZE+PWord(@pfd[0])^);
                   {$ENDIF}
                    Case iOperator Of
                         coISBLANK,coNOTBLANK:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                b:=VIsNull(Arg1);
                                If iOperator=coNOTBLANK Then b:=not b;
                                Result:=Variant(b);
                           End;

                         coNOT:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                If VIsNull(Arg1) Then
                                   Result:=Null
                                Else
                                   Result:=Variant(not Arg1);
                           End;

                         coMINUS:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                If not VIsNull(Arg1) Then
                                   Result:=-Arg1
                                Else
                                    Result:=Null;
                           End;

                         coUPPER:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                If not VIsNull(Arg1) Then
                                   Result:=UpperCase(Arg1)
                                Else
                                    Result:=Null;
                           End;

                         coLOWER:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                If not VIsNull(Arg1) Then
                                   Result:=LowerCase(Arg1)
                                Else
                                    Result:=Null;
                           End;
                    End;
               End;

            nodeBINARY:
               Begin
                    // Get Loper and Roper pointers to buffer.
                    pArg1:=pfdStart;
                   {$IFNDEF FPC}
                    {$IFDEF DELPHI2010UP}
                     inc(pArg1,CANEXPRSIZE+PWord(@pfd[0])^);
                     pArg2:=pfdStart;
                     inc(pArg2,CANEXPRSIZE+PWord(@pfd[2])^);
                    {$ENDIF}
                   {$ELSE}
                    inc(pArg1,CANEXPRSIZE+PWord(@pfd[0])^);
                    pArg2:=pfdStart;
                    inc(pArg2,CANEXPRSIZE+PWord(@pfd[2])^);
                   {$ENDIF}
                    // Check operator for what to do.
                    Case iOperator Of
                         coEQ:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then b:=false
                                Else b:=(Arg1 = Arg2);
                                Result:=Variant(b);
                                exit;
                           End;

                         coNE:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then b:=false
                                Else b:=(Arg1 <> Arg2);
                                Result:=Variant(b);
                                exit;
                           End;

                         coGT:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then b:=false
                                Else b:=(Arg1 > Arg2);
                                Result:=Variant(b);
                                exit;
                           End;

                         coGE:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then b:=false
                                Else b:=(Arg1 >= Arg2);
                                Result:=Variant(b);
                                exit;
                           End;

                         coLT:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then b:=false
                                Else b:=(Arg1 < Arg2);
                                Result:=Variant(b);
                                exit;
                           End;

                         coLE:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then b:=false
                                Else b:=(Arg1 <= Arg2);
                                Result:=Variant(b);
                                exit;
                           End;

                         coOR:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then b:=false
                                Else b:=(Arg1 or Arg2);
                                Result:=Variant(b);
                                exit;
                           End;

                         coAND:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then b:=false
                                Else b:=(Arg1 and Arg2);
                                Result:=Variant(b);
                                exit;
                           End;

                         coADD:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then Result:=Null
                                Else Result:=(Arg1 + Arg2);
                                exit;
                           End;

                         coSUB:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then Result:=Null
                                Else Result:=(Arg1 - Arg2);
                                exit;
                           End;

                         coMUL:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then Result:=Null
                                Else Result:=(Arg1 * Arg2);
                                exit;
                           End;

                         coDIV:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then Result:=Null
                                Else Result:=(Arg1 / Arg2);
                                exit;
                           End;

                         coMOD,coREM:
                           Begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then Result:=Null
                                Else Result:=(Arg1 mod Arg2);
                                exit;
                           End;

                         coIN:
                           Begin
                                Arg1:=ParseNode(PfdStart,pArg1);
                                Arg2:=ParseNode(PfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then
                                Begin
                                     Result:=false;
                                     exit;
                                End;

                                If VarIsArray(Arg2) Then
                                Begin
                                     b:=false;
                                     For i:=0 To VarArrayHighBound(Arg2,1) Do
                                     Begin
                                          If VarIsEmpty(Arg2[i]) Then break;
                                          b:=(Arg1=Arg2[i]);
                                          If b Then break;
                                     End;
                                End
                                Else
                                    b:=(Arg1=Arg2);
                                Result:=Variant(b);
                                exit;
                           End;

                         coLike:
                           Begin
                                Arg1:=ParseNode(PfdStart,pArg1);
                                Arg2:=ParseNode(PfdStart,pArg2);
                                If VIsNull(Arg1) or VIsNull(Arg2) Then
                                Begin
                                     Result:=false;
                                     exit;
                                End;
                                pArg1:=PByte(PChar(VarToStr(ParseNode(pfdStart,pArg1))));
                                pArg2:=PByte(PChar(VarToStr(ParseNode(pfdStart,pArg2))));
                                sLike := StringReplace(string(PChar(pArg2)), '%', '*', [rfReplaceAll]);
                                b:=MatchesMask(string(PChar(pArg1)), sLike);
                                Result:=Variant(b);
                                exit;
                           End;

                         Else
                             raise exception.Create('Operator no suportado '+inttostr(ord(iOperator)));
                    End;
               End;

            nodeCOMPARE:
               Begin
                   {$IFNDEF FPC}
                    {$IFDEF DELPHI2010UP}
                     IgnoreCase:=PWord(@pfd[0])^;
                     PartLength:=PWord(@pfd[2])^;
                     pArg1:=pfdStart+CANEXPRSIZE+PWord(@pfd[4])^;
                     pArg2:=pfdStart+CANEXPRSIZE+PWord(@pfd[6])^;
                    {$ENDIF}
                   {$ELSE}
                    IgnoreCase:=PWord(@pfd[0])^;
                    PartLength:=PWord(@pfd[2])^;
                    pArg1:=pfdStart+CANEXPRSIZE+PWord(@pfd[4])^;
                    pArg2:=pfdStart+CANEXPRSIZE+PWord(@pfd[6])^;
                   {$ENDIF}
                    Arg1:=ParseNode(pfdStart,pArg1);
                    Arg2:=ParseNode(pfdStart,pArg2);
                    If VIsNull(Arg1) or VIsNull(Arg2) Then
                    Begin
                         Result:=false;
                         exit;
                    End;

                    S1:=Arg1;
                    S2:=Arg2;
                    If IgnoreCase=1 Then
                    Begin
                         S1:=AnsiUpperCase(S1);
                         S2:=AnsiUpperCase(S2);
                    End;
                    If PartLength>0 Then
                    Begin
                         S1:=Copy(S1,1,PartLength);
                         S2:=Copy(S2,1,PartLength);
                    End;

                    Case iOperator Of
                         coEQ:
                            Begin
                                 b:=(S1 = S2);
                                 Result:=Variant(b);
                                 exit;
                            End;

                         coNE:
                            Begin
                                 b:=(S1 <> S2);
                                 Result:=Variant(b);
                                 exit;
                            End;

                         coLIKE:
                            Begin
                                 pArg1:=PByte(PChar(VarToStr(ParseNode(pfdStart,pArg1))));
                                 pArg2:=PByte(PChar(VarToStr(ParseNode(pfdStart,pArg2))));
                                 b:=MatchesMask(string(PChar(pArg1)),string(PChar(pArg2)));
                                 Result:=Variant(b);
                                 exit;
                            End;

                         Else
                             raise exception.Create('Operator no suportado '+inttostr(ord(iOperator)));
                    End;
               End;

            nodeFUNC:
               Begin
                    Case iOperator Of
                         coFUNC2:
                            Begin
                                 pArg1:=pfdStart;
                                 {$IFNDEF FPC}
                                  {$IFDEF DELPHI2010UP}
                                   inc(pArg1,iLiteralStart+PWord(@pfd[0])^);
                                  {$ENDIF}
                                 {$ELSE}
                                  inc(pArg1,iLiteralStart+PWord(@pfd[0])^);
                                 {$ENDIF}
                                 {$IFDEF NEXTGEN}
                                  sFunc:=UpperCase(string(pArg1));  // Function name
                                 {$ELSE}
                                  sFunc:=AnsiUpperCase(string(PAnsiChar(pArg1)));  // Function name
                                 {$ENDIF}
                                 pArg2:=pfdStart;
                                 {$IFNDEF FPC}
                                  {$IFDEF DELPHI2010UP}
                                   inc(pArg2,CANEXPRSIZE+PWord(@pfd[2])^); // Pointer to Value or Const
                                  {$ENDIF}
                                 {$ELSE}
                                  inc(pArg2,CANEXPRSIZE+PWord(@pfd[2])^); // Pointer to Value or Const
                                 {$ENDIF}
                                 If sFunc='UPPER' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else Result:=UpperCase(VarToStr(Arg2));
                                 End

                                 Else If sFunc='LOWER' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else Result:=LowerCase(VarToStr(Arg2));
                                 End

                                 Else If sFunc='SUBSTRING' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then
                                      Begin
                                           Result:=Null;
                                           exit;
                                      End;

                                      Result:=Arg2;
                                      Try
{$IFDEF NEXTGEN}
                                         pArg1:=PByte(VarToStr(Result[0]));
{$ELSE}
                                         pArg1:=PByte(AnsiString(VarToStr(Result[0])));
{$ENDIF}
                                      Except
                                         on EVariantError Do // no Params for "SubString"
                                            raise Exception.CreateFmt('Invalid or missing parameter for function %s',[pArg1]);
                                      End;

                                      i:=Result[1];
                                      z:=Result[2];
                                      If (z=0) Then
                                      Begin
                                           If (Pos(',',Result[1])>0) Then  // "From" and "To" entered without space!
                                              z:=StrToInt(Copy(Result[1],Pos(',',Result[1])+1,Length(Result[1])))
                                           Else                            // No "To" entered so use all
                                              z:=Length(PChar(pArg1));
                                      End;
                                      Result:=Copy(PChar(pArg1),i,z);
                                 End

                                 Else If sFunc='TRIM' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else Result:=Trim(VarToStr(Arg2));
                                 End

                                 Else If sFunc='TRIMLEFT' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else Result:=TrimLeft(VarToStr(Arg2));
                                 End

                                 Else If sFunc='TRIMRIGHT' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else Result:=TrimRight(VarToStr(Arg2));
                                 End

                                 Else If sFunc='GETDATE' Then
                                    Result:=Now

                                 Else If sFunc='YEAR' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else
                                      Begin
                                           DecodeDate(VarToDateTime(Arg2),year,mon,day);
                                           Result:=year;
                                      End;
                                 End


                                 Else If sFunc='MONTH' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else
                                      Begin
                                           DecodeDate(VarToDateTime(Arg2),year,mon,day);
                                           Result:=mon;
                                      End;
                                 End

                                 Else If sFunc='DAY' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else
                                      Begin
                                           DecodeDate(VarToDateTime(Arg2),year,mon,day);
                                           Result:=day;
                                      End;
                                 End

                                 Else If sFunc='HOUR' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else
                                      Begin
                                           DecodeTime(VarToDateTime(Arg2),hour,min,sec,msec);
                                           Result:=hour;
                                      End;
                                 End

                                 Else If sFunc='MINUTE' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else
                                      Begin
                                           DecodeTime(VarToDateTime(Arg2),hour,min,sec,msec);
                                           Result:=min;
                                      End;
                                 End

                                 Else If sFunc='SECOND' Then
                                 Begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      If VIsNull(Arg2) Then Result:=Null
                                      Else
                                      Begin
                                           DecodeTime(VarToDateTime(Arg2),hour,min,sec,msec);
                                           Result:=sec;
                                      End;
                                 End

                                 Else If sFunc='DATE' Then  // Format DATE('datestring','formatstring')
                                 Begin                      // or     DATE(datevalue)
                                      Result:=ParseNode(pfdStart,pArg2);
                                      If VarIsArray(Result) Then
                                      Begin
                                           Try
                                              sArg1:=VarToStr(Result[0]);
                                              sArg2:=VarToStr(Result[1]);
                                           Except
                                              on EVariantError Do // no Params for DATE
                                                 raise Exception.CreateFmt('Invalid or missing parameter for function %s',[sArg1]);
                                           End;

                                           format.ShortDateFormat:=sArg2;
                                           Result:=StrToDate(sArg1,format);
                                      End
                                      Else
                                          Result:=longint(trunc(VarToDateTime(Result)));
                                 End

                                 Else If sFunc='TIME' Then  // Format TIME('timestring','formatstring')
                                 Begin                      // or     TIME(datetimevalue)
                                      Result:=ParseNode(pfdStart,pArg2);
                                      If VarIsArray(Result) Then
                                      Begin
                                           Try
                                              sArg1:=VarToStr(Result[0]);
                                              sArg2:=VarToStr(Result[1]);
                                           Except
                                              on EVariantError Do // no Params for TIME
                                                 raise exception.CreateFmt('Invalid or missing parameter for function %s',[sArg1]);
                                           End;

                                           format.ShortTimeFormat:=sArg2;
                                           Result:=StrToTime(sArg1,format);
                                      End
                                      Else
                                          Result:=Frac(VarToDateTime(Result));
                                 End

                                 Else
                                    raise Exception.CreateFmt('Invalid function name %s',[pArg1]);
                            End;
                         Else
                            raise Exception.CreateFmt('Operador no suportado (%d).',[ord(iOperator)]);
                    End;
               End;

            nodeLISTELEM:
               Begin
                    Case iOperator Of
                         coLISTELEM2:
                            Begin
                                 Result:=VarArrayCreate([0,50],VarVariant); // Create VarArray for ListElements Values
                                 i:=0;
                                 pArg1:=pfdStart;
                                 {$IFNDEF FPC}
                                  {$IFDEF DELPHI2010UP}
                                   inc(pArg1,CANEXPRSIZE+PWord(@pfd[i*2])^);
                                  {$ENDIF}
                                 {$ELSE}
                                  inc(pArg1,CANEXPRSIZE+PWord(@pfd[i*2])^);
                                 {$ENDIF}
                                 {$IFNDEF FPC}
                                  {$IFDEF DELPHI2010UP}
                                   Repeat
                                    Arg1:=ParseNode(PfdStart,parg1);
                                    If VarIsArray(Arg1) Then
                                     Begin
                                      z := 0;
                                      While Not VarIsEmpty(Arg1[z]) Do
                                       Begin
                                        Result[i+z]:=Arg1[z];
                                        inc(z);
                                       End;
                                     End
                                    Else
                                     Result[i]:=Arg1;
                                    inc(i);
                                    pArg1:=pfdStart;
                                    inc(pArg1,CANEXPRSIZE+PWord(@pfd[i*2])^);
                                   Until NODEClass(PInteger(@pArg1[0])^)<>NodeListElem;
                                  {$ENDIF}
                                 {$ELSE}
                                  Repeat
                                   Arg1:=ParseNode(PfdStart,parg1);
                                   If VarIsArray(Arg1) Then
                                    Begin
                                     z := 0;
                                     While Not VarIsEmpty(Arg1[z]) Do
                                      Begin
                                       Result[i+z]:=Arg1[z];
                                       inc(z);
                                      End;
                                    End
                                   Else
                                    Result[i]:=Arg1;
                                   inc(i);
                                   pArg1:=pfdStart;
                                   inc(pArg1,CANEXPRSIZE+PWord(@pfd[i*2])^);
                                  Until NODEClass(PInteger(@pArg1[0])^)<>NodeListElem;
                                 {$ENDIF}
                                 // Only one or no Value so don't return as VarArray
                                 If i<2 Then
                                 Begin
                                      If VIsNull(Result[0]) Then
                                         Result:=Null
                                      Else
                                          Result:=VarAsType(Result[0],varString);
                                 End;
                            End;
                         Else
                            raise exception.CreateFmt('Operador no suportado (%d).',[ord(iOperator)]);
                    End;
               End;
        Else
            raise exception.CreateFmt('Class '+'Fora de intervalo (%d)',[ord(iClass)]);
        End;
   End;
  {$WARNINGS ON}

Var
   pfdStart,pfd:PByte;
Begin
 pfdStart:=@FilterData[0];
 pfd:=pfdStart;
 {$IFNDEF FPC}
  {$IFDEF DELPHI2010UP}
   iLiteralStart:=PWord(@pfd[8])^;
   inc(pfd,10);
   format := FormatSettings;
   Result := WordBool(ParseNode(pfdStart,pfd));
  {$ENDIF}
 {$ELSE}
  iLiteralStart:=PWord(@pfd[8])^;
  inc(pfd,10);
  format :=FormatSettings;
  Result :=WordBool(ParseNode(pfdStart,pfd));
 {$ENDIF}
End;

End.
