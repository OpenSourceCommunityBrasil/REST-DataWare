{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  23210: ApplicationConfiguration.pas 
{
{   Rev 1.0    09/11/2003 3:19:50 PM  Jeremy Darling
{ Added to project for a place to store application configuration information.
}
unit ApplicationConfiguration;

interface

uses
  Graphics,
  IniFiles,
  SysUtils,
  Classes;

type
  TLogColors=class(TStringList)
  private
    function GetColors(shortname: string): TColor;
    procedure SetColors(shortname: string; const Value: TColor);
  public
    property Colors[shortname:string]:TColor read GetColors write SetColors;
  end;

  TApplicationConfig = class
  private
    FLogColors: TLogColors;
  public
    property LogColors : TLogColors read FLogColors;
    procedure LoadFromIni(Ini : TIniFile);
    procedure SaveToIni(Ini : TIniFile);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TApplicationConfig }

constructor TApplicationConfig.Create;
begin
  inherited;

  FLogColors := TLogColors.Create;
end;

destructor TApplicationConfig.Destroy;
begin
  FLogColors.Free;

  inherited;
end;

procedure TApplicationConfig.LoadFromIni(Ini: TIniFile);
var
  i,
  v : Integer;
  n : String;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    Ini.ReadSection('LOGCOLORS', sl);
    for i := 0 to sl.Count -1 do
      begin
        n := sl[i];
        v := Ini.ReadInteger('LOGCOLORS', n, Integer(LogColors.Colors[n]));
        LogColors[i] := n;
        LogColors.Colors[n] := TColor(v);
      end;
  finally
    sl.Free;
  end;
end;

procedure TApplicationConfig.SaveToIni(Ini: TIniFile);
var
  i : Integer;
begin
  for i := 0 to LogColors.Count -1 do
    begin
      Ini.WriteInteger('LOGCOLORS', LogColors[i], Integer(LogColors.Colors[LogColors[i]]));
    end;
end;

{ TLogColors }

function TLogColors.GetColors(shortname: string): TColor;
begin
  if indexof(shortname) > -1 then
    result := TColor(Pointer(Objects[indexof(shortname)]))
  else
    result := clBlack;
end;

procedure TLogColors.SetColors(shortname: string; const Value: TColor);
begin
  if indexof(shortname) = -1 then
    AddObject(shortname, pointer(value))
  else
    Objects[indexof(shortname)] := pointer(value);
end;

end.
 
