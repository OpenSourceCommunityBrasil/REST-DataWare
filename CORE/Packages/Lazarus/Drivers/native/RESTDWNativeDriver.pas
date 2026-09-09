{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

Unit RESTDWNativeDriver;

{$warn 5023 off : no warning about unused units}
Interface

Uses
  uRESTDWNativeDriver, uRESTDWNativeDriverRegLazarus, LazarusPackageIntf;

Implementation

Procedure Register;
Begin
  RegisterUnit('uRESTDWNativeDriver', @uRESTDWNativeDriver.Register);
  RegisterUnit('uRESTDWNativeDriverRegLazarus', @uRESTDWNativeDriverRegLazarus.Register);
End;

Initialization
  RegisterPackage('RESTDWNativeDriver', @Register);
End.
