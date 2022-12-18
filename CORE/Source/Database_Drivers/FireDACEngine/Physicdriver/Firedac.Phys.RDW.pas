unit Firedac.Phys.RDW;

interface

uses
  System.Classes, Firedac.Phys.RDWBase;

type
  TRESTDWFDPhysicDriverLink = class;

  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidOSX32 or pidiOSSimulator or
    pidiOSDevice32 or pidiOSDevice64 or pidAndroid)]
  TRESTDWFDPhysicDriverLink = class(TFDPhysRDWBaseDriverLink)
  protected
    function GetBaseDriverID: String; override;
  end;

implementation

uses
  System.SysUtils, System.IniFiles, System.Variants,
  FireDAC.Stan.Intf, FireDAC.Stan.Consts, FireDAC.Stan.Util,
  FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.Phys, FireDAC.Phys.SQLGenerator, FireDAC.Phys.Meta,
{$IFNDEF FireDAC_MOBILE}
  FireDAC.Phys.MSAccMeta, FireDAC.Phys.MSSQLMeta, FireDAC.Phys.MySQLMeta,
  FireDAC.Phys.OracleMeta, FireDAC.Phys.DB2Meta, FireDAC.Phys.ASAMeta,
  FireDAC.Phys.ADSMeta, FireDAC.Phys.PGMeta, FireDAC.Phys.NexusMeta,
  FireDAC.Phys.InfxMeta,
{$ENDIF}
  Firedac.Phys.RDWMeta, FireDAC.Phys.IBMeta, FireDAC.Phys.SQLiteMeta,
  Firedac.Phys.RDWDef;

type
  TRESTDWFDPhysicDriver     = class;
  TFDPhysRDWConnection = class;

  TRESTDWFDPhysicDriver = class(TFDPhysRDWDriverBase)
  private
    // function GetDriverParams(AKeys: TStrings): TStrings;
  protected
    // Id do driver
    class function GetBaseDriverID: String; override;
    // descrição do Driver
    class function GetBaseDriverDesc: String; override;
    // Tipo do RDBMS
    class function GetRDBMSKind: TFDRDBMSKind; override;
    // Classe
    class function GetConnectionDefParamsClass: TFDConnectionDefParamsClass; override;
    // Cria a FD Phys Connection
    function InternalCreateConnection(AConnHost: TFDPhysConnectionHost): TFDPhysConnection;
      override;
    // Obtém os parametros exibidos no FDCommection
    function GetConnParams(AKeys: TStrings; AParams: TFDDatSTable): TFDDatSTable; override;
  end;

  TFDPhysRDWConnection = class(TFDPhysRDWConnectionBase)
  protected
    // Cria os Metadados(ver todo em TRESTDWFDPhysicDriver.GetRDBMSKind )
    function InternalCreateMetadata: TObject; override;
    // Cria o gerados de comandos SQL (ver todo em TRESTDWFDPhysicDriver.GetRDBMSKind )
    function InternalCreateCommandGenerator(const ACommand: IFDPhysCommand)
      : TFDPhysCommandGenerator; override;
  end;

  { TRESTDWFDPhysicDriverLink }

function TRESTDWFDPhysicDriverLink.GetBaseDriverID: String;
begin
  Result := S_FD_RDWId;
end;

{ TRESTDWFDPhysicDriver }

class function TRESTDWFDPhysicDriver.GetBaseDriverID: String;
begin
  Result := S_FD_RDWId;
end;

class function TRESTDWFDPhysicDriver.GetBaseDriverDesc: String;
begin
  Result := 'RestDataware Data Source';
end;

class function TRESTDWFDPhysicDriver.GetRDBMSKind: TFDRDBMSKind;
begin
  { TODO -oDelcio -cRDW : Implementar forma de obter tipo do banco de dados do lado do Server }
  // Obs: Talvez tenha que ser implementado para o Firedac gerar corretamente os comandos a ser enviados ao servidor.
  // Em algumas situações específicas, o FD gera comandos com algumas diferenças(FB, Mysql, Postgre) de acordo com essa propriedade
  Result := TFDRDBMSKinds.Other;
end;

class function TRESTDWFDPhysicDriver.GetConnectionDefParamsClass: TFDConnectionDefParamsClass;
begin
  Result := TFDPhysRDWConnectionDefParams;
end;

function TRESTDWFDPhysicDriver.InternalCreateConnection(AConnHost: TFDPhysConnectionHost)
  : TFDPhysConnection;
begin
  Result := TFDPhysRDWConnection.Create(Self, AConnHost);
end;

function TRESTDWFDPhysicDriver.GetConnParams(AKeys: TStrings; AParams: TFDDatSTable): TFDDatSTable;
var
  oView        : TFDDatSView;
  oList, oList2: TStrings;
  oIni         : TCustomIniFile;
  i            : Integer;
  sName        : String;
  oManMeta     : IFDPhysManagerMetadata;
begin
  Result := inherited GetConnParams(AKeys, AParams);
  oView  := Result.Select('Name=''' + S_FD_ConnParam_Common_Database + '''');
  if oView.Rows.Count = 1 then
    begin
      oView.Rows[0].BeginEdit;
      oView.Rows[0].SetValues('LoginIndex', 2);
      oView.Rows[0].EndEdit;
    end;

  Result.Rows.Add([Unassigned, S_FD_ConnParam_Common_MetaDefCatalog, '@S', '',
    S_FD_ConnParam_Common_MetaDefCatalog, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_Common_MetaDefSchema, '@S', '',
    S_FD_ConnParam_Common_MetaDefSchema, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_Common_MetaCurCatalog, '@S', '',
    S_FD_ConnParam_Common_MetaCurCatalog, -1]);
  Result.Rows.Add([Unassigned, S_FD_ConnParam_Common_MetaCurSchema, '@S', '',
    S_FD_ConnParam_Common_MetaCurSchema, -1]);

  oList := TStringList.Create(#0, ';');
  try
    FDPhysManager.CreateMetadata(oManMeta);
    oManMeta.GetRDBMSNames(oList);
    Result.Rows.Add([Unassigned, S_FD_ConnParam_Common_RDBMS, oList.DelimitedText, '',
      S_FD_ConnParam_Common_RDBMS, -1]);
  finally
    FDFree(oList);
  end;
end;

{ TFDPhysRDWConnection }

function TFDPhysRDWConnection.InternalCreateCommandGenerator(const ACommand: IFDPhysCommand)
  : TFDPhysCommandGenerator;
begin

  if ACommand <> nil then
    case GetRDBMSKindFromAlias of
{$IFNDEF FireDAC_MOBILE}
      TFDRDBMSKinds.Oracle: Result      := TFDPhysOraCommandGenerator.Create(ACommand, False);
      TFDRDBMSKinds.MSSQL: Result       := TFDPhysMSSQLCommandGenerator.Create(ACommand);
      TFDRDBMSKinds.MSAccess: Result    := TFDPhysMSAccCommandGenerator.Create(ACommand);
      TFDRDBMSKinds.MySQL: Result       := TFDPhysMySQLCommandGenerator.Create(ACommand);
      TFDRDBMSKinds.Db2: Result         := TFDPhysDb2CommandGenerator.Create(ACommand);
      TFDRDBMSKinds.SQLAnywhere: Result := TFDPhysASACommandGenerator.Create(ACommand);
      TFDRDBMSKinds.Advantage: Result   := TFDPhysADSCommandGenerator.Create(ACommand);
      TFDRDBMSKinds.PostgreSQL: Result  := TFDPhysPgCommandGenerator.Create(ACommand);
      TFDRDBMSKinds.NexusDB: Result     := TFDPhysNexusCommandGenerator.Create(ACommand);
      TFDRDBMSKinds.Informix: Result    := TFDPhysInfxCommandGenerator.Create(ACommand);
{$ENDIF}
      TFDRDBMSKinds.Interbase, TFDRDBMSKinds.Firebird:
          Result                   := TFDPhysIBCommandGenerator.Create(ACommand, 0, ecANSI);
      TFDRDBMSKinds.SQLite: Result := TFDPhysSQLiteCommandGenerator.Create(ACommand);
    else Result                    := TFDPhysCommandGenerator.Create(ACommand);
    end
  else
    case GetRDBMSKindFromAlias of
{$IFNDEF FireDAC_MOBILE}
      TFDRDBMSKinds.Oracle: Result      := TFDPhysOraCommandGenerator.Create(Self, False);
      TFDRDBMSKinds.MSSQL: Result       := TFDPhysMSSQLCommandGenerator.Create(Self);
      TFDRDBMSKinds.MSAccess: Result    := TFDPhysMSAccCommandGenerator.Create(Self);
      TFDRDBMSKinds.MySQL: Result       := TFDPhysMySQLCommandGenerator.Create(Self);
      TFDRDBMSKinds.Db2: Result         := TFDPhysDb2CommandGenerator.Create(Self);
      TFDRDBMSKinds.SQLAnywhere: Result := TFDPhysASACommandGenerator.Create(Self);
      TFDRDBMSKinds.Advantage: Result   := TFDPhysADSCommandGenerator.Create(Self);
      TFDRDBMSKinds.PostgreSQL: Result  := TFDPhysPgCommandGenerator.Create(Self);
      TFDRDBMSKinds.NexusDB: Result     := TFDPhysNexusCommandGenerator.Create(Self);
      TFDRDBMSKinds.Informix: Result    := TFDPhysInfxCommandGenerator.Create(Self);
{$ENDIF}
      TFDRDBMSKinds.Interbase, TFDRDBMSKinds.Firebird:
          Result                   := TFDPhysIBCommandGenerator.Create(Self, 0, ecANSI);
      TFDRDBMSKinds.SQLite: Result := TFDPhysSQLiteCommandGenerator.Create(Self);
    else Result                    := TFDPhysCommandGenerator.Create(Self);
    end
end;

function TFDPhysRDWConnection.InternalCreateMetadata: TObject;
var
  iSQLDialect: Integer;
  iClntVer   : TFDVersion;
  eBrand     : TFDPhysIBBrand;
begin
  iClntVer := 0;

  case GetRDBMSKindFromAlias of
{$IFNDEF FireDAC_MOBILE}
    TFDRDBMSKinds.Oracle: Result := TFDPhysOraMetadata.Create(Self, iClntVer, iClntVer, False);
    TFDRDBMSKinds.MSSQL:
        Result := TFDPhysMSSQLMetadata.Create(Self, False, True, True, True, False, 0,
        iClntVer, False);
    TFDRDBMSKinds.MSAccess: Result := TFDPhysMSAccMetadata.Create(Self, 0, iClntVer, GetKeywords);
    TFDRDBMSKinds.MySQL:
        Result := TFDPhysMySQLMetadata.Create(Self, False, 0, iClntVer,
        [nmCaseSens, nmDBApply], False);
    TFDRDBMSKinds.Db2:
        Result := TFDPhysDb2Metadata.Create(Self, 0, iClntVer, GetKeywords, False, True);
    TFDRDBMSKinds.SQLAnywhere: Result := TFDPhysASAMetadata.Create(Self, 0, iClntVer, GetKeywords);
    TFDRDBMSKinds.Advantage: Result := TFDPhysADSMetadata.Create(Self, 0, iClntVer, True);
    TFDRDBMSKinds.PostgreSQL:
        Result := TFDPhysPgMetadata.Create(Self, 0, iClntVer, False, False, False, True);
    TFDRDBMSKinds.NexusDB: Result := TFDPhysNexusMetadata.Create(Self, 0, iClntVer);
    TFDRDBMSKinds.Informix:
        Result := TFDPhysInfxMetadata.Create(Self, 0, iClntVer, GetKeywords, False, True);
{$ENDIF}
    TFDRDBMSKinds.Interbase, TFDRDBMSKinds.Firebird:
      begin
        iSQLDialect := ConnectionDef.AsInteger[S_FD_ConnParam_IB_SQLDialect];
        if iSQLDialect = 0 then
          iSQLDialect := 3;
        // if CompareText(DriverName, 'firebird') = 0 then
        eBrand := ibFirebird;
        // else
        // eBrand := ibInterbase;
        Result := TFDPhysIBMetadata.Create(Self, eBrand, 0, iClntVer, iSQLDialect, False);
      end;
    TFDRDBMSKinds.SQLite:
        Result := TFDPhysSQLiteMetadata.Create(Self, sbSQLite, 0, iClntVer, False, False);
  else
    if (Database <> nil) and Database.Connected then
      Result := TFDPhysRDWMetadata.Create(Self, GetKeywords)
    else
      Result := TFDPhysConnectionMetadata.Create(Self, 0, 0, False);
  end;
end;

initialization

try
  FDPhysManager().RegisterDriverClass(TRESTDWFDPhysicDriver);
except
  // none
end;

end.
