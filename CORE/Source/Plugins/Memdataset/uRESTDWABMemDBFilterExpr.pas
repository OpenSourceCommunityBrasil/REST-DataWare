unit uRESTDWABMemDBFilterExpr;

{$I ..\..\Includes\uRESTDW.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do pacote.
 Alberto Brito              - Admin - Criador e Administrador do pacote.

 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface
uses
  SysUtils, Classes, Variants, DB{$IFNDEF FPC}, DBCommon, SqlTimSt, Masks {$ENDIF}, FmtBcd;
type
  TRDWABExprParser = class(TExprParser)
  private
     FDataset:TDataSet;
  public
     constructor Create(DataSet: TDataSet; const Text: string;
                        Options: TFilterOptions);
     function Evaluate:boolean;
  end;



implementation

const
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
    {$ELSE}
     ,ord(DB.ftUnknown)     // ftObject
    {$ENDIF}
    );

{ TRDWABExprParser }

constructor TRDWABExprParser.Create(DataSet: TDataSet;
  const Text: string; Options: TFilterOptions);
begin
inherited Create(DataSet,Text,Options,[poExtSyntax],'',nil,FldTypeMap);
     FDataset:=DataSet;
end;

function TRDWABExprParser.Evaluate: boolean;
  function VIsNull(AVariant:Variant):Boolean;
  begin
       Result:=VarIsNull(AVariant) or VarIsEmpty(AVariant);
  end;
var

   iLiteralStart:Word;
   format:TFormatSettings;


   function GetUnicodeString(pft:PByte) : Utf8String;
   var
      len:word;
      pWords:PWord;
      pR:Pointer;
   begin
        pWords:=PWord(pft);
        len:=pWords^ div 2;
        inc(pWords);
        SetLength(Result,len);
        pR:=pointer(@Result[1]); //Substituir Stringindex 1 pela variavel para android e ARms compiles
        Move(pWords^,pR^,len * 2);
   end;


   function ParseNode(pfdStart,pfd:PByte):variant;
   var
      b:WordBool;
      i : Integer;
      z:nativeint;
      year,mon,day,hour,min,sec,msec:word;

      iClass:NODEClass;
      iOperator:TCANOperator;
      pArg1,pArg2:PByte;
      sFunc,sArg1,sArg2:string;
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
   type
      PDouble=^Double;
      PTimeStamp=^TTimeStamp;
      PComp=^Comp;
      PWordBool=^WordBool;
      PBCD=^TBCD;
   begin

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
        case iClass of
            nodeFIELD:
               begin
                    case iOperator of
                         coFIELD2:
                           begin
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
                           end;
                         else
                             raise exception.create('Error %s'+inttostr(ord(iOperator)));
                    end;
               end;

            nodeCONST:
               begin
                    case iOperator of
                         coCONST2:
                           begin
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
                                case DataType of
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
                                       begin
                                            ts.Date:=PInteger(pArg1)^;
                                            ts.Time:=0;
                                            dt:=TimeStampToDateTime(ts);
                                            Result:=dt;
                                       end;
                                     ord(DB.ftTime):
                                       begin
                                            ts.Date:=0;
                                            ts.Time:=PInteger(pArg1)^;;
                                            dt:=TimeStampToDateTime(ts);
                                            Result:=dt;
                                       end;
                                     ord(DB.ftDateTime):
                                       begin
                                            cdt:=PDouble(pArg1)^;
                                            ts:=MSecsToTimeStamp(cdt);
                                            dt:=TimeStampToDateTime(ts);
                                            Result:=dt;
                                       end;
                                     ord(DB.ftBoolean): Result:=PWordBool(pArg1)^;

                                     ord(DB.ftTimeStamp): Result:=VarSQLTimeStampCreate(PSQLTimeStamp(pArg1)^);
                                     ord(DB.ftBCD),
                                     ord(DB.ftFmtBCD):
                                       begin
                                            bcd:=TBCD(PBCD(pArg1)^);
                                            BCDToCurr(bcd,Cur);
                                            Result:=Cur;
                                       end;

                                     $1007:                       // Midas Unicode.
                                          Result:=GetUnicodeString(PByte(pArg1));

                                     else
                                         raise exception.Create('Tipo Campo Desconhecido, '+inttostr(DataType));
                                end;
                           end;
                    end;
               end;

            nodeUNARY:
               begin
                    pArg1:=pfdStart;
                   {$IFNDEF FPC}
                    {$IFDEF DELPHI2010UP}
                     inc(pArg1,CANEXPRSIZE+PWord(@pfd[0])^);
                    {$ENDIF}
                   {$ELSE}
                    inc(pArg1,CANEXPRSIZE+PWord(@pfd[0])^);
                   {$ENDIF}
                    case iOperator of
                         coISBLANK,coNOTBLANK:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                b:=VIsNull(Arg1);
                                if iOperator=coNOTBLANK then b:=not b;
                                Result:=Variant(b);
                           end;

                         coNOT:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                if VIsNull(Arg1) then
                                   Result:=Null
                                else
                                   Result:=Variant(not Arg1);
                           end;

                         coMINUS:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                if not VIsNull(Arg1) then
                                   Result:=-Arg1
                                else
                                    Result:=Null;
                           end;

                         coUPPER:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                if not VIsNull(Arg1) then
                                   Result:=UpperCase(Arg1)
                                else
                                    Result:=Null;
                           end;

                         coLOWER:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                if not VIsNull(Arg1) then
                                   Result:=LowerCase(Arg1)
                                else
                                    Result:=Null;
                           end;
                    end;
               end;

            nodeBINARY:
               begin
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
                    case iOperator of
                         coEQ:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 = Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coNE:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 <> Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coGT:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 > Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coGE:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 >= Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coLT:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 < Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coLE:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 <= Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coOR:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 or Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coAND:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then b:=false
                                else b:=(Arg1 and Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coADD:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 + Arg2);
                                exit;
                           end;

                         coSUB:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 - Arg2);
                                exit;
                           end;

                         coMUL:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 * Arg2);
                                exit;
                           end;

                         coDIV:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 / Arg2);
                                exit;
                           end;

                         coMOD,coREM:
                           begin
                                Arg1:=ParseNode(pfdStart,pArg1);
                                Arg2:=ParseNode(pfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then Result:=Null
                                else Result:=(Arg1 mod Arg2);
                                exit;
                           end;

                         coIN:
                           begin
                                Arg1:=ParseNode(PfdStart,pArg1);
                                Arg2:=ParseNode(PfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then
                                begin
                                     Result:=false;
                                     exit;
                                end;

                                if VarIsArray(Arg2) then
                                begin
                                     b:=false;
                                     for i:=0 to VarArrayHighBound(Arg2,1) do
                                     begin
                                          if VarIsEmpty(Arg2[i]) then break;
                                          b:=(Arg1=Arg2[i]);
                                          if b then break;
                                     end;
                                end
                                else
                                    b:=(Arg1=Arg2);
                                Result:=Variant(b);
                                exit;
                           end;

                         coLike:
                           begin
                                Arg1:=ParseNode(PfdStart,pArg1);
                                Arg2:=ParseNode(PfdStart,pArg2);
                                if VIsNull(Arg1) or VIsNull(Arg2) then
                                begin
                                     Result:=false;
                                     exit;
                                end;
                                pArg1:=PByte(PChar(VarToStr(ParseNode(pfdStart,pArg1))));
                                pArg2:=PByte(PChar(VarToStr(ParseNode(pfdStart,pArg2))));
                                b:=MatchesMask(string(PChar(pArg1)),string(PChar(pArg2)));
                                Result:=Variant(b);
                                exit;
                           end;

                         else
                             raise exception.Create('Operator não suportado '+inttostr(ord(iOperator)));
                    end;
               end;

            nodeCOMPARE:
               begin
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
                    if VIsNull(Arg1) or VIsNull(Arg2) then
                    begin
                         Result:=false;
                         exit;
                    end;

                    S1:=Arg1;
                    S2:=Arg2;
                    if IgnoreCase=1 then
                    begin
                         S1:=AnsiUpperCase(S1);
                         S2:=AnsiUpperCase(S2);
                    end;
                    if PartLength>0 then
                    begin
                         S1:=Copy(S1,1,PartLength);
                         S2:=Copy(S2,1,PartLength);
                    end;

                    case iOperator of
                         coEQ:
                            begin
                                 b:=(S1 = S2);
                                 Result:=Variant(b);
                                 exit;
                            end;

                         coNE:
                            begin
                                 b:=(S1 <> S2);
                                 Result:=Variant(b);
                                 exit;
                            end;

                         coLIKE:
                            begin
                                 pArg1:=PByte(PChar(VarToStr(ParseNode(pfdStart,pArg1))));
                                 pArg2:=PByte(PChar(VarToStr(ParseNode(pfdStart,pArg2))));
                                 b:=MatchesMask(string(PChar(pArg1)),string(PChar(pArg2)));
                                 Result:=Variant(b);
                                 exit;
                            end;

                         else
                             raise exception.Create('Operator não suportado '+inttostr(ord(iOperator)));
                    end;
               end;

            nodeFUNC:
               begin
                    case iOperator of
                         coFUNC2:
                            begin
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
                                 if sFunc='UPPER' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=UpperCase(VarToStr(Arg2));
                                 end

                                 else if sFunc='LOWER' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=LowerCase(VarToStr(Arg2));
                                 end

                                 else if sFunc='SUBSTRING' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then
                                      begin
                                           Result:=Null;
                                           exit;
                                      end;

                                      Result:=Arg2;
                                      try
{$IFDEF NEXTGEN}
                                         pArg1:=PByte(VarToStr(Result[0]));
{$ELSE}
                                         pArg1:=PByte(AnsiString(VarToStr(Result[0])));
{$ENDIF}
                                      except
                                         on EVariantError do // no Params for "SubString"
                                            raise Exception.CreateFmt('Invalid or missing parameter for function %s',[pArg1]);
                                      end;

                                      i:=Result[1];
                                      z:=Result[2];
                                      if (z=0) then
                                      begin
                                           if (Pos(',',Result[1])>0) then  // "From" and "To" entered without space!
                                              z:=StrToInt(Copy(Result[1],Pos(',',Result[1])+1,Length(Result[1])))
                                           else                            // No "To" entered so use all
                                              z:=Length(PChar(pArg1));
                                      end;
                                      Result:=Copy(PChar(pArg1),i,z);
                                 end

                                 else if sFunc='TRIM' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=Trim(VarToStr(Arg2));
                                 end

                                 else if sFunc='TRIMLEFT' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=TrimLeft(VarToStr(Arg2));
                                 end

                                 else if sFunc='TRIMRIGHT' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else Result:=TrimRight(VarToStr(Arg2));
                                 end

                                 else if sFunc='GETDATE' then
                                    Result:=Now

                                 else if sFunc='YEAR' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeDate(VarToDateTime(Arg2),year,mon,day);
                                           Result:=year;
                                      end;
                                 end


                                 else if sFunc='MONTH' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeDate(VarToDateTime(Arg2),year,mon,day);
                                           Result:=mon;
                                      end;
                                 end

                                 else if sFunc='DAY' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeDate(VarToDateTime(Arg2),year,mon,day);
                                           Result:=day;
                                      end;
                                 end

                                 else if sFunc='HOUR' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeTime(VarToDateTime(Arg2),hour,min,sec,msec);
                                           Result:=hour;
                                      end;
                                 end

                                 else if sFunc='MINUTE' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeTime(VarToDateTime(Arg2),hour,min,sec,msec);
                                           Result:=min;
                                      end;
                                 end

                                 else if sFunc='SECOND' then
                                 begin
                                      Arg2:=ParseNode(pfdStart,pArg2);
                                      if VIsNull(Arg2) then Result:=Null
                                      else
                                      begin
                                           DecodeTime(VarToDateTime(Arg2),hour,min,sec,msec);
                                           Result:=sec;
                                      end;
                                 end

                                 else if sFunc='DATE' then  // Format DATE('datestring','formatstring')
                                 begin                      // or     DATE(datevalue)
                                      Result:=ParseNode(pfdStart,pArg2);
                                      if VarIsArray(Result) then
                                      begin
                                           try
                                              sArg1:=VarToStr(Result[0]);
                                              sArg2:=VarToStr(Result[1]);
                                           except
                                              on EVariantError do // no Params for DATE
                                                 raise Exception.CreateFmt('Invalid or missing parameter for function %s',[sArg1]);
                                           end;

                                           format.ShortDateFormat:=sArg2;
                                           Result:=StrToDate(sArg1,format);
                                      end
                                      else
                                          Result:=longint(trunc(VarToDateTime(Result)));
                                 end

                                 else if sFunc='TIME' then  // Format TIME('timestring','formatstring')
                                 begin                      // or     TIME(datetimevalue)
                                      Result:=ParseNode(pfdStart,pArg2);
                                      if VarIsArray(Result) then
                                      begin
                                           try
                                              sArg1:=VarToStr(Result[0]);
                                              sArg2:=VarToStr(Result[1]);
                                           except
                                              on EVariantError do // no Params for TIME
                                                 raise exception.CreateFmt('Invalid or missing parameter for function %s',[sArg1]);
                                           end;

                                           format.ShortTimeFormat:=sArg2;
                                           Result:=StrToTime(sArg1,format);
                                      end
                                      else
                                          Result:=Frac(VarToDateTime(Result));
                                 end

                                 else
                                    raise Exception.CreateFmt('Invalid function name %s',[pArg1]);
                            end;
                         else
                            raise Exception.CreateFmt('Operador não suportado (%d).',[ord(iOperator)]);
                    end;
               end;

            nodeLISTELEM:
               begin
                    case iOperator of
                         coLISTELEM2:
                            begin
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
                                 if i<2 then
                                 begin
                                      if VIsNull(Result[0]) then
                                         Result:=Null
                                      else
                                          Result:=VarAsType(Result[0],varString);
                                 end;
                            end;
                         else
                            raise exception.CreateFmt('Operador não suportado (%d).',[ord(iOperator)]);
                    end;
               end;
        else
            raise exception.CreateFmt('Class '+'Fora de intervalo (%d)',[ord(iClass)]);
        end;
   end;
  {$WARNINGS ON}

var
   pfdStart,pfd:PByte;
begin
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
end;

end.
