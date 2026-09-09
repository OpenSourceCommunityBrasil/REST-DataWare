unit uRESTDWBasicDbTypes;

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

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organizao dos Projetos
 Flvio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
}

{$IFNDEF RESTDWLAZARUS}
 {$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
 {$ENDIF}
{$ENDIF}

Interface

Uses
 SysUtils, Classes, Db,
 uRESTDWAbout, uRESTDWProtoTypes, uRESTDWConsts, uRESTDWTools;

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
   Property DBPort       : Integer         Read vdbPort         Write vdbPort;
   Property DataSource   : String          Read vDataSource     Write vDataSource;
   Property OtherDetails : String          Read votherDetails   Write votherDetails;
  End;
 Type
  TRESTDWStorageBase = class(TRESTDWComponent)
  Private
   {$IFDEF FPC}
    FDatabaseCharSet: TDatabaseCharSet;
   {$ENDIF}
   FEncodeStrs: Boolean;
  Protected
   Procedure SaveDatasetToStream  (Dataset    : TDataset;
                                   Var stream : TStream); Virtual;
   Procedure LoadDatasetFromStream(Dataset    : TDataset;
                                   stream     : TStream); Virtual;
   Procedure SaveDWMemToStream    (Dataset    : TDataset;
                                   Var stream : TStream); Virtual;
   Procedure LoadDWMemFromStream  (Dataset    : TDataset;
                                   stream     : TStream); Virtual;
  Public
   Constructor Create        (AOwner     : TComponent); Override;
   Procedure   SaveToStream  (Dataset    : TDataset;
                              Var Stream : TStream);
   Procedure   LoadFromStream(Dataset    : TDataset;
                              Stream     : TStream);
   Procedure   SaveToFile    (Dataset    : TDataset;
                              FileName   : String);
   Procedure   LoadFromFile  (Dataset    : TDataset;
                              FileName   : String);
  Public
   Property  EncodeStrs      : Boolean          Read FEncodeStrs      Write FEncodeStrs;
  Published
   {$IFDEF FPC}
    Property DatabaseCharSet : TDatabaseCharSet Read FDatabaseCharSet Write FDatabaseCharSet;
   {$ENDIF}
  End;



implementation

Uses uRESTDWJSONInterface;

constructor TRESTDWStorageBase.Create(AOwner: TComponent);
Begin
  inherited Create(AOwner);
  FEncodeStrs := True;
End;

Procedure TRESTDWStorageBase.LoadDatasetFromStream(Dataset: TDataset; stream: TStream);
Begin

End;

Procedure TRESTDWStorageBase.LoadDWMemFromStream(Dataset : TDataset;
                                                 stream  : TStream);
Begin

End;

Procedure TRESTDWStorageBase.LoadFromFile(Dataset: TDataset; FileName: String);
Var
 vFileStream : TFileStream;
Begin
 If not FileExists(FileName) then
  Exit;
 vFileStream := TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
 Try
  LoadFromStream(Dataset,TStream(vFileStream));
 Finally
  vFileStream := Nil;
  vFileStream.Free;
 End;
End;

Procedure TRESTDWStorageBase.LoadFromStream(Dataset: TDataset; stream: TStream);
Begin
 LoadDatasetFromStream(Dataset, stream);
End;

Procedure TRESTDWStorageBase.SaveDatasetToStream(Dataset: TDataset; Var stream: TStream);
Begin

End;

Procedure TRESTDWStorageBase.SaveDWMemToStream(Dataset    : TDataset;
                                               Var Stream : TStream);
Begin

End;

Procedure TRESTDWStorageBase.SaveToFile(Dataset: TDataset; FileName: String);
Var
 vFileStream : TFileStream;
Begin
 Try
  vFileStream := TFileStream.Create(FileName,fmCreate);
  Try
   SaveToStream(Dataset,TStream(vFileStream));
  Except
  End;
 Finally
  vFileStream.Free;
 End;
End;

Procedure TRESTDWStorageBase.SaveToStream(Dataset: TDataset; Var stream: TStream);
Begin
 SaveDatasetToStream(Dataset, stream);
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
   Src           := TConnectionDefs(Source);
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
                   EncodeStrings(vHostName    {$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vUsername    {$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vPassword    {$IFDEF FPC}, csUndefined{$ENDIF}),
                   vdbPort,
                   EncodeStrings(votherDetails{$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vCharset     {$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(GetDatabaseType(vDWDatabaseType){$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vProtocol  {$IFDEF FPC}, csUndefined{$ENDIF}),
                   EncodeStrings(vDriverID  {$IFDEF FPC}, csUndefined{$ENDIF}),
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

end.
