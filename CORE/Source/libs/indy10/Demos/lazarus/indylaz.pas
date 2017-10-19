{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit indylaz;

interface

uses
  IdAbout, IdAboutVCL, IdAntiFreeze, IdCoreDsnRegister, IdDsnBaseCmpEdt, 
  IdDsnCoreResourceStrings, IdDsnPropEdBinding, IdDsnPropEdBindingVCL, 
  IdDsnRegister, IdDsnResourceStrings, IdDsnSASLListEditor, 
  IdDsnSASLListEditorForm, IdDsnSASLListEditorFormVCL, IdRegister, 
  IdRegisterCore, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('IdCoreDsnRegister', @IdCoreDsnRegister.Register);
  RegisterUnit('IdDsnRegister', @IdDsnRegister.Register);
  RegisterUnit('IdRegister', @IdRegister.Register);
  RegisterUnit('IdRegisterCore', @IdRegisterCore.Register);
end;

initialization
  RegisterPackage('indylaz', @Register);
end.
