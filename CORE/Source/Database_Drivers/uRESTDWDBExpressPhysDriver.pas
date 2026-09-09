Unit uRESTDWDBExpressPhysDriver;

{$I uRESTDW.inc}

Interface

Uses
{$IFDEF DELPHIXE2UP}
 System.Classes,
{$ELSE}
 Classes,
{$ENDIF}
 uRESTDWDBExpressPhysLink;

Procedure Register;

Implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - PhysLink', [TRESTDWDBExpressPhysLink]);
End;
End.
