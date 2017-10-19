{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  108528: Main.pas 
{
{   Rev 1.0    14/08/2004 12:29:18  ANeillans
{ Initial Checkin
}
{
  Demo Name:  SMTP Server
  Created By: Andy Neillans
          On: 27/10/2002

  Notes:
   Demonstration of SMTPServer (by use of comments only!!)
   Read the RFC to understand how to store and manage server data, and
   therefore be able to use this component effectivly.

  Version History:
    14th Aug 04:  Andy Neillans
                  Updated for Indy 10, rewritten IdSMTPServer
    12th Sept 03: Andy Neillans
                  Cleanup. Added some basic syntax checking for example.

  Tested:
   Indy 10:
     D5:     Untested
     D6:     Untested
     D7:     Untested
}
unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IdBaseComponent, IdComponent, IdTCPServer, IdSMTPServer, StdCtrls,
  IdMessage, IdEMailAddress, IdCmdTCPServer, IdExplicitTLSClientServerBase;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ToLabel: TLabel;
    FromLabel: TLabel;
    SubjectLabel: TLabel;
    IdSMTPServer1: TIdSMTPServer;
    btnServerOn: TButton;
    btnServerOff: TButton;
    procedure btnServerOnClick(Sender: TObject);
    procedure btnServerOffClick(Sender: TObject);
    procedure IdSMTPServer1MsgReceive(ASender: TIdSMTPServerContext;
      AMsg: TStream; var LAction: TIdDataReply);
    procedure IdSMTPServer1RcptTo(ASender: TIdSMTPServerContext;
      const AAddress: String; var VAction: TIdRCPToReply;
      var VForward: String);
    procedure IdSMTPServer1UserLogin(ASender: TIdSMTPServerContext;
      const AUsername, APassword: String; var VAuthenticated: Boolean);
    procedure IdSMTPServer1MailFrom(ASender: TIdSMTPServerContext;
      const AAddress: String; var VAction: TIdMailFromReply);
    procedure IdSMTPServer1Received(ASender: TIdSMTPServerContext;
      AReceived: String);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.btnServerOnClick(Sender: TObject);
begin
 btnServerOn.Enabled := False;
 btnServerOff.Enabled := True;
 IdSMTPServer1.active := true;
end;

procedure TForm1.btnServerOffClick(Sender: TObject);
begin
 btnServerOn.Enabled := True;
 btnServerOff.Enabled := False;
 IdSMTPServer1.active := false;
end;

procedure TForm1.IdSMTPServer1MsgReceive(ASender: TIdSMTPServerContext;
  AMsg: TStream; var LAction: TIdDataReply);
var
 LMsg : TIdMessage;
 LStream : TFileStream;
begin
// When a message is received by the server, this event fires.
// The message data is made available in the AMsg : TStream.
// In this example, we will save it to a temporary file, and the load it using
// IdMessage and parse some header elements.

LStream := TFileStream.Create(ExtractFilePath(Application.exename) + 'test.eml', fmCreate);
Try
 LStream.CopyFrom(AMsg, 0);
Finally
 FreeAndNil(LStream);
End;

LMsg := TIdMessage.Create;
Try
 LMsg.LoadFromFile(ExtractFilePath(Application.exename) + 'test.eml', False);
 ToLabel.Caption := LMsg.Recipients.EMailAddresses;
 FromLabel.Caption := LMsg.From.Text;
 SubjectLabel.Caption := LMsg.Subject;
 Memo1.Lines := LMsg.Body;
Finally
 FreeAndNil(LMsg);
End;

end;

procedure TForm1.IdSMTPServer1RcptTo(ASender: TIdSMTPServerContext;
  const AAddress: String; var VAction: TIdRCPToReply;
  var VForward: String);
begin
 // Here we are testing the RCPT TO lines sent to the server.
 // These commands denote where the e-mail should be sent.
 // RCPT To address comes in via AAddress. VAction sets the return action to the server.

 // Here, you would normally do:
 // Check if the user has relay rights, if the e-mail address is not local
 // If the e-mail domain is local, does the address exist?

 // The following actions can be returned to the server:
 {
    rAddressOk, //address is okay
    rRelayDenied, //we do not relay for third-parties
    rInvalid, //invalid address
    rWillForward, //not local - we will forward
    rNoForward, //not local - will not forward - please use
    rTooManyAddresses, //too many addresses
    rDisabledPerm, //disabled permentantly - not accepting E-Mail
    rDisabledTemp //disabled temporarily - not accepting E-Mail
 }

 // For now, we will just always allow the rcpt address.
 VAction := rAddressOk;
end;

procedure TForm1.IdSMTPServer1UserLogin(ASender: TIdSMTPServerContext;
  const AUsername, APassword: String; var VAuthenticated: Boolean);
begin
 // This event is fired if a user attempts to login to the server
 // Normally used to grant relay access to specific users etc.
 VAuthenticated := True;
end;

procedure TForm1.IdSMTPServer1MailFrom(ASender: TIdSMTPServerContext;
  const AAddress: String; var VAction: TIdMailFromReply);
begin
 // Here we are testing the MAIL FROM line sent to the server.
 // MAIL FROM address comes in via AAddress. VAction sets the return action to the server.

 // The following actions can be returned to the server:
 { mAccept, mReject }

 // For now, we will just always allow the mail from address.
 VAction := mAccept;
end;

procedure TForm1.IdSMTPServer1Received(ASender: TIdSMTPServerContext;
  AReceived: String);
begin
 // This is a new event in the rewrite of IdSMTPServer for Indy 10.
 // It lets you control the Received: header that is added to the e-mail.
 // If you do not want a Received here to be added, set AReceived := '';
 // Formatting 'keys' are available in the received header -- please check
 // the IdSMTPServer source for more detail.
end;

end.
