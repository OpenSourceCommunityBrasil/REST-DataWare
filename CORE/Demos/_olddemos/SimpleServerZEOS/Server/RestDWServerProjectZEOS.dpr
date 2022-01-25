program RestDWServerProjectZEOS;
{$APPTYPE GUI}
//https://stackoverflow.com/questions/19124701/get-image-using-jquery-ajax-and-decode-it-to-base64
//https://stackoverflow.com/questions/42214527/posting-a-base64-encoded-pdf-file-with-ajax
uses
  Vcl.Forms,
  RestDWServerFormU in 'RestDWServerFormU.pas' {RestDWForm},
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas' {ServerMethods1: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TRestDWForm, RestDWForm);
  Application.Run;
end.
