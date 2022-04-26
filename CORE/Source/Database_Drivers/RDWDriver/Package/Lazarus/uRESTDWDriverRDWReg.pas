unit uRESTDWDriverRDWReg;

interface

uses
 {$IFNDEF UNIX}Windows,
 {$ELSE}Lcl,{$ENDIF}LResources, Classes, propedits, uRESTDWDriverRDW;

Procedure Register;

implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWDriverRDW]);
End;

initialization
{$I restdwdriverrdw.lrs}

end.
