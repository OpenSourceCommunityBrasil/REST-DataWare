unit uZenviaSend;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdMultipartFormData, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, System.NetEncoding,
  uDWAbout, uDWResponseTranslator;

Const
 vZenviaSend = ' {"sendSmsRequest": {' +
               '"from": "%s",' + //Meu numero
               '"to": "%s",' +  //Para quem
               '"schedule": "%s",'+ //"2016-12-05T09:18:00"
               '"msg": "%s",'+ //"Minha menssagem"
               '"callbackOption": "NONE",'+
               '"id": "%s",'+  //"idteste"
               '"aggregateId": "%s",'+ //"1111"
               '"flashSms": false}}';

type
  TForm1 = class(TForm)
    bSendSMS: TButton;
    eUserName: TEdit;
    ePassword: TEdit;
    eRemetente: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    eDestinatario: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    eID: TEdit;
    Label6: TLabel;
    eAggregateId: TEdit;
    Label7: TLabel;
    mMSG: TEdit;
    DWClientREST1: TDWClientREST;
    Memo1: TMemo;
    procedure bSendSMSClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.bSendSMSClick(Sender: TObject);
Var
 SendParams    : TStringList;
 aStringStream : TStringStream;
begin
 SendParams    := TStringList.Create;
 aStringStream := TStringStream.Create('', TEncoding.UTF8);
 Memo1.Lines.Clear;
 Try
  SendParams.Add(Format(vZenviaSend, [eRemetente.Text,
                                      eDestinatario.Text,
                                      FormatDateTime('yyyy-mm-dd', Now) + 'T' + FormatDateTime('hh:mm:ss', Now),
                                      mMSG.Text,
                                      eID.Text,
                                      eAggregateId.Text]));
  DWClientREST1.AuthOptions.UserName := eUserName.Text;
  DWClientREST1.AuthOptions.Password := ePassword.Text;;
  DWClientREST1.Post('https://api-rest.zenvia.com/services/send-sms/',
                     SendParams, aStringStream, False, True);
 Finally
  SendParams.Free;
  If aStringStream.Size > 0 Then
   Memo1.Lines.Add(aStringStream.datastring);
  aStringStream.Free;
 End;
end;

end.
