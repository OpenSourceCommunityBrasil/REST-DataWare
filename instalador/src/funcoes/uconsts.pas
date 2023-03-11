unit uconsts;

{$mode ObjFPC}{$H+}

interface
  {$REGION RESTDW Consts}
  //apontar onde está a pasta CORE
const
  DelphiSocketsList = 'Ics,Indy';
  LazarusSocketsList = 'Indy';

  DelphiDBWareList = 'AnyDAC,ApolloDB,FireDAC,Interbase,MyDAC,UniDAC,Zeos';
  LazarusDBWareList = 'Lazarus,UniDAC,Zeos';

  DelphiResourceList = 'CGI,Wizards';
  LazarusResourceList = 'CGI';

var
  TRESTDWCorePaths: array of string = ('Source\', 'Source\Basic', 'Source\Basic\Crypto',
    'Source\Basic\Dialogs', 'Source\Basic\Mechanics', 'Source\Consts',
    'Source\Database_Drivers', 'Source\Includes', 'Source\Plugins',
    'Source\Plugins\DMDados', 'Source\Plugins\JSONViewer',
    'Source\Plugins\Memdataset', 'Source\Plugins\SQLEditor', 'Source\utils',
    'Source\utils\JSON');
  TRESTDWSocketIndyPaths: array of string = ('Source\Sockets\Indy');
  TRESTDWSocketICSPaths: array of string = ('Source\Sockets\Ics');
  TRESTDWWizardsPaths: array of string = ('Source\Wizards', 'Source\Wizards\templates');
  TRESTDWShellToolsPaths: array of string = ('Source\ShellTools');
  {$ENDREGION}

  {$REGION DELPHI Consts}
type
  TDelphiVersions = (Delphi5, Delphi6, Delphi7, Delphi8, Delphi2005,
    Delphi2006, Delphi2007, Delphi2009, Delphi2010, DelphiXE, DelphiXE2,
    DelphiXE3, DelphiXE4, DelphiXE5, Appmethod, DelphiXE6, DelphiXE7,
    DelphiXE8, Delphi10Seattle, Delphi10Berlin, Delphi10Tokyo, Delphi10Rio,
    Delphi10Sydney, Delphi11Alexandria);
var
  TDelphiVersionsNames: array of string = ('Delphi 5', 'Delphi 6', 'Delphi 7', 'Delphi 8',
    'BDS 2005', 'BDS 2006', 'RAD Studio 2007', 'RAD Studio 2009',
    'RAD Studio 2010', 'RAD Studio XE', 'RAD Studio XE2', 'RAD Studio XE3',
    'RAD Studio XE4', 'RAD Studio XE5', 'Appmethod 1.13',
    'RAD Studio XE6/Appmethod 1.14', 'RAD Studio XE7/Appmethod 1.15',
    'RAD Studio XE8', 'RAD Studio 10 Seattle', 'RAD Studio 10.1 Berlin',
    'RAD Studio 10.2 Tokyo', 'RAD Studio 10.3 Rio', 'RAD Studio 10.4 Sydney',
    'RAD Studio 11.0 Alexandria');

  TDelphiVersionNumbers: array of double = (13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 18.5,
    20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 27.0, 28.0, 29.0,
    30.0, 31.0, 32.0, 33.0, 34.0, 35.0);

  TDelphiRegistryPaths: array of string = ('\Software\Borland\Delphi\5.0',
    '\Software\Borland\Delphi\6.0', '\Software\Borland\Delphi\7.0',
    '\Software\Borland\BDS\2.0', '\Software\Borland\BDS\3.0',
    '\Software\Borland\BDS\4.0', '\Software\Borland\BDS\5.0',
    '\Software\CodeGear\BDS\6.0', '\Software\CodeGear\BDS\7.0',
    '\Software\Embarcadero\BDS\8.0', '\Software\Embarcadero\BDS\9.0',
    '\Software\Embarcadero\BDS\10.0', '\Software\Embarcadero\BDS\11.0',
    '\Software\Embarcadero\BDS\12.0', '\Software\Embarcadero\BDS\13.0',
    '\Software\Embarcadero\BDS\14.0', '\Software\Embarcadero\BDS\15.0',
    '\Software\Embarcadero\BDS\16.0', '\Software\Embarcadero\BDS\17.0',
    '\Software\Embarcadero\BDS\18.0', '\Software\Embarcadero\BDS\19.0',
    '\Software\Embarcadero\BDS\20.0', '\Software\Embarcadero\BDS\21.0',
    '\Software\Embarcadero\BDS\22.0');
  {$ENDREGION}

implementation

end.
