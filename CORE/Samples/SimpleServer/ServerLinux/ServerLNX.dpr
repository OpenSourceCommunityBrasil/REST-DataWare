program ServerLNX;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Classes,
  System.Types,
  URESTDWBase,
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas',
  uDmService in 'uDmService.pas' {ServerMethodDM: TServerMethodDataModule};

var
RESTServicePooler1: TRESTServicePooler;

Function StartServer : boolean;
Begin
  result:=false;
 if not Assigned(RESTServicePooler1) then
  Begin
  try
    RESTServicePooler1:= TRESTServicePooler.create(nil);
    RESTServicePooler1.ServerParams.UserName := 'testserver';
    RESTServicePooler1.ServerParams.Password := 'testserver';
    RESTServicePooler1.serviceport:=8082;
    RESTServicePooler1.EncodeStrings:=true;
    RESTServicePooler1.ServerMethodClass := TServerMethodDM;
    RESTServicePooler1.active:=true;
    RESTServicePooler1.DataCompression :=true;
    result:=true;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  End;


End;


Function RunServer:boolean;
var s: string;
Begin
result:=falsE;
  Writeln('start - iniciar, stop - para para o server');
  StartServer;
  while true do
  Begin
    readln(s);
    s:=LowerCase(s);
    if (s) = 'start' then
    Begin
     if StartServer then
     Writeln('Server iniciado');
    End
   else  if (s)= 'stop' then
    Begin
      RESTServicePooler1.Active:=falsE;
      freeandnil(RESTServicePooler1);
      break;
    End
    else
    begin
      Writeln('Comando Invalido');
      Write('start - iniciar, stop - para para o server');
    end

  End;
  result:=true;
End;

begin
  try
    RunServer;
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
