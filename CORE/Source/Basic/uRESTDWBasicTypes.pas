unit uRESTDWBasicTypes;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

interface

Uses
 FMTBcd,
 {$IFDEF FPC}
  SysUtils,  Classes, Db, uRESTDWAbout, DbTables
 {$ELSE}
  {$if CompilerVersion > 24} // Delphi 2010 pra cima
   System.SysUtils, System.Classes, Db, uRESTDWAbout
  {$ELSE}
   SysUtils, Classes, Db, DbTables, uRESTDWAbout
  {$IFEND}
 {$ENDIF}
 {$IFDEF FPC}
  {$IFDEF RESTDWLAZDRIVER}
   , memds
  {$ENDIF}
  {$IFDEF RESTDWUNIDACMEM}
  , DADump, UniDump, VirtualTable, MemDS
  {$ENDIF};
 {$ELSE}
   {$IFDEF RESTDWCLIENTDATASET}
    ,  DBClient
   {$ENDIF}
   {$IFDEF RESTDWUNIDACMEM}
   , DADump, UniDump, VirtualTable, MemDS
   {$ENDIF}
   {$IFDEF RESTKBMMEMTABLE}
    , kbmmemtable
   {$ENDIF}
   {$IF CompilerVersion > 22} // Delphi 2010 pra cima
    {$IFDEF RESTDWFDMEMTABLE}
     , FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
     FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
     FireDAC.Comp.DataSet, FireDAC.Comp.Client
     {$IFNDEF FPC}
      {$IF CompilerVersion > 26} // Delphi XE6 pra cima
       , FireDAC.Stan.StorageBin
      {$IFEND}
     {$ENDIF}
    {$ENDIF}
    {$IFDEF RESTDWADMEMTABLE}
     , uADStanIntf, uADStanOption, uADStanParam,
     uADStanError, uADPhysIntf, uADDAptIntf,
     uADCompDataSet, uADCompClient
     {$IFNDEF FPC}
      {$IF CompilerVersion > 26} // Delphi XE6 pra cima
       , uADStanStorageBin
      {$IFEND}
     {$ENDIF}
    {$ENDIF}
   {$IFEND};
 {$ENDIF}

 Const
  dwftColor       = Integer(255);
 {$IFDEF COMPILER10_UP}
  FieldTypeIdents : Array[dwftColor..dwftColor] Of TIdentMapEntry = ((Value: dwftColor; Name: 'ftColor'));
 {$ELSE}
  FieldTypeIdents : Array[0..7]                 Of TIdentMapEntry = ((Value: dwftTimeStampOffset; Name: 'ftTimeStampOffset'),
                                                                     (Value: dwftStream;          Name: 'ftStream'),
                                                                     (Value: dwftSingle;          Name: 'ftSingle'),
                                                                     (Value: dwftExtended;        Name: 'ftExtended'),
                                                                     (Value: dwftByte;            Name: 'ftByte'),
                                                                     (Value: dwftShortint;        Name: 'ftShortint'),
                                                                     (Value: dwftLongWord;        Name: 'ftLongWord'),
                                                                     (Value: dwftColor;           Name: 'ftColor'));
 {$ENDIF}

 Type
 {$IFDEF FPC}
  DWInteger       = Longint;
  DWInt64         = Int64;
  DWFloat         = Real;
  DWFieldTypeSize = Longint;
  DWBufferSize    = Longint;
 {$ELSE}
  DWInteger       = Integer;
  DWInt64         = Int64;
  DWFloat         = Real;
  DWFieldTypeSize = Integer;
  DWBufferSize    = Longint;
 {$ENDIF}
 PDWInt64         = ^DWInt64;
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    DWString     = String;
    DWWideString = String;
   {$ELSE}
    DWString     = Utf8String;
    DWWideString = Utf8String;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    DWString     = Utf8String;
    DWWideString = Utf8String;
   {$ELSE}
    DWString     = AnsiString;
    DWWideString = WideString;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  DWString     = AnsiString;
  DWWideString = WideString;
 {$ENDIF}
 PArrayData    = ^TArrayData;
 TArrayData    = Array of Variant;
 Type
  TWorkMode = (wmRead, wmWrite);
  TWorkInfo = Record
   Current,
   Max     : Int64;
   Level   : Integer;
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
  TRESTDWParamsHeader = Packed Record
   VersionNumber,
   RecordCount,
   ParamsCount    : DWInteger; //new for ver15
   DataSize       : DWInt64; //new for ver15
 End;

 Type
  TClassNull= Class(TComponent)
 End;

 Type
  RESTDWArrayError          = Class (Exception);
  RESTDWTableError          = Class (Exception);
  RESTDWDatabaseError       = Class (Exception);
  TFieldsList               = Array of TFieldDefinition;
  TConnStatus               = (hsResolving, hsConnecting, hsConnected,
                               hsDisconnecting, hsDisconnected, hsStatusText);
  TRESTDWClientStage        = (csNone, csLoggedIn, csRejected);
  TEncodeSelect             = (esASCII,     esUtf8, esANSI);
  TObjectDirection          = (odIN, odOUT, odINOUT);
  TDataAttributes           = Set of (dwCalcField,    dwNotNull, dwLookup,
                                      dwInternalCalc, dwAggregate);

  TSendEvent                = (seGET,       sePOST,
                               sePUT,       seDELETE,
                               sePatch);
  TTypeRequest              = (trHttp,      trHttps);
  TDatasetEvents            = Procedure (DataSet: TDataSet) Of Object;
  TRESTDwSessionData        = Class(TCollectionItem);
  TRESTDWDatabaseType       = (dbtUndefined, dbtAccess, dbtDbase, dbtFirebird, dbtInterbase, dbtMySQL,
                               dbtSQLLite,   dbtOracle, dbtMsSQL, dbtODBC,     dbtParadox,  dbtPostgreSQL,
                               dbtAdo);
  TWideChars                = Array of WideChar;
  TRESTDWBytes              = Array of Byte;
  TOnWriterProcess          = Procedure(DataSet               : TDataSet;
                                        RecNo, RecordCount    : Integer;
                                        Var AbortProcess      : Boolean) Of Object;

 Type
  TProxyOptions = Class(TPersistent)
  Private
   vServer,                  //Servidor Proxy na Rede
   vLogin,                   //Login do Servidor Proxy
   vPassword     : String;   //Senha do Servidor Proxy
   vPort         : Integer;  //Porta do Servidor Proxy
  Public
   Constructor Create;
   Procedure   Assign(Source : TPersistent); Override;
  Published
   Property Server        : String  Read vServer   Write vServer;   //Servidor Proxy na Rede
   Property Port          : Integer Read vPort     Write vPort;     //Porta do Servidor Proxy
   Property Login         : String  Read vLogin    Write vLogin;    //Login do Servidor
   Property Password      : String  Read vPassword Write vPassword; //Senha do Servidor
 End;

 Type
  TConnectionDefs = Class(TPersistent)
  Private
   votherDetails,
   vCharset,
   vDatabaseName,
   vHostName,
   vUsername,
   vPassword,
   vProtocol,
   vDriverID,
   vDataSource       : String;
   vdbPort         : Integer;
   vDWDatabaseType : TRESTDWDatabaseType;
  Private
   Function GetDatabaseType(Value : String)          : TRESTDWDatabaseType;Overload;
   Function GetDatabaseType(Value : TRESTDWDatabaseType) : String;         Overload;
  Public
   Constructor Create; //Cria o Componente
   Destructor  Destroy;Override;//Destroy a Classe
   Procedure   Assign(Source : TPersistent); Override;
   Function    ToJSON : String;
   Procedure   LoadFromJSON(Value : String);
  Published
   Property DriverType   : TRESTDWDatabaseType Read vDWDatabaseType Write vDWDatabaseType;
   Property Charset      : String          Read vCharset        Write vCharset;
   Property DriverID     : String          Read vDriverID       Write vDriverID;
   Property DatabaseName : String          Read vDatabaseName   Write vDatabaseName;
   Property HostName     : String          Read vHostName       Write vHostName;
   Property Username     : String          Read vUsername       Write vUsername;
   Property Password     : String          Read vPassword       Write vPassword;
   Property Protocol     : String          Read vProtocol       Write vProtocol;
   Property dbPort       : Integer         Read vdbPort         Write vdbPort;
   Property DataSource   : String          Read vDataSource     Write vDataSource;
   Property otherDetails : String          Read votherDetails   Write votherDetails;
  End;

  Type
   TRESTDWDataRoute   = Class
   Private
    vDataRoute         : String;
    vServerMethodClass : TComponentClass;
   Public
    Constructor Create;
    Property DataRoute         : String           Read vDataRoute         Write vDataRoute;
    Property ServerMethodClass : TComponentClass  Read vServerMethodClass Write vServerMethodClass;
  End;

  Type
   PRESTDWDataRoute     = ^TRESTDWDataRoute;
   TRESTDWDataRouteList = Class(TList)
   Private
    Function  GetRec(Index : Integer) : TRESTDWDataRoute; Overload;
    Procedure PutRec(Index : Integer;
                     Item  : TRESTDWDataRoute); Overload;
   Public
    Procedure ClearList;
    Constructor Create;
    Destructor  Destroy; Override;
    Function    RouteExists(Value : String) : Boolean;
    Procedure   Delete(Index : Integer); Overload;
    Function    Add   (Item  : TRESTDWDataRoute) : Integer; Overload;
    Function    GetServerMethodClass(DataRoute             : String;
                                     Var ServerMethodClass : TComponentClass) : Boolean;
    Property    Items [Index : Integer] : TRESTDWDataRoute Read GetRec Write PutRec; Default;
  End;

 Type
  TArguments = Array Of String;

 Type
  TStreamType = (stMetaData, stAll);

 Type
  TPrivateClass = Class
 End;

 Type
  {$IFDEF FPC}
   {$IFDEF RESTDWLAZDRIVER}
    TRESTDWClientSQLBase   = Class(TMemDataset)                   //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWUNIDACMEM}
    TRESTDWClientSQLBase   = Class(TVirtualTable)
   {$ENDIF}
   {$IFDEF RESTDWMEMTABLE}
    TRESTDWClientSQLBase   = Class(TDWMemtable)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
  {$ELSE}
   {$IFDEF RESTDWCLIENTDATASET}
    TRESTDWClientSQLBase   = Class(TClientDataSet)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWKBMMEMTABLE}
    TRESTDWClientSQLBase   = Class(TKbmMemtable)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWUNIDACMEM}
    TRESTDWClientSQLBase   = Class(TVirtualTable)
   {$ENDIF}
   {$IFDEF RESTDWFDMEMTABLE}
    TRESTDWClientSQLBase   = Class(TFDMemtable)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWADMEMTABLE}
    TRESTDWClientSQLBase   = Class(TADMemtable)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
   {$IFDEF RESTDWMEMTABLE}
    TRESTDWClientSQLBase   = Class(TDWMemtable)                 //Classe com as funcionalidades de um DBQuery
   {$ENDIF}
  {$ENDIF}
  Private
   fsAbout                            : TRESTDWAboutInfo;
   vComponentTag,
   vSequenceField,
   vSequenceName                      : String;
   vLoadFromStream,
   vBinaryCompatibleMode,
   vOnLoadStream,
   vBinaryLoadRequest                 : Boolean;
   vOnWriterProcess                   : TOnWriterProcess;
   {$IFDEF FPC}
   vDatabaseCharSet                   : TDatabaseCharSet;
   Procedure SetDatabaseCharSet(Value : TDatabaseCharSet);
   Function  GetDatabaseCharSet : TDatabaseCharSet;
   {$ENDIF}
   Function  OnEditingState : Boolean;
   Class Procedure SaveRecordToStream(Dataset : TDataset;
                                      Stream  : TStream);
   Class Procedure SaveToStreamFromDataset(Dataset           : TDataset;
                                           Const StreamValue : TMemoryStream);
   Procedure LoadFromStreamToDataset      (Const StreamValue : TMemoryStream;
                                           DataType          : TStreamType = stAll);
  Public
   Procedure   BaseOpen;
   Procedure   BaseClose;
   Procedure   ForceInternalCalc;
   Procedure   SetComponentTAG;
   Procedure   SaveToStream     (Var Value   : TMemoryStream);Overload;
   Class Procedure SaveToStream (Dataset     : TDataset;
                                 Var Value   : TMemoryStream);Overload;
   Procedure   LoadFromStream   (Value       : TMemoryStream;
                                 DataType    : TStreamType = stAll);
   Procedure   SetInDesignEvents(Const Value : Boolean);Virtual;Abstract;
   Procedure   SetInBlockEvents (Const Value : Boolean);Virtual;Abstract;
   Procedure   SetInitDataset   (Const Value : Boolean);Virtual;Abstract;
   Procedure   PrepareDetailsNew;                       Virtual;Abstract;
   Procedure   PrepareDetails(ActiveMode : Boolean);    Virtual;Abstract;
   Constructor Create(AOwner: TComponent);Override;
   Property    InLoadFromStream  : Boolean       Read vLoadFromStream;
   Property    BinaryLoadRequest : Boolean       Read vBinaryLoadRequest;
   Property    OnLoadStream      : Boolean       Read vOnLoadStream       Write vOnLoadStream;
   Property    Componenttag      : String        Read vComponentTag;
   {$IFDEF FPC}
   Property DatabaseCharSet      : TDatabaseCharSet Read GetDatabaseCharSet Write SetDatabaseCharSet;
   {$ENDIF}
  Published
   Property BinaryCompatibleMode : Boolean          Read vBinaryCompatibleMode  Write vBinaryCompatibleMode;
   Property    SequenceName      : String           Read vSequenceName          Write vSequenceName;
   Property    SequenceField     : String           Read vSequenceField         Write vSequenceField;
   Property    OnWriterProcess   : TOnWriterProcess Read vOnWriterProcess       Write vOnWriterProcess;
   Property    AboutInfo         : TRESTDWAboutInfo     Read fsAbout                Write fsAbout Stored False;
 End;

Type
 TRESTDWDatasetArray = Array of TRESTDWClientSQLBase;

implementation

Uses uRESTDWConsts, uRESTDWTools, uRESTDWDataJSON, uRESTDWJSONInterface, uRESTDWBasicDB;

Constructor TConnectionDefs.Create;
Begin
 Inherited;
 vdbPort          := -1;
 vDWDatabaseType  := dbtUndefined;
End;

Destructor  TConnectionDefs.Destroy;
Begin
 Inherited;
End;

Function TConnectionDefs.GetDatabaseType(Value : String)          : TRESTDWDatabaseType;
Begin
 Result := dbtUndefined;
 If LowerCase(Value) = LowerCase('dbtUndefined')       Then
  Result := dbtUndefined
 Else If LowerCase(Value) = LowerCase('dbtAccess')     Then
  Result := dbtAccess
 Else If LowerCase(Value) = LowerCase('dbtDbase')      Then
  Result := dbtDbase
 Else If LowerCase(Value) = LowerCase('dbtFirebird')   Then
  Result := dbtFirebird
 Else If LowerCase(Value) = LowerCase('dbtInterbase')  Then
  Result := dbtInterbase
 Else If LowerCase(Value) = LowerCase('dbtMySQL')      Then
  Result := dbtMySQL
 Else If LowerCase(Value) = LowerCase('dbtMsSQL')      Then
  Result := dbtMsSQL
 Else If LowerCase(Value) = LowerCase('dbtOracle')     Then
  Result := dbtOracle
 Else If LowerCase(Value) = LowerCase('dbtODBC')       Then
  Result := dbtODBC
 Else If LowerCase(Value) = LowerCase('dbtParadox')    Then
  Result := dbtParadox
 Else If LowerCase(Value) = LowerCase('dbtPostgreSQL') Then
  Result := dbtPostgreSQL
 Else If LowerCase(Value) = LowerCase('dbtSQLLite')    Then
  Result := dbtSQLLite
 Else If LowerCase(Value) = LowerCase('dbtAdo')    Then
  Result := dbtAdo;
End;

Function TConnectionDefs.GetDatabaseType(Value : TRESTDWDatabaseType) : String;
Begin
 Case Value Of
  dbtUndefined  : Result := LowerCase('dbtUndefined');
  dbtAccess     : Result := LowerCase('dbtAccess');
  dbtDbase      : Result := LowerCase('dbtDbase');
  dbtFirebird   : Result := LowerCase('dbtFirebird');
  dbtInterbase  : Result := LowerCase('dbtInterbase');
  dbtMySQL      : Result := LowerCase('dbtMySQL');
  dbtSQLLite    : Result := LowerCase('dbtSQLLite');
  dbtOracle     : Result := LowerCase('dbtOracle');
  dbtMsSQL      : Result := LowerCase('dbtMsSQL');
  dbtParadox    : Result := LowerCase('dbtParadox');
  dbtPostgreSQL : Result := LowerCase('dbtPostgreSQL');
  dbtODBC       : Result := LowerCase('dbtODBC');
  dbtAdo        : Result := LowerCase('dbtAdo');
 End;
End;

Procedure   TConnectionDefs.Assign(Source : TPersistent);
Var
 Src : TConnectionDefs;
Begin
 If Source is TConnectionDefs Then
  Begin
   Src := TConnectionDefs(Source);
   votherDetails := Src.votherDetails;
   vDatabaseName := Src.vDatabaseName;
   vHostName     := Src.vHostName;
   vUsername     := Src.vUsername;
   vPassword     := Src.vPassword;
   vdbPort       := Src.vdbPort;
   vDriverID     := Src.vDriverID;
   vDataSource   := Src.vDataSource;
  End
 Else
  Inherited;
End;

Function    TConnectionDefs.ToJSON : String;
Begin
 Result := Format('{"databasename":"%s","hostname":"%s",'+
                  '"username":"%s","password":"%s","dbPort":%d,'+
                  '"otherDetails":"%s","charset":"%s","databasetype":"%s","protocol":"%s",'+
                  '"driverID":"%s","datasource":"%s"}',
                  [EncodeStrings(vDatabaseName{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vHostName{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vUsername{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vPassword{$IFDEF FPC}, csUndefined{$ENDIF}),
                   vdbPort,
                   EncodeStrings(votherDetails{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vCharset{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(GetDatabaseType(vDWDatabaseType){$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vProtocol{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vDriverID{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vDataSource{$IFDEF FPC}, csUndefined{$ENDIF})]);
End;

Procedure TConnectionDefs.LoadFromJSON(Value : String);
Var
 bJsonValue : TRESTDWJSONInterfaceObject;
Begin
 bJsonValue := TRESTDWJSONInterfaceObject.Create(Value);
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    vDatabaseName   := DecodeStrings(bJsonValue.Pairs[0].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vHostName       := DecodeStrings(bJsonValue.Pairs[1].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vUsername       := DecodeStrings(bJsonValue.Pairs[2].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vPassword       := DecodeStrings(bJsonValue.Pairs[3].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    If bJsonValue.Pairs[4].Value <> '' Then
     vdbPort        := StrToInt(bJsonValue.Pairs[4].Value)
    Else
     vdbPort        := -1;
    votherDetails   := DecodeStrings(bJsonValue.Pairs[5].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vCharset        := DecodeStrings(bJsonValue.Pairs[6].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vDWDatabaseType := GetDatabaseType(DecodeStrings(bJsonValue.Pairs[7].Value{$IFDEF FPC}, csUndefined{$ENDIF}));
    vProtocol       := DecodeStrings(bJsonValue.Pairs[8].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vDriverID       := DecodeStrings(bJsonValue.Pairs[9].Value{$IFDEF FPC}, csUndefined{$ENDIF});
    vDataSource     := DecodeStrings(bJsonValue.Pairs[10].Value{$IFDEF FPC}, csUndefined{$ENDIF});
   End;
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Constructor TProxyOptions.Create;
Begin
 Inherited;
 vServer   := '';
 vLogin    := vServer;
 vPassword := vLogin;
 vPort     := 8888;
End;

Procedure TProxyOptions.Assign(Source: TPersistent);
Var
 Src : TProxyOptions;
Begin
 If Source is TProxyOptions Then
  Begin
   Src := TProxyOptions(Source);
   vServer := Src.Server;
   vLogin  := Src.Login;
   vPassword := Src.Password;
   vPort     := Src.Port;
  End
 Else
  Inherited;
End;

Function RPos(const Substr, S: string): Integer;
Var
 I, X, Len: Integer;
Begin
 Len := Length(SubStr);
 I := Length(S) - Len + 1;
 If (I <= 0) Or (Len = 0) Then
  Begin
   RPos := 0;
   Exit;
  End
 Else
  Begin
   While I > 0 Do
    Begin
     If S[I] = SubStr[1] Then
      Begin
       X := 1;
       While (X < Len) And (S[I + X] = SubStr[X + 1]) Do
        Inc(X);
       If (X = Len) Then
        Begin
         RPos := I;
         exit;
        End;
      End;
     Dec(I);
    End;
   RPos := 0;
  End;
End;

Procedure TRESTDWClientSQLBase.BaseClose;
Begin
  {$IFDEF FPC}
   {$IFDEF RESTDWMEMTABLE}
    TDWMemtable(Self).Close;
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    TVirtualTable(Self).Close;
   {$ENDIF}
   {$IFDEF LAZDRIVER}
    TMemDataset(Self).Close;
   {$ENDIF}
  {$ELSE}
  {$IFDEF CLIENTDATASET}
   TClientDataset(Self).Close;
  {$ENDIF}
  {$IFDEF RESJEDI}
   TJvMemoryData(Self).Close;
  {$ENDIF}
  {$IFDEF RESTKBMMEMTABLE}
   Tkbmmemtable(Self).Close;
  {$ENDIF}
  {$IFDEF RESTFDMEMTABLE}
   TFDmemtable(Self).Close;
  {$ENDIF}
  {$IFDEF RESTADMEMTABLE}
   TADmemtable(Self).Close;
  {$ENDIF}
  {$IFDEF RESTDWMEMTABLE}
   TDWMemtable(Self).Close;
  {$ENDIF}
  {$IFDEF UNIDACMEM}
   TVirtualTable(Self).Close;
  {$ENDIF}
  {$ENDIF}
End;

Procedure TRESTDWClientSQLBase.BaseOpen;
Begin
  {$IFDEF FPC}
   {$IFDEF RESTDWMEMTABLE}
    TDWMemtable(Self).Open;
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    TVirtualTable(Self).Open;
   {$ENDIF}
   {$IFDEF LAZDRIVER}
    TMemDataset(Self).Open;
   {$ENDIF}
  {$ELSE}
  {$IFDEF CLIENTDATASET}
   TClientDataset(Self).Open;
  {$ENDIF}
  {$IFDEF RESJEDI}
   TJvMemoryData(Self).Open;
  {$ENDIF}
  {$IFDEF RESTKBMMEMTABLE}
   TKbmmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTFDMEMTABLE}
   TFDmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTADMEMTABLE}
   TADmemtable(Self).Open;
  {$ENDIF}
  {$IFDEF RESTDWMEMTABLE}
   TDWMemtable(Self).Open;
  {$ENDIF}
  {$IFDEF UNIDACMEM}
   TVirtualTable(Self).Open;
  {$ENDIF}
  {$ENDIF}
End;

Constructor TRESTDWClientSQLBase.Create(AOwner: TComponent);
Begin
 Inherited;
 vOnWriterProcess      := Nil;
 vBinaryCompatibleMode := False;
 vLoadFromStream       := False;
 {$IFDEF RESTDWMEMTABLE}
  vBinaryCompatibleMode := True;
  {$IFNDEF FPC}
   {$IF CompilerVersion > 21}
    Encoding            := esUtf8;
   {$ELSE}
    Encoding            := esAscii;
   {$IFEND}
  {$ELSE}
   Encoding             := esUtf8;
  {$ENDIF}
 {$ENDIF}
End;

{$IFDEF FPC}
Function  TRESTDWClientSQLBase.GetDatabaseCharSet : TDatabaseCharSet;
Begin
 Result := vDatabaseCharSet;
End;

Procedure TRESTDWClientSQLBase.SetDatabaseCharSet(Value : TDatabaseCharSet);
Begin
 vDatabaseCharSet := Value;
 {$IFDEF RESTDWMEMTABLE}
  TDWMemtable(Self).DatabaseCharSet := Value; //Classe com as funcionalidades de um DBQuery
 {$ENDIF}
End;
{$ENDIF}

Function TRESTDWClientSQLBase.OnEditingState: Boolean;
Begin
 Result := (State in [dsEdit, dsInsert]);
 If Result then
  Edit;
End;

Procedure TRESTDWClientSQLBase.SaveToStream (Var Value   : TMemoryStream);
Begin
 If Not Assigned(Value) Then
  Value := TMemoryStream.Create;
 TRESTDWClientSQLBase.SaveToStreamFromDataset(Self, Value);
 Value.Position := 0;
End;

Class Procedure TRESTDWClientSQLBase.SaveToStream(Dataset    : TDataset;
                                                  Var Value  : TMemoryStream);
Begin
 If Not Assigned(Value) Then
  Value := TMemoryStream.Create;
 TRESTDWClientSQLBase.SaveToStreamFromDataset(Dataset, Value);
 Value.Position := 0;
End;

Class Procedure TRESTDWClientSQLBase.SaveRecordToStream(Dataset : TDataset;
                                                        Stream  : TStream);
Var
 X, I    : Integer;
 J, L    : DWInt64;
 S       : DWString;
 E       : Extended;
 F       : DWFloat;
 Bool    : Boolean;
 B       : TBcd;
 P       : TMemoryStream;
 T       : DWFieldTypeSize;
 D       : TDateTime;
Begin
 P := Nil;
 For I := 0 to Dataset.FieldCount - 1 do
  Begin
   If fkCalculated = Dataset.Fields[I].FieldKind Then Continue;
   T := DWFieldTypeSize(Dataset.Fields[I].DataType);
   Stream.Write(T, Sizeof(DWFieldTypeSize));
   Case TFieldType(T) Of
      ftMemo,
      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ELSE}
         ftWideMemo,{$ENDIF}
      ftFmtMemo,
      ftFixedChar,
      ftWideString,
      ftString : Begin
                  {$IFDEF COMPILER14}
                  {$WARNINGS OFF}
                   S := UnicodeString(Dataset.Fields[I].AsString);
                  {$WARNINGS ON}
                  {$ELSE}
                   {$IFNDEF FPC}
                    {$IF Defined(HAS_FMX)}
                     S := Dataset.Fields[I].AsString;
                    {$ELSE}
                     S := Dataset.Fields[I].AsString;
                    {$IFEND}
                   {$ELSE}
                    S := Dataset.Fields[I].AsString;
                   {$ENDIF}
                  {$ENDIF}
                  If (Length(S) > Dataset.Fields[I].Size) And
                     (Dataset.Fields[I].DataType In [ftString, ftFixedChar]) Then
                   SetLength(S, Dataset.Fields[I].Size);
                  S := Utf8Encode(S);
                  L := Length(S);
                  Stream.Write(L, Sizeof(L));
                  {$IFNDEF FPC}
                  If L <> 0 Then Stream.Write(S[InitStrPos], L);
                  {$ELSE}
                  If L <> 0 Then Stream.Write(S[1], L);
                  {$ENDIF}
                 End;
      {$IFDEF COMPILER12_UP}
      ftByte,
      ftShortint : Begin
                    J := Dataset.Fields[I].AsInteger;
                    Stream.Write(J, Sizeof(DWInteger));
                   End;
      {$ENDIF}
      ftSmallint : Begin
                    If Not(Dataset.Fields[I].IsNull) Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                      X := Dataset.Fields[I].AsInteger;
                      Stream.Write(X, Sizeof(DWInteger));
                     End
                    Else
                     Begin
                      Bool := True;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                   End;
      ftWord,
      ftInteger,
      ftAutoInc :  Begin
                    If Not(Dataset.Fields[I].IsNull) Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                      J := Dataset.Fields[I].AsInteger;
                      Stream.Write(J, Sizeof(DWInteger));
                     End
                    Else
                     Begin
                      Bool := True;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                   End;
      ftFloat,
      ftFMTBcd,
      ftCurrency,
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftExtended, ftSingle, {$IFEND}{$ENDIF}
      ftBCD     : Begin
                    If Not(Dataset.Fields[I].IsNull) Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                      F := Dataset.Fields[I].AsFloat;
                      Stream.Write(F, Sizeof(DWFloat));
                     End
                    Else
                     Begin
                      Bool := True;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                  End;
      ftDate,
      ftTime,
      ftDateTime,
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftTimeStampOffset, {$IFEND}{$ENDIF}
      ftTimeStamp : Begin
                     If Not Dataset.Fields[I].IsNull Then
                      J := DateTimeToUnix(Dataset.Fields[I].AsDateTime)
                     Else
                      J := 0;
                     Stream.Write(J, Sizeof(DWInt64));
                    End;
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord,{$IFEND}{$ENDIF}
      ftLargeint : Begin
                    If Not(Dataset.Fields[I].IsNull) Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                      {$IFNDEF FPC}
                       {$IF CompilerVersion > 21}
                        J := Dataset.Fields[I].AsLargeInt;
                       {$ELSE}
                        J := Dataset.Fields[I].AsInteger;
                       {$IFEND}
                      {$ELSE}
                       J := Dataset.Fields[I].AsLargeInt;
                      {$ENDIF}
                      Stream.Write(J, Sizeof(DWInt64));
                     End
                    Else
                     Begin
                      Bool := True;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                   End;
      ftBoolean  : Begin
                    If Dataset.Fields[I].isnull Then
                     Begin
                      Bool := False;
                      Stream.Write(Bool, Sizeof(Byte));
                     End
                    Else
                     Begin
                      Bool := Dataset.Fields[I].AsBoolean;
                      Stream.Write(Bool, Sizeof(Byte));
                     End;
                   End;
      ftVariant,
      ftInterface,
      ftIDispatch,
      ftGuid  :  Begin
                  {$IFDEF COMPILER14}
                  {$WARNINGS OFF}
                   S := UnicodeString(Dataset.Fields[I].AsString);
                  {$WARNINGS ON}
                  {$ELSE}
                   {$IFNDEF FPC}
                    {$IF Defined(HAS_FMX)}
                     S := Dataset.Fields[I].AsString;
                    {$ELSE}
                     S := Dataset.Fields[I].AsString;
                    {$IFEND}
                   {$ELSE}
                    S := Dataset.Fields[I].AsString;
                   {$ENDIF}
                  {$ENDIF}
                  If (Length(S) > Dataset.Fields[I].Size) And
                     (Dataset.Fields[I].DataType In [ftString, ftFixedChar]) Then
                   SetLength(S, Dataset.Fields[I].Size);
                  S := Utf8Encode(S);
                  L := Length(S);
                  Stream.Write(L, Sizeof(L));
                  {$IFNDEF FPC}
                  If L <> 0 Then Stream.Write(S[InitStrPos], L);
                  {$ELSE}
                  If L <> 0 Then Stream.Write(S[1], L);
                  {$ENDIF}
                 End;
      ftBlob,
      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftStream,{$IFEND}{$ENDIF}
      ftBytes : Begin
                 P := TMemoryStream.Create;
                 Try
                  If Not Dataset.Fields[I].isnull Then
                   TBlobField(Dataset.Fields[I]).SaveToStream(P);
                  If Assigned(P) Then
                   Begin
                    L := P.Size;
                    Stream.Write(L, Sizeof(DWInt64));
                    P.Position := 0;
                    If L <> 0 then
                     Stream.CopyFrom(P, L);
                   End
                  Else
                   Begin
                    L := 0;
                    Stream.Write(L, Sizeof(DWInt64));
                   End;
                 Finally
                  FreeAndNil(P);
                 End;
                End;
      Else
       Begin
       {$IFNDEF COMPILER11_UP}
        If Not Dataset.Fields[I].isnull Then Continue;
        Case Integer(Dataset.Fields[I].DataType) Of
         dwftLongWord : Begin
                         J := Dataset.Fields[I].AsInteger;
                         Stream.Write(J, Sizeof(DWInteger));
                        End;
         dwftExtended,
         dwftSingle   : Begin
                         If Not(Dataset.Fields[I].IsNull) Then
                          Begin
                           Bool := False;
                           Stream.Write(Bool, Sizeof(Byte));
                           F := Dataset.Fields[I].AsFloat;
                           Stream.Write(F, Sizeof(DWFloat));
                          End
                         Else
                          Begin
                           Bool := True;
                           Stream.Write(Bool, Sizeof(Byte));
                          End;
                        End;
         dwftTimeStampOffset: Begin
                              If Not Dataset.Fields[I].IsNull Then
                               J := DateTimeToUnix(Dataset.Fields[I].AsDateTime)
                              Else
                               J := 0;
                              Stream.Write(J, Sizeof(DWInt64));
                             End;
        End;
       {$ENDIF}
       End;
   End;
  End;
End;

Class Procedure TRESTDWClientSQLBase.SaveToStreamFromDataset(Dataset           : TDataset;
                                                             Const StreamValue : TMemoryStream);
Var
 ParamsHeader : TRESTDWParamsHeader;
 {$IFNDEF FPC}
  {$if CompilerVersion < 21}
   aStream    : TMemoryStream;
  {$IFEND}
 {$ENDIF}
 I, Temp      : Integer;
 EndPos,
 StartPos     : Int64;
 {$IFNDEF FPC}
  {$IF (CompilerVersion >= 26) And (CompilerVersion <= 30)}
   {$IF Defined(HAS_FMX)}
    S, W : String;
   {$ELSE}
    S, W : Utf8String;
   {$IFEND}
  {$ELSE}
   {$IF Defined(HAS_FMX)}
    S, W : Utf8String;
   {$ELSE}
    S, W : AnsiString;
   {$IFEND}
  {$IFEND}
 {$ELSE}
  S, W   : AnsiString;
 {$ENDIF}
 {$IFDEF FPC}
 Function GetDefinitions(Dataset : TDataset) : AnsiString;
 {$ELSE}
 {$IF CompilerVersion < 25}
 Function GetDefinitions(Dataset : TDataset) : AnsiString;
 {$ELSE}
 Function GetDefinitions(Dataset : TDataset) : String;
 {$IFEND}
 {$ENDIF}
 Var
  I : Integer;
  S, S2: string;
  L : TStrings;
 Begin
  L := TStringList.Create;
  Try
   For I := 0 To Dataset.FieldCount - 1 Do
    Begin
     S := Dataset.Fields[I].FieldName + '=' + GetFieldTypeB(Dataset.Fields[I].DataType);
     If fkLookup = Dataset.Fields[I].FieldKind then
      S := S + ':lookup'
     Else If fkCalculated = Dataset.Fields[I].FieldKind then
      S := S + ':calc';
     If (Dataset.Fields[I].Size > 0) and (Dataset.Fields[I].DataType <> ftGuid) Then
      S2 := IntToStr(Dataset.Fields[I].Size)
     Else
      S2 := '';
     If Dataset.Fields[I].Required Then
      Begin
       If S2 <> '' Then
        S := S + ',' + S2 + ':nn'
       Else
        S := S + ',nn';
      End
     Else
      Begin
       If S2 <> '' Then
         S := S + ',' + S2;
      End;
     L.Add(S);
    End;
   {$IFNDEF FPC}
    {$IF Defined(HAS_FMX)}
     Result := String(L.Text);
    {$ELSE}
     Result := AnsiString(L.Text);
    {$IFEND}
   {$ELSE}
    Result := AnsiString(L.Text);
   {$ENDIF}
  Finally
   L.Free;
  End;
 End;
Begin
 Try
  If Not Dataset.Active Then
   Dataset.Active := True;
  Dataset.DisableControls;
  Dataset.First;
  {$IFNDEF FPC}
   {$if CompilerVersion < 21}
    aStream := TMemoryStream.Create;
    Try
     If Not Assigned(StreamValue) Then
      Exit;
     //Write init Header
     StartPos := StreamValue.Position;
     With ParamsHeader Do
      Begin
       VersionNumber := DwParamsHeaderVersion;
       DataSize      := 0;
       ParamsCount   := Dataset.FieldCount;
       RecordCount   := Dataset.RecordCount;
      End;
     //Write dwParamsBinList
     {$IFNDEF FPC}
      {$IF Defined(HAS_FMX)}
       {$IF Defined(HAS_UTF8)} //TODO
        S := String(GetDefinitions(Dataset));
       {$ELSE}
        S := AnsiString(GetDefinitions(Dataset));
       {$IFEND}
      {$ELSE}
       S := AnsiString(GetDefinitions(Dataset));
      {$IFEND}
     {$ELSE}
      S := AnsiString(GetDefinitions(Dataset));
     {$ENDIF}
    // SwapString(S);
     I := Length(S);
     StreamValue.WriteBuffer(I, SizeOf(I));
     StreamValue.WriteBuffer(S[InitStrPos], I);
     For I := 0 To ParamsHeader.RecordCount - 1 Do
      Begin
       SaveRecordToStream(Dataset, StreamValue);
       Dataset.Next;
      End;
     //Remap Bin size
     EndPos := aStream.Size;
     ParamsHeader.DataSize    := EndPos;
     ParamsHeader.ParamsCount := Dataset.FieldCount;
     ParamsHeader.RecordCount := Dataset.RecordCount;
     //Rewrite init Header
     StreamValue.Position := 0;
     aStream.Position := 0;
     StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
     StreamValue.CopyFrom(aStream, aStream.Size);
     StreamValue.Position := 0;
    Finally
     FreeAndNil(aStream);
    End;
   {$ELSE}
    If Not Assigned(StreamValue) Then
     Exit;
    //Write init Header
    StartPos := StreamValue.Position;
    With ParamsHeader Do
     Begin
      VersionNumber := RESTDWParamsHeaderVersion;
      DataSize      := 0;
      ParamsCount   := Dataset.FieldCount;
      RecordCount   := Dataset.RecordCount;
     End;
    StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
    {$IFNDEF FPC}
     {$IF Defined(HAS_FMX)}
      {$IF Defined(HAS_UTF8)} //TODO
       S := String(GetDefinitions(Dataset));
      {$ELSE}
       S := AnsiString(GetDefinitions(Dataset));
      {$IFEND}
     {$ELSE}
      S := AnsiString(GetDefinitions(Dataset));
     {$IFEND}
    {$ELSE}
     S := AnsiString(GetDefinitions(Dataset));
    {$ENDIF}
    I := Length(S);
    StreamValue.WriteBuffer(I, SizeOf(I));
    StreamValue.WriteBuffer(S[InitStrPos], I);
    For I := 0 To ParamsHeader.RecordCount - 1 Do
     Begin
      SaveRecordToStream(Dataset, StreamValue);
      Dataset.Next;
     End;
    //Remap Bin size
    EndPos := StreamValue.Position;
    ParamsHeader.DataSize    := EndPos - StartPos - SizeOf(ParamsHeader);
    ParamsHeader.ParamsCount := Dataset.FieldCount;
    ParamsHeader.RecordCount := Dataset.RecordCount;
    //Rewrite init Header
    StreamValue.Position := StartPos;
    StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
    StreamValue.Position := 0;
   {$IFEND}
  {$ELSE}
  If Not Assigned(StreamValue) Then
   Exit;
  //Write init Header
  StartPos := StreamValue.Position;
  With ParamsHeader Do
   Begin
    VersionNumber := DwParamsHeaderVersion;
    DataSize      := 0;
    ParamsCount   := Dataset.FieldCount;
    RecordCount   := Dataset.RecordCount;
   End;
  StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
  {$IFNDEF FPC}
   {$IF Defined(HAS_FMX)}
    {$IF Defined(HAS_UTF8)} //TODO
     S := String(GetDefinitions(Dataset));
    {$ELSE}
     S := AnsiString(GetDefinitions(Dataset));
    {$IFEND}
   {$ELSE}
    S := AnsiString(GetDefinitions(Dataset));
   {$IFEND}
  {$ELSE}
   S := AnsiString(GetDefinitions(Dataset));
  {$ENDIF}
  I := Length(S);
  StreamValue.WriteBuffer(I, SizeOf(I));
  StreamValue.WriteBuffer(S[InitStrPos], I);
  For I := 0 To ParamsHeader.RecordCount - 1 Do
   Begin
    SaveRecordToStream(Dataset, StreamValue);
    Dataset.Next;
   End;
  //Remap Bin size
  EndPos := StreamValue.Position;
  ParamsHeader.DataSize    := EndPos - StartPos - SizeOf(ParamsHeader);
  ParamsHeader.ParamsCount := Dataset.FieldCount;
  ParamsHeader.RecordCount := Dataset.RecordCount;
  //Rewrite init Header
  StreamValue.Position := StartPos;
  StreamValue.WriteBuffer(ParamsHeader, SizeOf(ParamsHeader));
  StreamValue.Position := 0;
  {$ENDIF}
 Finally
  If Dataset.Active Then
   Begin
    Dataset.First;
    Dataset.EnableControls;
   End;
 End;
End;

Procedure TRESTDWClientSQLBase.LoadFromStreamToDataset(Const StreamValue : TMemoryStream;
                                                       DataType          : TStreamType = stAll);
Var
 ParamsHeader   : TRESTDWParamsHeader;
 AbortProcess   : Boolean;
 FPrecision,
 I, VersionNumber,
 RecordsCount,
 ParamsCount,
 L              : Integer;
 S              : DWString;
 vAllListFields,
 vFieldList     : TStringList;
 DataSize,
 aSize,
 StartPos       : Int64;
 Function AppendField(FieldDef,
                      Size, Precision : Integer;
                      Attributes      : TDataAttributes;
                      Const Name      : String) : Integer;
 Var
  vFieldDef : TFieldDef;
 Begin
  Result := FieldDefs.Count;
  If (FieldDefs.IndexOf(Name) > -1) Then
   Begin
    Result := FieldDefs.IndexOf(Name);
    Exit;
   End;
//  If (Fields.Count > 0) Then
//   Begin
//    If (FindField(Name) <> Nil) Then
//     Begin
//      Result := FieldByName(Name).Index;
//      Exit;
//     End;
//   End;
  vFieldDef            := FieldDefs.AddFieldDef;
  vFieldDef.Name       := Name;
  vFieldDef.DataType   := ObjectValueToFieldType(TObjectValue(FieldDef));
  If (Not(vFieldDef.DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd
                                 {$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}])) Then
   vFieldDef.Size      := Size
  Else
   vFieldDef.Size      := 0;
  If (vFieldDef.DataType In [ftFloat, ftCurrency, ftBCD,
                             {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                             {$IFEND}{$ENDIF} ftFMTBcd]) Then
   vFieldDef.Precision := Precision;
   If dwNotNull in Attributes Then
    vFieldDef.Required          := True;
   If dwInternalCalc in Attributes Then
    vFieldDef.InternalCalcField := True;
//  vFieldDef.CreateField(Self);
 End;
 {$IFNDEF FPC}
 {$IF Defined(HAS_FMX)}
 Procedure Init(const Definitions : String);
 {$ELSE}
 Procedure Init(const Definitions : AnsiString);
 {$IFEND}
 {$ELSE}
 Procedure Init(const Definitions : AnsiString);
 {$ENDIF}
 Var
  X, I, P, Sz : Integer;
  N, S1, S2   : string;
  B: Boolean;
  A: TDataAttributes;
  vFieldDefinition : TFieldDefinition;
 Begin
  FieldDefs.Clear;
  FieldDefs.BeginUpdate;
  Try
   vAllListFields.Text := String(Definitions);
   For I := 0 to vAllListFields.Count - 1 do
    Begin
     If Pos('=', vAllListFields[I]) = 0 Then Continue;
     N := vAllListFields.Names[I];
     S1 := Trim(vAllListFields.ValueFromIndex[I]);
     P := Pos(',', S1);
     If P > 0 Then
      Begin
       S2 := Trim(LowerCase(Copy(S1, P + 1, MaxInt)));
       SetLength(S1, P - 1);
       S1 := Trim(S1);
       B := Pos('nn:', S2) = 1;
       If B Then
        {$IFDEF CIL}Borland.Delphi.{$ENDIF}System.Delete(S2, 1, 3)
       Else
        Begin
         P := RPos(':nn', S2);
         B := P > 0;
         If B Then
          {$IFDEF CIL}Borland.Delphi.{$ENDIF}System.Delete(S2, P, 3)
         Else
          Begin
           B := S2 = 'nn';
           If B Then
            S2 := '';
          End;
        End;
       Sz := StrToIntDef(S2, 0);
      End
     Else
      Begin
       B := False;
       Sz := 0;
      End;
     If B Then
      A := [dwNotNull]
     Else
      A := [];
     P := RPos(':calc', LowerCase(S1));
     If P > 0 Then
      Begin
       SetLength(S1, P - 1);
       S1 := Trim(S1);
       Include(A, dwCalcField);
      End
     Else
      Begin
       P := RPos(':lookup', LowerCase(S1));
       If P > 0 Then
        Begin
         SetLength(S1, P - 1);
         S1 := Trim(S1);
         Include(A, dwCalcField);
         Include(A, dwLookup);
        End;
      End;
     vFieldDefinition               := TFieldDefinition.Create;
     vFieldDefinition.FieldName     := N;
     vFieldDefinition.DataType      := TFieldType(StringToFieldType(S1));
     If (Not(vFieldDefinition.DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd
                                          {$IFNDEF FPC}{$IF CompilerVersion > 21}, ftSingle{$IFEND}{$ENDIF}])) Then
      vFieldDefinition.Size         := Sz
     Else
      vFieldDefinition.Size         := 0;
     If (vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD,
                                       {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                       {$IFEND}{$ENDIF} ftFMTBcd]) Then
      vFieldDefinition.Precision    := FPrecision;
     vFieldDefinition.Required      := B;
     TRESTDWClientSQL(Self).NewDataField(vFieldDefinition);
     If TRESTDWClientSQL(Self).Fields.Count = 0 Then
      vFieldList.Add(N);
     AppendField(StringToFieldType(S1), Sz, FPrecision, A, N);
     FreeAndNil(vFieldDefinition);
    End;
  Finally
   FieldDefs.EndUpdate;
   TRESTDWClientSQL(Self).SetInBlockEvents(True);
   TRESTDWClientSQL(Self).Inactive := True;
   TRESTDWClientSQL(Self).CreateDataSet;
   If Not TRESTDWClientSQL(Self).Active Then
    TRESTDWClientSQL(Self).Open;
   TRESTDWClientSQL(Self).Inactive := False;
  End;
 End;
 Procedure LoadRecordFromStream(FieldList : TStringList;
                                Stream    : TStream);
 Var
  X, I       : Integer;
  J, L       : DWInt64;
  S, W       : DWString;
  E          : Extended;
  F          : DWFloat;
  Bool       : Boolean;
  B          : TBcd;
  P          : TMemoryStream;
  T          : DWFieldTypeSize;
  D          : TDateTime;
  vField     : TField;
  vFieldName : String;
  Function IsFieldValue : Boolean;
  Var
   Z : Integer;
  Begin
   Result := False;
   {$IFDEF FPC}
   Z := FieldList.IndexOf(vFieldName);
   If Not(vFieldName = FieldList[Z]) Then
    Z := -1;
   {$ELSE}
   FieldList.Find(vFieldName, Z);
   {$ENDIF}
   Result := Z > -1;
   If Result Then
    Begin
     vField := FindField(vFieldName);
     If vField = Nil Then
      Result := False
     Else If (fkCalculated = vField.FieldKind) Or
             (fkLookup     = vField.FieldKind) Then
      Result := False;
    End;
  End;
 Begin
  For I := 0 To vAllListFields.Count -1 Do
   Begin
    S := '';
    L := 0;
    J := 0;
    vFieldName := vAllListFields.Names[I];
    Stream.ReadBuffer(T, Sizeof(DWFieldTypeSize));
//    T := Integer(vField.DataType);
    Case TFieldType(T) Of
      ftMemo,
      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ELSE}
         ftWideMemo,{$ENDIF}
      ftFmtMemo,
      ftFixedChar,
      ftWideString,
      ftString : Begin
                  Stream.Read(L, Sizeof(L));
                  If L > 0 Then
                   Begin
                    SetLength(S, L);
                    {$IFDEF FPC}
                     If L <> 0 Then
                      Stream.ReadBuffer(Pointer(S)^, L);
                     S := GetStringEncode(S, vDatabaseCharSet);
                    {$ELSE}
                     If L <> 0 Then
                      Stream.Read(S[InitStrPos], L);
                    {$ENDIF}
                   End;
                  If IsFieldValue Then
                   Begin
                    If (Length(S) > vField.Size) And
                       (vField.DataType In [ftString, ftFixedChar]) Then
                      vField.AsString := S;
                     {$IFNDEF FPC}
                      {$IF Defined(HAS_FMX)}
                       {$IFDEF WINDOWS}
                        If SourceSide = dwDelphi Then
                         vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}S{$ENDIF}
                        Else If SourceSide = dwLazarus Then
                         vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}
                       {$ELSE}
                         vField.AsString := S;
                       {$ENDIF}
                      {$ELSE}
                       vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                      {$IFEND}
                     {$ELSE}
                      vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                     {$ENDIF}
                   End;
                 End;
      {$IFDEF COMPILER12_UP}
      ftByte,
      ftShortint : Begin
                    Stream.ReadBuffer(J, Sizeof(DWInteger));
                    If IsFieldValue Then
                     vField.AsInteger := J;
                   End;
      {$ENDIF}
      ftSmallint : Begin
                    Stream.ReadBuffer(Bool, Sizeof(Byte));
                    If Not Bool Then
                     Begin
                      Stream.ReadBuffer(X, Sizeof(DWInteger));
                      If IsFieldValue Then
                       vField.AsInteger := X;
                     End;
                   End;
      ftWord,
      ftInteger,
      ftAutoInc :  Begin
                    Stream.ReadBuffer(Bool, Sizeof(Byte));
                    If Not Bool Then
                     Begin
                      Stream.ReadBuffer(J, Sizeof(DWInteger));
                      If IsFieldValue Then
                       vField.AsInteger := J;
                     End;
                   End;
      ftFloat,
      ftFMTBcd,
      ftCurrency,
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftExtended, ftSingle, {$IFEND}{$ENDIF}
      ftBCD     : Begin
                   F := 0;
                   Stream.ReadBuffer(Bool, Sizeof(Byte));
                   If Not Bool Then
                    Begin
                     Stream.ReadBuffer(F, Sizeof(DWFloat));
                     If IsFieldValue Then
                      vField.Value := F;
                    End;
                  End;
      ftDate,
      ftTime,
      ftDateTime,
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftTimeStampOffset, {$IFEND}{$ENDIF}
      ftTimeStamp : Begin
                     Stream.ReadBuffer(J, Sizeof(DWInt64));
                     If J <> 0 Then
                      If IsFieldValue Then
                       vField.AsDateTime := UnixToDateTime(J);
                    End;
      {$IFNDEF FPC}{$IF CompilerVersion >= 21}ftLongWord,{$IFEND}{$ENDIF}
      ftLargeint : Begin
                    Stream.ReadBuffer(Bool, Sizeof(Byte));
                    If Not Bool Then
                     Begin
                     Stream.ReadBuffer(J, Sizeof(DWInt64));
                     If IsFieldValue Then
                      Begin
                       {$IFNDEF FPC}
                        {$IF CompilerVersion > 21}
                         vField.AsLargeInt := J;
                        {$ELSE}
                         vField.AsInteger := J;
                        {$IFEND}
                       {$ELSE}
                        vField.AsLargeInt := J;
                       {$ENDIF}
                      End;
                     End;
                   End;
      ftBoolean  : Begin
                    Stream.ReadBuffer(Bool, Sizeof(Byte));
                    If IsFieldValue Then
                     vField.AsBoolean := Bool;
                   End;
      ftVariant,
      ftInterface,
      ftIDispatch,
      ftGuid   : Begin
                  Stream.Read(L, Sizeof(L));
                  If L > 0 Then
                   Begin
                    SetLength(S, L);
                    {$IFDEF FPC}
                     If L <> 0 Then
                      Stream.ReadBuffer(Pointer(S)^, L);
                     S := GetStringEncode(S, vDatabaseCharSet);
                    {$ELSE}
                     If L <> 0 Then
                      Stream.Read(S[InitStrPos], L);
                    {$ENDIF}
                   End;
                  If IsFieldValue Then
                   Begin
                    If (Length(S) > vField.Size) And
                       (vField.DataType In [ftString, ftFixedChar]) Then
                     vField.AsString := S;
                     {$IFNDEF FPC}
                      {$IF Defined(HAS_FMX)}
                       {$IFDEF WINDOWS}
                        If SourceSide = dwDelphi Then
                         vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}S{$ENDIF}
                        Else If SourceSide = dwLazarus Then
                         vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}
                       {$ELSE}
                         vField.AsString := S;
                       {$ENDIF}
                      {$ELSE}
                       vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                      {$IFEND}
                     {$ELSE}
                      vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                     {$ENDIF}
                   End;
                 End;
      ftBlob,
      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftStream,{$IFEND}{$ENDIF}
      ftBytes : Begin
                 Stream.ReadBuffer(J, Sizeof(DWInt64));
                 If J > 0 Then
                  Begin
                   P := TMemoryStream.Create;
                   Try
                    P.CopyFrom(Stream, J);
                    P.position := 0;
                    If IsFieldValue Then
                     Begin
                      If P.Size > 0 Then
                       TBlobField(vField).LoadFromStream(P)
                      Else
                       TBlobField(vField).Clear;
                     End;
                   Finally
                    P.Free;
                   End;
                  End;
                End;
      Else
       Begin
       {$IFNDEF COMPILER11_UP}
        Case Integer(T) Of
         dwftWideMemo : Begin
                         Stream.Read(L, Sizeof(L));
                         If L > 0 Then
                          Begin
                           SetLength(S, L);
                           {$IFDEF FPC}
                            If L <> 0 Then
                             Stream.ReadBuffer(Pointer(S)^, L);
                            S := GetStringEncode(S, vDatabaseCharSet);
                           {$ELSE}
                            If L <> 0 Then
                             Stream.Read(S[InitStrPos], L);
                           {$ENDIF}
                          End;
                         If IsFieldValue Then
                          Begin
                           If (Length(S) > vField.Size) And
                              (vField.DataType In [ftString, ftFixedChar]) Then
                            vField.AsString := S;
                           {$IFNDEF FPC}
                            {$IF Defined(HAS_FMX)}
                             {$IFDEF WINDOWS}
                              If SourceSide = dwDelphi Then
                               vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}S{$ENDIF}
                              Else If SourceSide = dwLazarus Then
                               vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF}
                             {$ELSE}
                               vField.AsString := S;
                             {$ENDIF}
                            {$ELSE}
                             vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                            {$IFEND}
                           {$ELSE}
                            vField.AsString := {$IFDEF FPC}GetStringEncode(S, vDatabaseCharSet){$ELSE}Utf8Decode(S){$ENDIF};
                           {$ENDIF}
                          End;
                        End;
         dwftLongWord : Begin
                         Stream.ReadBuffer(J, Sizeof(DWInteger));
                         If IsFieldValue Then
                          vField.AsInteger := J;
                        End;
         dwftExtended,
         dwftSingle   : Begin
                         F := 0;
                         Stream.ReadBuffer(Bool, Sizeof(Byte));
                         If Not Bool Then
                          Begin
                           Stream.ReadBuffer(F, Sizeof(DWFloat));
                           If IsFieldValue Then
                            vField.Value := F;
                          End;
                        End;
         dwftTimeStampOffset: Begin
                               Stream.ReadBuffer(J, Sizeof(DWInt64));
                               If J <> 0 Then
                                If IsFieldValue Then
                                 vField.AsDateTime := UnixToDateTime(J);
                              End;
        End;
       {$ENDIF}
       End;
    End;
   End;
 End;
Begin
 FPrecision           := 0;
 StreamValue.Position := FPrecision;
 AbortProcess         := False;
 vFieldList           := Nil;
 vAllListFields       := Nil;
 If StreamValue.Size > 0 Then
  Begin
   StreamValue.ReadBuffer(ParamsHeader, Sizeof(TRESTDWParamsHeader));
   VersionNumber   := ParamsHeader.VersionNumber;
   ParamsCount     := ParamsHeader.ParamsCount;
   RecordsCount    := ParamsHeader.RecordCount;
   DataSize        := ParamsHeader.DataSize;
   StartPos        := StreamValue.Position;
   aSize           := StreamValue.Size;
   S := '';
   StreamValue.ReadBuffer(I, SizeOf(I));
   If (I > ParamsHeader.DataSize) Or
      (I > MAXSHORT)              Or
      (I < 0)                     Then
    Raise RESTDWTableError.Create(SCorruptedDefinitions);
   SetLength(S, I);
   {$IFDEF FPC}
    If I <> 0 Then
     StreamValue.ReadBuffer(Pointer(S)^, I);
    S := GetStringEncode(S, vDatabaseCharSet);
   {$ELSE}
    If I <> 0 Then
     StreamValue.Read(S[InitStrPos], I);
   {$ENDIF}
   //Init FieldDefs
   vFieldList     := TStringList.Create;
   vAllListFields := TStringList.Create;
   //Load Data
   DisableControls;
   TRESTDWClientSQL(Self).SetInBlockEvents(True);
   Init(S);
   If DataType = stAll Then
    Begin
     Try
      For I := 0 To RecordsCount - 1 Do
       Begin
        If StreamValue.Position = StreamValue.Size Then
         Break;
        Append;
        LoadRecordFromStream(vFieldList, StreamValue);
        If Assigned(OnWriterProcess) Then
         OnWriterProcess(Self, I +1, RecordsCount, AbortProcess);
        If AbortProcess Then
         Break;
        Post;
       End;
     Finally
      First;
      EnableControls;
      TRESTDWClientSQL(Self).SetInBlockEvents(False);
     End;
    End;
  End
 Else
  Raise Exception.Create(Format(cInvalidBinaryRequest, ['None data came from server.']));
 If Assigned(vFieldList) Then
  FreeAndNil(vFieldList);
 If Assigned(vAllListFields) Then
  FreeAndNil(vAllListFields);
// If Assigned(OnCalcFields) Then
//  OnCalcFields(Self);
End;

Procedure TRESTDWClientSQLBase.LoadFromStream(Value    : TMemoryStream;
                                              DataType : TStreamType = stAll);
Var
 I : Integer;
 //TODO XyberX
//{$IFNDEF RESTDWMEMTABLE}
// vMemBRequest :  TRESTDWMemtable;
// Procedure CopyData;
// Begin
//  vMemBRequest.First;
//  {$IFDEF UNIDACMEM}
//   AssignDataSet(vMemBRequest);
//  {$ELSE}
//   {$IFDEF CLIENTDATASET}
//    LoadFromStream(Value);
//   {$ELSE}
//    Try
//     While Not vMemBRequest.Eof Do
//      Begin
//       Append;
//       CopyRecord(vMemBRequest);
//       Post;
//       vMemBRequest.Next;
//      End;
//    Finally
//    End;
//   {$ENDIF}
//  {$ENDIF}
// End;
//{$ENDIF}
Begin
 vLoadFromStream := True;
 Try
  Try
 //  SetInitDataset(True);
  {$IFDEF FPC}
   {$IFDEF RESTDWMEMTABLE}
    vBinaryLoadRequest := True;
    DisableControls;
    Close;
    Try
     Value.Position := 0;
     If Not vBinaryCompatibleMode Then
      Begin
       TdwMemtable(Self).Encoding        := TRESTDWClientSQL(Self).Encoding;
       TdwMemtable(Self).OnWriterProcess := vOnWriterProcess;
       If Value.Size > 0 Then
        Begin
         TdwMemtable(Self).LoadFromStream(Value);
         TdwMemtable(Self).Active := True;
        End;
      End
     Else
      LoadFromStreamToDataset(Value, DataType);
    Finally
     vOnLoadStream     := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    vBinaryLoadRequest := True;
    DisableControls;
    Close;
    Try
     Value.Position := 0;
     If Not vBinaryCompatibleMode Then
      Begin
       TVirtualTable(Self).LoadFromStream(Value);
       TVirtualTable(Self).Active := True;
      End
     Else
      LoadFromStreamToDataset(Value, DataType);
    Finally
     vOnLoadStream      := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
  {$ELSE}
   {$IFDEF CLIENTDATASET}
    vBinaryLoadRequest := True;
    DisableControls;
    Close;
    Try
     Value.Position := 0;
     If Not vBinaryCompatibleMode Then
      Begin
       TClientDataset(Self).LoadFromStream(Value);
       TClientDataset(Self).Active := True;
      End
     Else
      LoadFromStreamToDataset(Value, DataType);
    Finally
     vOnLoadStream      := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF RESTKBMMEMTABLE}
    Raise Exception.Create(Format(cInvalidBinaryRequest, ['Invalid dataset driver.']));
   {$ENDIF}
   {$IFDEF UNIDACMEM}
    DisableControls;
    Close;
    vBinaryLoadRequest := True;
    Try
     Value.Position := 0;
     If vBinaryCompatibleMode Then
      LoadFromStreamToDataset(Value, DataType)
     Else
      Begin
       If Value.Size > 0 Then
        Begin
         TVirtualTable(Self).LoadFromStream(Value, TVirtualTable(Self).Fields.Count = 0);
         TVirtualTable(Self).Active := True;
        End;
      End;
    Finally
     vOnLoadStream     := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF RESTFDMEMTABLE}
    DisableControls;
    Close;
    Try
     vBinaryLoadRequest := True;
     If vBinaryCompatibleMode Then
      LoadFromStreamToDataset(Value, DataType)
     Else
      Begin
       Try
        If Value.Size > 0 Then
         Begin
          If DataType = stAll Then
           TFDMemtable(Self).ResourceOptions.StoreItems := [siMeta, siData, siDelta]
          Else
           TFDMemtable(Self).ResourceOptions.StoreItems := [siMeta, siDelta];
          TFDMemtable(Self).LoadFromStream(Value, sfBinary);
         End;
        vOnLoadStream     := True;
       Finally
        vOnLoadStream     := False;
        vBinaryLoadRequest := False;
       End;
      End;
    Finally
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF RESTADMEMTABLE}
    DisableControls;
    Close;
    Try
     vBinaryLoadRequest := True;
     If vBinaryCompatibleMode Then
      LoadFromStreamToDataset(Value, DataType)
     Else
      Begin
       Try
        If Value.Size > 0 Then
         Begin
          If DataType = stAll Then
           TADMemtable(Self).ResourceOptions.StoreItems := [siMeta, siData, siDelta]
          Else
           TADMemtable(Self).ResourceOptions.StoreItems := [siMeta, siDelta];
          TADMemtable(Self).LoadFromStream(Value, sfBinary);
         End;
        vOnLoadStream     := True;
       Finally
        vOnLoadStream     := False;
        vBinaryLoadRequest := False;
       End;
      End;
    Finally
     EnableControls;
    End;
   {$ENDIF}
   {$IFDEF RESTDWMEMTABLE}
    DisableControls;
    vBinaryLoadRequest := True;
    Try
     Value.Position := 0;
     If Not vBinaryCompatibleMode Then
      Begin
       TdwMemtable(Self).Encoding        := TRESTDWClientSQL(Self).Encoding;
       TdwMemtable(Self).OnWriterProcess := vOnWriterProcess;
       If Value.Size > 0 Then
        Begin
         TdwMemtable(Self).LoadFromStream(Value);
         TdwMemtable(Self).Active := True;
        End;
      End
     Else
      LoadFromStreamToDataset(Value, DataType);
    Finally
     vOnLoadStream     := False;
     vBinaryLoadRequest := False;
     EnableControls;
    End;
   {$ENDIF}
  {$ENDIF}
  Finally
   vLoadFromStream := False;
 //  SetInitDataset(False);
  End;
 Except
  On E : Exception Do
   Begin
    Raise Exception.Create(Format(cInvalidBinaryRequest, [E.Message]));
   End;
 End
End;

Procedure TRESTDWClientSQLBase.SetComponentTAG;
Begin
 vComponentTag := EncodeStrings(RandomString(10){$IFDEF FPC}, csUndefined{$ENDIF});
End;

Procedure TRESTDWClientSQLBase.ForceInternalCalc;
Var
 needsPost : Boolean;
 saveState : TDataSetState;
Begin
 needsPost := OnEditingState;
 saveState := setTempState(dsInternalCalc);
 Try
  RefreshInternalCalcFields(ActiveBuffer);
 Finally
  RestoreState(saveState);
 End;
 If needsPost Then
  Post;
End;

Constructor TRESTDWDataRoute.Create;
Begin
 vDataRoute         := '';
 vServerMethodClass := TClassNull;
End;

Function TRESTDWDataRouteList.GetRec(Index : Integer) : TRESTDWDataRoute;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TRESTDWDataRoute(TList(Self).Items[Index]^);
End;

Procedure TRESTDWDataRouteList.PutRec(Index : Integer;
                                      Item  : TRESTDWDataRoute);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TRESTDWDataRoute(TList(Self).Items[Index]^) := Item;
End;

Procedure TRESTDWDataRouteList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Constructor TRESTDWDataRouteList.Create;
Begin
 Inherited;
End;

Function   TRESTDWDataRouteList.RouteExists(Value : String) : Boolean;
Var
 I : Integer;
Begin
 Result := False;
 For I := 0 To Count -1 Do
  Begin
   Result := Lowercase(Items[I].DataRoute) = Lowercase(Value);
   If Result Then
    Break;
  End;
End;

Destructor TRESTDWDataRouteList.Destroy;
Begin
 ClearList;
 Inherited;
End;

Procedure TRESTDWDataRouteList.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     {$IFDEF FPC}
     FreeAndNil(TList(Self).Items[Index]^);
     {$ELSE}
      {$IF CompilerVersion > 33}
       FreeAndNil(TRESTDWDataRoute(TList(Self).Items[Index]^));
      {$ELSE}
       FreeAndNil(TList(Self).Items[Index]^);
      {$IFEND}
     {$ENDIF}
     {$IFDEF FPC}
      Dispose(PRESTDWDataRoute(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Function TRESTDWDataRouteList.GetServerMethodClass(DataRoute             : String;
                                                   Var ServerMethodClass : TComponentClass) : Boolean;
Var
 I : Integer;
Begin
 Result            := False;
 ServerMethodClass := Nil;
 For I := 0 To Self.Count -1 Do
  Begin
   Result := Lowercase(DataRoute) = Lowercase(TRESTDWDataRoute(TList(Self).Items[I]^).DataRoute);
   If (Result) Then
    Begin
     ServerMethodClass := TRESTDWDataRoute(TList(Self).Items[I]^).ServerMethodClass;
     Break;
    End;
  End;
End;

Function TRESTDWDataRouteList.Add(Item : TRESTDWDataRoute) : Integer;
Var
 vItem : PRESTDWDataRoute;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

end.
