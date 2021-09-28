Library mod_restdataware_core;

{$mode objfpc}{$H+}

Uses
{$ifdef unix}
  cthreads,
{$endif}
 httpd,
 custapache,
 fpApache,
 dmdwcgiserver,
 uDmService;

Const
 ModuleName  = 'mod_restdataware';
 HandlerName = ModuleName;

Var
 DefaultModule : Module;
 {$ifdef unix}
  Public name ModuleName;
 {$endif unix}
 {$ifdef windows}
  Exports defaultmodule name HandlerName;
 {$endif windows}

Begin
 Application.Title         := 'REST Dataware CORE - Apache Module';
 Application.ModuleName    := ModuleName;
 Application.HandlerName   := HandlerName;
 Application.SetModuleRecord(DefaultModule);
 Application.Initialize;
End.

