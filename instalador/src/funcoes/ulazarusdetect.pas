unit ulazarusdetect;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TLazarusFinder }

  TLazarusFinder = class
  private
    function Comparar(str, tipo: ansistring): boolean;
  public
    procedure ListaArquivos(pasta, ext: string; var str: TStringList);
  end;

implementation

{ TLazarusFinder }

function TLazarusFinder.Comparar(str, tipo: ansistring): boolean;
begin
  Result := (tipo = 'A') and (SameText(ExtractFileName(str), 'environmentoptions.xml'));
end;

procedure TLazarusFinder.ListaArquivos(pasta, ext: string; var str: TStringList);
var
  F: TSearchRec;
  Ret: integer;
  bcomp: boolean;
  recursivo: boolean;
  onlyFolder: boolean;
begin
  recursivo := True;

  pasta := IncludeTrailingPathDelimiter(pasta);

  if ext = '' then
    ext := '*.*';

  onlyFolder := False;
  Ret := FindFirstUTF8(pasta + ext, faAnyFile, F);
  if Ret <> 0 then
  begin
    FindCloseUTF8(F);
    Ret := FindFirstUTF8(pasta + '*', faAnyFile, F);
    onlyFolder := True;
  end;

  try
    while Ret = 0 do
    begin
      if (F.Attr and faDirectory > 0) then
      begin
        if (F.Name <> '.') and (F.Name <> '..') and (F.Name <> '') and (recursivo) then
          listaArquivos(pasta + F.Name, ext, str);
      end
      else if (F.Name <> '') and (not onlyFolder) then
      begin
        bcomp := comparar(pasta + F.Name, 'A');

        if bcomp then
          str.Add(pasta + F.Name);
      end;
      Ret := FindNextUTF8(F);
    end;
  finally
    FindCloseUTF8(F);
  end;

end;

end.
