program WebpascalFMXMobile;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipalFMX in 'uPrincipalFMX.pas' {Form9},
  uDmServiceFMX in 'uDmServiceFMX.pas' {ServerMethodDM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm9, Form9);
  Application.CreateForm(TServerMethodDM, ServerMethodDM);
  Application.Run;
end.
