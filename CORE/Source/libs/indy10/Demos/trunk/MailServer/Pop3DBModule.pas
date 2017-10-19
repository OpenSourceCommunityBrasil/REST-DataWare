unit Pop3DBModule;
{ This unit is performing all the internal data housekeeping:
  Mailboxes
  Accounts
  Passwords
  Email Adresses
  Most are kept in Stringlists, the Objects containing some additional data.
  You can easily extend this using a small database (Firebird recommended)
  to have the data for the users stored in a convenient way.

  (c)2005
  Jörg Meier (Bob)
  briefe@jmeiersoftware.de
}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;




//  Some Globals
Const
  MBoxFolder      = 'MailBoxes\';    // Foldername for storing Mailboxes
  SentArchive     = 'SentMails\';
Type
  TPop3DBMod = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
    fMailboxList  : tStringList;
    fEmailAddrs   : tStringList;
    fSendQueue    : tThreadList;
    Function  AddUser(Const AUserName,APassword,AMBoxName:String):Boolean;
    Function  AddEmailAccount(Const AEmailAddress,AUserName:String):Boolean;
    Procedure FillUserList;
  public
    { Public-Deklarationen }
    Property  MailBoxList : tStringList read fMailBoxList;
    Property  EmailAddrs  : tStringList read fEmailAddrs;
    Property  SendQueue   : tThreadList  read fSendQueue;
    Function  GetSendMailCount:Integer;
    Function  GetMailNumber:Cardinal;
    Function  GetSendFileName(Const AMBox:String):String;
    Function  GetRecvFileName(const AMBox: String): String;
    Procedure EnterToSendMail(Const AFileName:String);
    Function  GetMBoxName(Const AUser:String):String;
  end;

var
  Pop3DBMod: TPop3DBMod;

Function GetValidMailBoxName(Const AUserName,APassword:String):String;
Function GetMailBoxList:tStringList;

implementation
Uses IdGlobal;
{$R *.DFM}
Type
    tUserObject = Class(tObject)
       PassWord     : String;
       MBoxName     : String;
       Constructor Create(Const APassword,AMBoxName:String);
    end;

{ if you use a database, this can be used to sequence accesses to the DB which
  normally wouldn't be thread-save
}
Var DBSection : tIdCriticalSection;
{ TPop3DBMod }

function GetValidMailBoxName(const AUserName,APassword: String): String;
{
         A user is logging in. He gave us a Username together with a password.
         Check for a legal combination and return the path to the mailfolder
         if it was NOT successful, return an epty string instead.
}
Var      Nr     : Integer;
         This   : tUserObject;
begin
     With Pop3DBMod do
     begin
          Result := ''; // assume failure
          Nr := fMailBoxList.IndexOf(AUserName);
          If Nr < 0 then Exit; // User is unknown
          This := tUserObject(fMailBoxList.Objects[Nr]);
          If This.PassWord = APassword then Result := This.MBoxName
          Else                              Result := '';
     end;
end;

Function GetMailBoxList:tStringList;
{
     Return a list of all known local mailboxes
}

Var      ii    : Integer;
Begin
     Result := tStringlist.Create;
     Result.Duplicates := DupIgnore;
     With Pop3DBMod do
     begin
          for ii := 0 to fMailBoxList.Count-1 do
          begin
               Result.Add(tUserObject(fMailboxlist.Objects[ii]).MBoxName);
          end;
     end;
end;

procedure TPop3DBMod.DataModuleCreate(Sender: TObject);
begin
     DBSection    := tIdCriticalSection.Create;

     fMailBoxList := tStringList.Create;
     fMailboxlist.Duplicates := DupError;
     fMailboxlist.Sorted := True;

     fEmailAddrs  := tStringlist.Create;
     fEmailAddrs.Duplicates := DupError;
     fEmailAddrs.Sorted := True;

     FillUserList;
     fSendQueue    := tThreadList.Create;
end;

procedure TPop3DBMod.DataModuleDestroy(Sender: TObject);
Var       ii    : Integer;
          MyUsr : tUserObject;
begin
     // Clear MailBoxList
     For ii := 0 to fMailBoxList.Count-1 do
     begin
          MyUsr := tUserObject(fMailBoxList.Objects[ii]);
          FreeAndNil(MyUsr);
          fMailBoxList.Objects[ii] := nil;
     end;
     FreeAndNil(fMailBoxList);
     FreeAndNil(FEmailAddrs);
     FreeAndNil(DBSection);
end;

function TPop3DBMod.AddUser(const AUserName, APassword,AMBoxName: String): Boolean;
{ Add a user to the local system
  AUsername : is the account
  APassword : plain-text password
  AMBoxname : is the folder where this user's mail will be stored.
              actually, this folder is created below the folder where
              this program runs.
  All this information is NOT saved, it is kept in mem as long as the server lives.

}
Var      ThisUser : tUserObject;
begin
     Result := True; // assume all goes well
     try
        ThisUser := tUserObject.Create(APassword,AMBoxName);
        fMailBoxList.AddObject(AUserName,ThisUser);
     Except
           Result := False;
     end;
end;

function TPop3DBMod.AddEmailAccount(const AEmailAddress, AUserName: String): Boolean;
Var      Nr     : Integer;
begin
     Result := False; // Assume Error
     Try
        Nr := MailBoxList.IndexOf(AUserName);
        If Nr < 0 then exit;  // Not found

        EmailAddrs.AddObject(AEmailAddress,Pointer(Nr));
        Result := True;   // Success;
     except
           Exit;
     end;
end;

procedure TPop3DBMod.FillUserList;
{
  Here the Users are fed into the system. Hard coded only, but it's a demo.
  You should again use a database and read out every information.
}
begin
     try
        DBSection.Enter;
{ first the user in the system }
//      AddUser(AccountName,Password,Foldername);
        AddUser('Thats.MySelf','Top_Secret','MyMailBox');
{ then the external email-address and the Username (for delivering inbound mail)}
//      AddEmail(Email-Address,Username)
        AddEmailAccount('maildemo@nerdshack.com','Thats.MySelf');
     Finally
            DBSection.Leave;
     end;
end;

function TPop3DBMod.GetMailNumber: Cardinal;
{ This routine (a pretty good database-candidate as well) generates
  a unique ascending number
}
Const   NumberFName = 'MailNum.Dat';
Var     NumberFile  : File of Cardinal;
        FName       : String;
begin
     DBSection.Enter;
     Try
        FName := ExtractFilePath(Application.ExeName)+NumberFName;
        AssignFile(NumberFile,FName);
        If FileExists(FName) Then
        begin
             Reset(NumberFile);
             Read(NumberFile,Result);
             Inc(Result);
             Seek(NumberFile,0);
        end
        else begin
             Rewrite(NumberFile);
             Result := 1; // Start with one
        End;
        Write(NumberFile,Result);
     Finally
            CloseFile(NumberFile);
            DBSection.Leave;
     end;
end;

function TPop3DBMod.GetSendFileName(const AMBox: String): String;
// Generate FileName for a mail to send
begin
     Result := AMBox + '\'
            +  Format('M%.8d.SNT',[GetMailNumber]);
end;

function TPop3DBMod.GetRecvFileName(const AMBox: String): String;
// Generate FileName for a mail to send
begin
     Result := AMBox + '\'
            +  Format('M%.8d.RAW',[GetMailNumber]);
end;

function TPop3DBMod.GetSendMailCount: Integer;
Var      MyList : tList;
begin
     MyList := SendQueue.LockList;
     Result := MyList.Count;
     SendQueue.UnlockList;
end;

procedure TPop3DBMod.EnterToSendMail(const AFileName: String);
{
   Put the Filename to send into our Sendqueue. This is a thread-safe
   list, so we can put in, send and delete simultaneously.
}
begin
     SendQueue.Add(StrNew(PChar(AFileName)));
end;

function TPop3DBMod.GetMBoxName(const AUser: String): String;
Var      Nr  : Integer;
begin
     Result := '';
     Nr := MailBoxList.IndexOf(AUser);
     If Nr < 0 then exit; // Not found, could rise an Exception as well
     Result := tUserObject(MailBoxList.Objects[Nr]).MBoxName;
end;

{ tUserObject }

constructor tUserObject.Create(const APassword,AMBoxName: String);
begin
     Self.PassWord := APassWord;
     Self.MBoxName := AMBoxName;
end;

end.
