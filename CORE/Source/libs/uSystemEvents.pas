unit uSystemEvents;

interface

Uses SysUtils, Classes, uDWConstsData, uDWConstsCharset, ServerUtils;

Type
 TDWDatabaseType       = (dbtUndefined, dbtAccess, dbtDbase, dbtFirebird, dbtInterbase, dbtMySQL,
                          dbtSQLLite,   dbtOracle, dbtMsSQL, dbtODBC,     dbtParadox,  dbtPostgreSQL,
                          dbtAdo);
 TConnectionDefs       = Class;
 TWelcomeMessage       = Procedure(Welcomemsg, AccessTag : String;
                                   Var ConnectionDefs    : TConnectionDefs;
                                   Var Accept            : Boolean;
                                   Var ContentType,
                                   ErrorMessage          : String) Of Object;
 TNotifyWelcomeMessage = Procedure(Welcomemsg, AccessTag : String;
                                   Var ConnectionDefs    : TConnectionDefs;
                                   Var Accept            : Boolean) Of Object;
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
  vDWDatabaseType : TDWDatabaseType;
 Private
  Function GetDatabaseType(Value : String)          : TDWDatabaseType;Overload;
  Function GetDatabaseType(Value : TDWDatabaseType) : String;         Overload;
 Public
  Constructor Create; //Cria o Componente
  Destructor  Destroy;Override;//Destroy a Classe
  Procedure   Assign(Source : TPersistent); Override;
  Function    ToJSON : String;
  Procedure   LoadFromJSON(Value : String);
 Published
  Property DriverType   : TDWDatabaseType Read vDWDatabaseType Write vDWDatabaseType;
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
 TClientConnectionDefs = Class(TPersistent)
 Private
  vActive : Boolean;
  vConnectionDefs : TConnectionDefs;
  Procedure SetClientConnectionDefs(Value : Boolean);
  Procedure SetConnectionDefs(Value : TConnectionDefs);
 Public
  Constructor Create; //Cria o Componente
  Destructor  Destroy;Override;//Destroy a Classe
 Published
  Property Active         : Boolean         Read vActive         Write SetClientConnectionDefs;
  Property ConnectionDefs : TConnectionDefs Read vConnectionDefs Write SetConnectionDefs;
End;

Type
 TRESTDWConnectionParams = Class(TPersistent)
 Private
  vBinaryRequest,
  vEncodeStrings,
  vCompression,
  vActive,
  vProxy                : Boolean;
  vTimeOut,
  vPoolerPort           : Integer;
  vAccessTag,
  vWelcomeMessage,
  vRestPooler,
  vRestURL,
  vRestWebService,
  vPassword,
  vLogin                : String;
  vPoolerList           : TStringList;
  vProxyOptions         : TProxyOptions;
  vEncoding             : TEncodeSelect;
  {$IFDEF FPC}
  vDatabaseCharSet      : TDatabaseCharSet;
  {$ENDIF}
  vTypeRequest          : TTypeRequest;
  vClientConnectionDefs : TClientConnectionDefs;
  vAuthOptionParams     : TRDWClientAuthOptionParams;
  Function    GetPoolerList     : TStringList;
 Public
  Constructor Create;
  Destructor  Destroy;Override;//Destroy a Classe
  Property    PoolerList         : TStringList                Read GetPoolerList;
 Published
  Property Active                : Boolean                    Read vActive               Write vActive;            //Seta o Estado da Conexão
  Property BinaryRequest         : Boolean                    Read vBinaryRequest        Write vBinaryRequest;
  Property Compression           : Boolean                    Read vCompression          Write vCompression;       //Compressão de Dados
  Property Login                 : String                     Read vLogin                Write vLogin;             //Login do Usuário caso haja autenticação
  Property Password              : String                     Read vPassword             Write vPassword;          //Senha do Usuário caso haja autenticação
  Property Proxy                 : Boolean                    Read vProxy                Write vProxy;             //Diz se tem servidor Proxy
  Property ProxyOptions          : TProxyOptions              Read vProxyOptions         Write vProxyOptions;      //Se tem Proxy diz quais as opções
  Property PoolerService         : String                     Read vRestWebService       Write vRestWebService;    //Host do WebService REST
  Property PoolerURL             : String                     Read vRestURL              Write vRestURL;           //URL do WebService REST
  Property PoolerPort            : Integer                    Read vPoolerPort           Write vPoolerPort;        //A Porta do Pooler do DataSet
  Property PoolerName            : String                     Read vRestPooler           Write vRestPooler;        //Qual o Pooler de Conexão ligado ao componente
  Property RequestTimeOut        : Integer                    Read vTimeOut              Write vTimeOut;           //Timeout da Requisição
  Property EncodeStrings         : Boolean                    Read vEncodeStrings        Write vEncodeStrings;
  Property Encoding              : TEncodeSelect              Read vEncoding             Write vEncoding;          //Encoding da string
  Property WelcomeMessage        : String                     Read vWelcomeMessage       Write vWelcomeMessage;
  {$IFDEF FPC}
  Property DatabaseCharSet       : TDatabaseCharSet           Read vDatabaseCharSet      Write vDatabaseCharSet;
  {$ENDIF}
  Property AccessTag             : String                     Read vAccessTag            Write vAccessTag;
  Property TypeRequest           : TTypeRequest               Read vTypeRequest          Write vTypeRequest       Default trHttp;
  Property AuthenticationOptions : TRDWClientAuthOptionParams Read vAuthOptionParams     Write vAuthOptionParams;
  Property ClientConnectionDefs  : TClientConnectionDefs      Read vClientConnectionDefs Write vClientConnectionDefs;
End;

implementation

Uses uDWJSONObject, uDWJSONTools, uDWJSONInterface, uRESTDWPoolerDB;

Destructor TRESTDWConnectionParams.Destroy;
Begin
 If Assigned(vPoolerList) Then
  FreeAndNil(vPoolerList);
 FreeAndNil(vClientConnectionDefs);
 FreeAndNil(vProxyOptions);
 FreeAndNil(vAuthOptionParams);
 Inherited;
End;

Constructor TRESTDWConnectionParams.Create;
Begin
 Inherited;
 vClientConnectionDefs := TClientConnectionDefs.Create;
 vAuthOptionParams     := TRDWClientAuthOptionParams.Create(Self);
 vAuthOptionParams.AuthorizationOption := rdwAONone;
 vPoolerList           := Nil;
 {$IFNDEF FPC}
 {$IF CompilerVersion > 21}
  vEncoding         := esUtf8;
 {$ELSE}
  vEncoding         := esAscii;
 {$IFEND}
 {$ELSE}
  vEncoding         := esUtf8;
 {$ENDIF}
 vLogin             := 'testserver';
 vRestWebService    := '127.0.0.1';
 vCompression       := True;
 vBinaryRequest     := False;
 vPassword          := vLogin;
 vRestPooler        := '';
 vPoolerPort        := 8082;
 vProxy             := False;
 vEncodeStrings     := True;
 vProxyOptions      := TProxyOptions.Create;
 vTimeOut           := 10000;
 vActive            := True;
End;

Function    TRESTDWConnectionParams.GetPoolerList     : TStringList;
Var
 I             : Integer;
 vTempDatabase : TRESTDWDataBase;
Begin
 vTempDatabase := TRESTDWDataBase.Create(Nil);
 Result        := TStringList.Create;
 vTempDatabase.AuthenticationOptions := AuthenticationOptions;
 Try
  vTempDatabase.AccessTag              := vAccessTag;
  vTempDatabase.Compression            := vCompression;
  vTempDatabase.TypeRequest            := vTypeRequest;
  vTempDatabase.Proxy                  := vProxy;             //Diz se tem servidor Proxy
  vTempDatabase.ProxyOptions.Server    := vProxyOptions.vServer;      //Se tem Proxy diz quais as opções
  vTempDatabase.ProxyOptions.Login     := vProxyOptions.vLogin;      //Se tem Proxy diz quais as opções
  vTempDatabase.ProxyOptions.Password  := vProxyOptions.vPassword;      //Se tem Proxy diz quais as opções
  vTempDatabase.ProxyOptions.Port      := vProxyOptions.vPort;      //Se tem Proxy diz quais as opções
  vTempDatabase.PoolerService          := vRestWebService;    //Host do WebService REST
  vTempDatabase.PoolerURL              := vRestURL;           //URL do WebService REST
  vTempDatabase.PoolerPort             := vPoolerPort;        //A Porta do Pooler do DataSet
//  vTempDatabase.PoolerName           := vRestPooler;        //Qual o Pooler de Conexão ligado ao componente
  vTempDatabase.RequestTimeOut         := vTimeOut;           //Timeout da Requisição
  vTempDatabase.EncodeStrings          := vEncodeStrings;
  vTempDatabase.Encoding               := vEncoding;          //Encoding da string
  vTempDatabase.WelcomeMessage         := vWelcomeMessage;
  if Assigned(vPoolerList) then
   FreeAndNil(vPoolerList);
  vPoolerList                          := vTempDatabase.PoolerList;
  If Assigned(vPoolerList) Then
   Begin
    For I := 0 To vPoolerList.Count -1 Do
     Result.Add(vPoolerList[I]);
   End;
 Finally
  vTempDatabase.Active               := False;
  FreeAndNil(vTempDatabase);
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

Procedure TClientConnectionDefs.SetClientConnectionDefs(Value : Boolean);
Begin
 Case Value Of
  True  : Begin
           If Not Assigned(vConnectionDefs) Then
            vConnectionDefs := TConnectionDefs.Create;
          End;
  False : Begin
           If Assigned(vConnectionDefs) Then
            FreeAndNil(vConnectionDefs);
          End;
 End;
 vActive := Value;
End;

Procedure TClientConnectionDefs.SetConnectionDefs(Value : TConnectionDefs);
Begin
 If vActive Then
  vConnectionDefs := Value;
End;

Constructor TClientConnectionDefs.Create;
Begin
 vActive := False;
End;

Destructor TClientConnectionDefs.Destroy;
Begin
 If Assigned(vConnectionDefs) Then
  FreeAndNil(vConnectionDefs);
 Inherited;
End;

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

Function TConnectionDefs.GetDatabaseType(Value : String)          : TDWDatabaseType;
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

Function TConnectionDefs.GetDatabaseType(Value : TDWDatabaseType) : String;
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
 bJsonValue : TDWJSONObject;
Begin
 bJsonValue := TDWJSONObject.Create(Value);
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

end.

