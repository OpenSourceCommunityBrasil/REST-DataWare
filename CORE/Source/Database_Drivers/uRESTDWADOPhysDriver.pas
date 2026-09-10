Unit uRESTDWADOPhysDriver;

{$I uRESTDW.inc}

Interface

Uses
{$IFDEF DELPHIXE2UP}
 System.Classes,
{$ELSE}
 Classes,
{$ENDIF}
 uRESTDWADOPhysLink;

Procedure Register;

Implementation

Procedure Register;
Begin
 RegisterComponents('REST Dataware - PhysLink', [TRESTDWADOPhysLink]);
End;
End.
