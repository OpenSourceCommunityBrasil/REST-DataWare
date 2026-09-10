Unit RESTDWNativeLinkSQLDB;

{$warn 5023 off}

Interface

Uses
 uRESTDWNativeLinkSQLDB, LazarusPackageIntf;

Implementation

Procedure Register;
Begin
 RegisterUnit('uRESTDWNativeLinkSQLDB', @uRESTDWNativeLinkSQLDB.Register);
End;

Initialization

 RegisterPackage('RESTDWNativeLinkSQLDB', @Register);
End.
