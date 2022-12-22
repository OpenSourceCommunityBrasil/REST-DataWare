unit FireDAC.Phys.RDWMeta;

interface

uses
  FireDAC.Phys.Meta, FireDAC.Stan.Intf, FireDAC.DatS, Classes, SysUtils,
  FireDAC.Phys.Intf, FireDAC.Phys, uRESTDWBasicDB, FireDAC.Phys.SQLGenerator;

type
  TFDPhysRDWMetadata = class (TFDPhysConnectionMetadata)

  end;

  TFDPhysRDWCommandGenerator = class(TFDPhysCommandGenerator)

  end;



implementation


end.
