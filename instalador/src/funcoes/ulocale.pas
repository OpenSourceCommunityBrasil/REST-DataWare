unit ulocale;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TLanguage = (ptBR, enUS, esES);

  TTranslatedObject = record
    Version: string;
    // subtitles
    LanguageSubtitle: string;
    IDESubTitle: string;
    ResourceSubTitle: string;
    ConfirmSubTitle: string;
    InstallSubTitle: string;
    // buttons
    ButtonNext: string;
    ButtonPrevious: string;
    // resources
    DataEngine: string;
    DBWare: string;
    OtherResources: string;
    // memos

  end;
  TTranslatedObjects = array[TLanguage] of TTranslatedObject;

  { TLocale }

  TLocale = class
    FTranslatedObject: TTranslatedObjects;
  private
    procedure FillDefaultLanguageStrings;
  public
    constructor Create;
    destructor Destroy; override;
    property LocalizedNames: TTranslatedObjects read FTranslatedObject;
  end;

implementation

{ TLocale }

procedure TLocale.FillDefaultLanguageStrings;
begin
  with FTranslatedObject[ptBR] do
  begin
    Version := 'Versão';
    LanguageSubtitle := 'Escolha o idioma';
    IDESubTitle := 'Escolha a IDE';
    ResourceSubTitle := 'Escolha os recursos a instalar';
    ButtonNext := 'Próximo >';
    ButtonPrevious := '< Anterior';
    DataEngine := 'Motor de Dados';
    DBWare := 'Drivers de Banco (DBWare)';
    OtherResources := 'Outros Recursos';
  end;

  with FTranslatedObject[enUS] do
  begin
    Version := 'Version';
    LanguageSubtitle := 'Choose your language';
    IDESubTitle := 'Choose an IDE';
    ResourceSubTitle := 'Choose which resources to install';
    ButtonNext := 'Next >';
    ButtonPrevious := '< Back';
    DataEngine := 'Data Engine';
    DBWare := 'Database Drivers (DBWare)';
    OtherResources := 'Other Recursos';
  end;

  with FTranslatedObject[esES] do
  begin
    Version := 'Versión';
    LanguageSubtitle := 'Seleccione su idioma';
    IDESubTitle := 'Seleccione su IDE';
    ResourceSubTitle := 'Elija las características para instalar';
    ButtonNext := 'Próximo >';
    ButtonPrevious := '< Anterior';
    DataEngine := 'Motor de Datos';
    DBWare := 'Drivers de Banco (DBWare)';
    OtherResources := 'Otros Recursos';
  end;
end;

constructor TLocale.Create;
begin
  FillDefaultLanguageStrings;
end;

destructor TLocale.Destroy;
begin

end;

end.
