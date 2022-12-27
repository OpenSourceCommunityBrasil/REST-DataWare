unit uRESTDWMemIniFiles;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}
{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
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
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils, System.Classes, System.IniFiles;
  {$ELSE ~HAS_UNITSCOPE}
  SysUtils, Classes, IniFiles;
  {$ENDIF ~HAS_UNITSCOPE}
// Initialization (ini) Files
function IniReadBool(const FileName, Section, Line: string): Boolean;              // John C Molyneux
function IniReadInteger(const FileName, Section, Line: string): Integer;           // John C Molyneux
function IniReadString(const FileName, Section, Line: string): string;             // John C Molyneux
procedure IniWriteBool(const FileName, Section, Line: string; Value: Boolean);     // John C Molyneux
procedure IniWriteInteger(const FileName, Section, Line: string; Value: Integer);  // John C Molyneux
procedure IniWriteString(const FileName, Section, Line, Value: string);            // John C Molyneux
// Initialization (ini) Files helper routines
procedure IniReadStrings(IniFile: TCustomIniFile; const Section: string; Strings: TStrings);
procedure IniWriteStrings(IniFile: TCustomIniFile; const Section: string; Strings: TStrings);

implementation
// Initialization Files
function IniReadBool(const FileName, Section, Line: string): Boolean;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    Result := Ini.ReadBool(Section, Line, False);
  finally
    Ini.Free;
  end;
end;
function IniReadInteger(const FileName, Section, Line: string): Integer;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    Result := Ini.ReadInteger(Section, Line, 0);
  finally
    Ini.Free;
  end;
end;
function IniReadString(const FileName, Section, Line: string): string;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    Result := Ini.ReadString(Section, Line, '');
  finally
    Ini.Free;
  end;
end;
procedure IniWriteBool(const FileName, Section, Line: string; Value: Boolean);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    Ini.WriteBool(Section, Line, Value);
  finally
    Ini.Free;
  end;
end;
procedure IniWriteInteger(const FileName, Section, Line: string; Value: Integer);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    Ini.WriteInteger(Section, Line, Value);
  finally
    Ini.Free;
  end;
end;
procedure IniWriteString(const FileName, Section, Line, Value: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FileName);
  try
    Ini.WriteString(Section, Line, Value);
  finally
    Ini.Free;
  end;
end;
// Initialization (ini) Files helper routines
const
  ItemCountName = 'Count';
procedure IniReadStrings(IniFile: TCustomIniFile; const Section: string; Strings: TStrings);
var
  Count, I: Integer;
begin
  with IniFile do
  begin
    Strings.BeginUpdate;
    try
      Strings.Clear;
      Count := ReadInteger(Section, ItemCountName, 0);
      for I := 0 to Count - 1 do
        Strings.Add(ReadString(Section, IntToStr(I), ''));
    finally
      Strings.EndUpdate;
    end;
  end;
end;
procedure IniWriteStrings(IniFile: TCustomIniFile; const Section: string; Strings: TStrings);
var
  I: Integer;
begin
  with IniFile do
  begin
    EraseSection(Section);
    WriteInteger(Section, ItemCountName, Strings.Count);
    for I := 0 to Strings.Count - 1 do
      WriteString(Section, IntToStr(I), Strings[I]);
  end;
end;
{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);
finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}
end.
