unit MBoxDataModule;
{ this was originally the Indy Pop3Server demo, but I filled
  the skeleton with a little bit of flesh...

    2005
  Jörg Meier (Bob)
  emil@jmeiersoftware.de

}
{ $Log:  22918: MainFrm.pas 
{
{   Rev 1.2    25/10/2004 22:49:28  ANeillans    Version: 9.0.17
{ Verified
}
{
{   Rev 1.1    12/09/2003 21:18:36  ANeillans
{ Verified with Indy 9 on D7.
{ Added instruction memo.
}
{
{   Rev 1.0    10/09/2003 20:40:48  ANeillans
{ Initial Import (Used updated version - not original 9 Demo)
}
{
  Demo Name:  POP3 Server
  Created By: Siamak Sarmady
          On: 27/10/2002

  Notes:
   Demonstrates POP3 server events (by way of comment - NOT functional!)

  Version History:
   31st Dec 04:  Andy Neillans
                 Fixed for current Indy 10, and migrated to support Delphi 2005.
   12th Sept 03: Andy Neillans
                 Added the comments memo on the form for information.
   8th July 03:  Andy Neillans
                 Fixed the demo for I9.014
   Unknown:      Allen O'Neill
                 Added in some missing command handler comments

  Tested:
   31st Dec 04:  D2005: Andy Neillans
}

{@$Define WithDatabase} // to use alternate modules for the userauthentication

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IdPOP3Server, IdSMTPServer, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, IdCmdTCPServer, idthread,
  IdExplicitTLSClientServerBase, IdCommandHandlers, IDContext,
  IdMessage, IdGlobal, IDSys, IdPOP3, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTPBase, IdSMTP, RAS, IdAntiFreezeBase, IdAntiFreeze;

type
  TMBoxDataMod = class(TDataModule)
    InternalPOP3: TIdPOP3Server;
    InternalSMTP: TIdSMTPServer;
    ExternalSMTP: TIdSMTP;
    ExternalPOP3: TIdPOP3;
    IdAntiFreeze1: TIdAntiFreeze;
    IdPOP3Server1: TIdPOP3Server;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
//    procedure InternalPOP3DELE(ASender: TIdCommand; AMessageNum: Integer);
    procedure InternalPOP3LIST(ASender: TIdCommand; AMessageNum: Integer);
    procedure InternalPOP3QUIT(ASender: TIdCommand);
    procedure InternalPOP3RETR(ASender: TIdCommand; AMessageNum: Integer);
    procedure InternalPOP3RSET(ASender: TIdCommand);
    procedure InternalPOP3TOP(ASender: TIdCommand; AMessageNum,
      ANumLines: Integer);
    procedure InternalPOP3UIDL(ASender: TIdCommand; AMessageNum: Integer);
    procedure InternalPOP3Connect(AContext: TIdContext);
    procedure InternalPOP3Exception(AContext: TIdContext;
      AException: Exception);
    procedure InternalPOP3Disconnect(AContext: TIdContext);
    procedure InternalPOP3BeforeCommandHandler(ASender: TIdCmdTCPServer;
      var AData: String; AContext: TIdContext);
    procedure InternalPOP3Status(ASender: TObject;
      const AStatus: TIdStatus; const AStatusText: String);
    procedure InternalPOP3APOP(ASender: TIdCommand; AMailboxID: String;
      var VUsersPassword: String);
    procedure InternalSMTPUserLogin(ASender: TIdSMTPServerContext;
      const AUsername, APassword: String; var VAuthenticated: Boolean);
    procedure InternalSMTPConnect(AContext: TIdContext);
    procedure InternalSMTPDisconnect(AContext: TIdContext);
    procedure InternalSMTPException(AContext: TIdContext;
      AException: Exception);
    procedure InternalSMTPExecute(AContext: TIdContext);
    procedure InternalSMTPListenException(AThread: TIdListenerThread;
      AException: Exception);
    procedure InternalSMTPMailFrom(ASender: TIdSMTPServerContext;
      const AAddress: String; var VAction: TIdMailFromReply);
    procedure InternalSMTPRcptTo(ASender: TIdSMTPServerContext;
      const AAddress: String; var VAction: TIdRCPToReply;
      var VForward: String);
//    procedure InternalSMTPReceived(ASender: TIdSMTPServerContext;
//      AReceived: String);
    procedure InternalSMTPMsgReceive(ASender: TIdSMTPServerContext;
      AMsg: TStream; var LAction: TIdDataReply);
    procedure InternalSMTPStatus(ASender: TObject;
      const AStatus: TIdStatus; const AStatusText: String);
    procedure InternalPOP3Delete(aCmd: TIdCommand; AMsgNo: Integer);
    procedure InternalPOP3Retrieve(aCmd: TIdCommand; AMsgNo: Integer);
    procedure InternalPOP3Stat(aCmd: TIdCommand; out oCount,
      oSize: Integer);
    procedure InternalSMTPReceived(ASender: TIdSMTPServerContext;
      var AReceived: String);
    procedure InternalSMTPAfterCommandHandler(ASender: TIdCmdTCPServer;
      AContext: TIdContext);
    procedure InternalSMTPBeforeCommandHandler(ASender: TIdCmdTCPServer;
      var AData: String; AContext: TIdContext);
    procedure InternalSMTPBeforeConnect(AContext: TIdContext);
    procedure InternalSMTPBeforeListenerRun(AThread: TIdThread);
    procedure InternalPOP3BeforeConnect(AContext: TIdContext);
    procedure InternalPOP3BeforeListenerRun(AThread: TIdThread);
    procedure InternalPOP3Execute(AContext: TIdContext);
    procedure InternalPOP3ListenException(AThread: TIdListenerThread;
      AException: Exception);
    procedure InternalPOP3Reset(aCmd: TIdCommand);
    procedure InternalPOP3CheckUser(aContext: TIdContext;
      aServerContext: TIdPOP3ServerContext);
  private
    { Private-Deklarationen }
    fMBoxRoot      : String;
    fMailIDs       : tStringList; // list of downloaded mails not deleted on Server
    fDoHangup      : Boolean; // for dial-up connections
    fNewConnection : Boolean; // ditto
    RasConn        : tRasConnection;
    Procedure InitMailBoxes;
    Procedure DebugOutput(Const Command:String;ASender:tIDCommand);
  public
    { Public-Deklarationen }
    Procedure RunServer;
    Procedure StopServer;
    Procedure SetupExternals;
    Procedure GetSendMail;
    Function  GoOnline(Const Provider:String):Boolean;
    Property  MBoxRoot : String read FMBoxRoot;
    Procedure GetMailInfos(var MailList:tstringList);
    Procedure GetAllMail(MailList:tStringList;Const MBoxName:String='');
    Procedure SendAllMail;
    Property  MailIDs:tstringlist read fMailIDs;
  end;

var
  MBoxDataMod: TMBoxDataMod;

implementation
Uses FileCtrl, Pop3DBModule, SyncObjs, Pop3MainUnit, ProviderUnit;
{$R *.DFM}

Type  tUserData = Class(tObject)
           MailList  : tStringList;
           UsrName   : String;
           MBoxPath  : String;
           MBoxSize  : Integer;
           Constructor Create(Const AUsrName:String);
           Destructor  Destroy;Override;
           Procedure FillMailList;
      End;

      tMailData = Class(tObject)
           FName        : String;
           DoDelete     : Boolean;
           DoSend       : Boolean;
           MailNumber   : Integer;
           MailSize     : Integer;
           Constructor Create(Const AFileName:String);
           Destructor  Destroy;Override;
      End;

// This object is used to specify the received mail from an Internet-Mailserver
      tServerMail = Class(tObject)
           Mailsentby   : String;    // From
           MailSentto   : tStringList;    // To
           MailSubject  : String;    // Ref
           MailSize     : Integer;   // Bytes
           MsgID        : String;    // Unique MessageID (Set by the Mailserver)
      public
          Constructor create;
          Destructor  destroy; Override;
      end;

Var   DBSection  : tCriticalSection;
      LogSection : tCriticalSection;

{*************************************************************************}
{*                                                                       *}
{*    Some File-Routines from my FileUtils Unit needed here              *}
{*    (slightly modified to be used with Indy                            *}
{*                                                                       *}
{*************************************************************************}
Type   FileFunction = Function(Const Filename:String):Boolean;

function GetFileSize(const FileName: string): LongInt;
var
  SearchRec: TSearchRec;
begin
  if FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec) = 0 then
  begin
       Result := SearchRec.Size;
       With Searchrec.FindData do If (nFileSizeHigh <> 0) or ((nFileSizeLow and $80000000) <> 0) then
          Result := -1; // Indicate Size Overflow
  end
  else Result := -1;
  SysUtils.FindClose(Searchrec);
end;

function GetFileSize64(const FileName: string): Int64;
var
  SearchRec: TSearchRec;
begin
  if FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec) = 0 then
    Result := SearchRec.FindData.nFileSizeHigh shl 32 or SearchRec.FindData.nFileSizeLow
  else Result := -1;
  SysUtils.FindClose(Searchrec);
end;

Function GetFilesInDirEX(InitDir:String;Var DirList : tStringList;Fnc:FileFunction;Const Pattern : String = '*.*'):Integer;
Var  R    : Integer;
     Sr   : tSearchrec;
Begin
     Result := 0;
     If Not assigned(Dirlist) Then Begin
        Exit;
     End;
     InitDir := Sys.IncludeTrailingPathDelimiter(InitDir);
{ Search for Files }
     R := FindFirst(InitDir+Pattern,faAnyFile{ and not faDirectory},Sr);
     While R = 0 Do Begin
           If (Sr.Attr and faDirectory) = 0 Then Begin
              If (Assigned(Fnc) And Fnc(InitDir+Sr.Name))
              Or Not Assigned(Fnc) Then Begin
                 Dirlist.AddObject(InitDir+Sr.Name,Pointer(Sr.Size));
                 Inc(Result);
                 Sleep(0);
              End;
           End;
           R := FindNext(SR);
     End;
     SysUtils.FindClose(Sr);
End;

Function GetFilesInDir(InitDir:String;Var DirList : tStringList;Const Pattern : String = '*.*'):Integer;
Begin
     Result := GetFilesInDirEx(InitDir,Dirlist,nil,Pattern);
end;

Function GetRawFileName(Const Root:String;MailInfo:tServerMail):String;
Var      ii       : Integer;
         Nr       : Integer;
         MBEntry  : Integer;
begin
{
   Here we must decide for which user the mail actually is.
   What we do need is a correspondance between Email-Address - Username
   Which is maintained in POP3DBModule (because it could be a database-Function)
   Here we will scan every recipient given in the mail to find at least one user this mail is for.
   If we do not find any, we have a problem of delivering: the mail was in our provider's mailbox,
   so apparently for us, but we cannot deliver. This is usually the place where an
   Administrator-Account is required to collect such mails and deliver them manually.
   This is a demo, so we will return the first mailbox the mail is for and not returning a List.
   (The mail could be addressed to more than one address in our server, in which case it
   should be copied to every recipient. This coul be done easily when GetRawFilename returns a StringList)
}

     For ii := 0 to  MailInfo.MailSentto.count-1 do
     begin
          Nr := Pop3DBMod.EmailAddrs.IndexOf(MailInfo.MailSentto[ii]);
          If Nr >= 0 then With POP3DBMod do
          begin
               // We found one! Get MailboxName
               // ... looks a bit complicated with one list indexing the other ...
               MBEntry := Integer(EmailAddrs.Objects[Nr]);
               Result := GetRecvFileName(Root+GetMBoxName(MailBoxList[MBEntry]));
          end;
     end;
end;

{*************************************************************************}
{*                                                                       *}
{*      tServerMail Methods                                              *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}
Constructor tServerMail.create;
begin
     Inherited create;
end;

Destructor  tServerMail.destroy;
begin
     MailsentBy  := '';
     FreeAndNil(MailSentto);
     MailSubject := '';
     MsgID       := '';
     Inherited Destroy;
end;

{*************************************************************************}
{*                                                                       *}
{*      DataModul initializations                                        *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}
Procedure DebugString(const S : String);
{
  This outputs a line in the memobox of the mainform.
  Simple? Not at all! Indy is using threads to perform the jobs

  Because a memobox (and many other VCL-Components) is not thread-save,
  this turns out to be something complicated, but there is
  a solution for this:
  We will use the Windows Message system to send the message to the
  POP3MainForm, which in turn picks up the message and does what
  we'd like to have done in the Forms WndProc.
  There are two mechanisms : Sendmessage and PostMessage. Whilst the first
  just executes the called WndProc it will run in our thread's context
  (which we do NOT want to) the second will put the message into the Queue
  and return immediately. In the context of the Forms MainThread the message
  will be picked up and the job will be done.
  This is why we have to allocate the message on the stack and free it in
  the WndProc or else our parameter 'S' is already gone when the WndProc
  executes.

  Long description, short procedure....
}
Var  MyMessage  : PChar;
Begin
     MyMessage := StrNew(PChar(S));
     PostMessage(POP3Main.Handle,LogMessageNo,LogString,Integer(MyMessage));
end;

Procedure DebugException;
Var Buffer  : String;
begin
     SetLength(Buffer,1024);
     ExceptionErrorMessage(ExceptObject,ExceptAddr,PChar(Buffer),1024);
     DebugString(Buffer);
end;

procedure TMBoxDataMod.DebugOutput(const Command: String;
  ASender: tIDCommand);
begin
     DebugString(Command);
     DebugString(ASender.Reply.FormattedReply.Text);
     DebugString(ASender.Response.Text);
end;

procedure TMBoxDataMod.DataModuleCreate(Sender: TObject);
begin
        Pop3DBMod   := tPop3DBMod.Create(Self);
        fMBoxRoot   := Sys.IncludeTrailingPathDelimiter(Sys.IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +MBoxFolder);
        DBSection   := tCriticalSection.Create;
        LogSection  := tCriticalSection.Create;
        fMailIDs    := tStringList.Create;
        fMailIDs.Sorted := True;
        fMailIDs.Duplicates := DupIgnore;
        If FileExists(ChangeFileExt(Application.ExeName,'.MList')) then
        begin
             MailIDs.LoadFromFile(ChangeFileExt(Application.ExeName,'.MList'));
        end;
        InitMailBoxes;
        RasConn := tRASConnection.Create(Self);
end;

procedure TMBoxDataMod.DataModuleDestroy(Sender: TObject);
begin
     MailIDs.SaveToFile(ChangeFileExt(Application.ExeName,'.MList'));
     if InternalPop3.Active=True then InternalPop3.Active:=False;
     FreeAndNil(RasConn);
     FreeAndNil(DBSection);
     FreeAndNil(LogSection);
end;

{*************************************************************************}
{*                                                                       *}
{*      Dial-up a provider                                               *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}
{
   Rather often I read in the newsgroups I'm in
   the question "How to connect to...".
   I have written an object which handles most of this:
   tRASConnection.
   You'll find it in the RAS-Module
}
Function  TMBoxDataMod.GoOnline(Const Provider:String):Boolean;
{
  Simply connect to internet - Server
  The connection was selected in the option-form.
  If connecting via LAN the Provider must be an empty string!!
  This is for dialling out via a Modem or ISDN
  Phone number, account and password are taken from the entries
  given in your connection information.
  ***** could somebody insert the right phrases here, please. I do not
  know the translations for the phone-entries in windows. *******
}
Const     ConnRetries = 3; // Max number of dial up retries
Var       I             : Integer;
          PrvName       : string;
          Count         : Integer;
          Connected     : Boolean;
begin
     fDoHangup      := false;
     fNewConnection := False;
     I              := 0;
     Connected      := False;
     prvName        := 'unknown';
     Count          := RasCountConnections;
     if (Count = 0) and (Provider <> '') then
     begin
//          Logmessage('connecting ...',2);
           While (I < ConnRetries) and not Connected do
           begin
                Connected := RasConn.Connectwith(Provider);
                fNewConnection := True;
                if connected then begin
                   prvName   := Provider;
                   fdoHangup := true;
//                       LogMessage('Connection with '+prvName + ' established.',2);
                end;
                Inc(I);
           end;
     end
     else { Count > 0}
     begin
         If Provider = '' then
         begin
//              LogMessage('Used a LAN connection',2);
              PrvName := 'Network';
         end
         else  {LogMessage('Used already established connection',2)};
         fDoHangup  := False;
         Count      := 1;  //That's <> 0
         Connected  := true;
     end;

     // if didn't work retry later
     Result := Connected or (Count > 0);
     If Connected then
     begin
          If fNewConnection Then
             {LogMessage('connected',2)};
     end;
end;

{*************************************************************************}
{*                                                                       *}
{*    Command responses from the Pop3 Server                             *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

// This is where the client program issues a delete command for a particular message
procedure TMBoxDataMod.InternalPOP3Delete(aCmd: TIdCommand; AMsgNo: Integer);
Var     UserData  : tUserData;
        MailData  : tMailData;
        Reason    : String;
begin
// if the message has been deleted, then return a success command as follows;
// ASender.Thread.Connection.Writeln('+OK - Message ' + IntToStr(AMessageNum) + ' Deleted')
// otherwise, if there was an error in deleting the message, or the message number
// did not exist in the first place, then return the following:
// ASender.Thread.Connection.Writeln('-ERR - Message ' + IntToStr(AMessageNum) + ' not deleted because.... [reason]')

// Usually, messages are deleted after being retrieved from pop3 server
// This is done when client sents DELE command after retrieving a message
// Client command is something like DELE 1 which means delete message 1

// Note, you should not actually delete the message at this point, just mark it as deleted.
// Deletions should be handled at the QUIT event.
     Try
        Reason := '';
//        UserData := tUserData(ASender.Context.Data);
        UserData := tUserData(ACmd.Context.Data);
        If (AMsgNo >= 1) and (AMsgNo <= UserData.MailList.Count) then
        begin
             MailData := tMailData(UserData.MailList.Objects[AMsgNo-1]);
             If Not MailData.DoDelete then
             begin
                  MailData.DoDelete := True;
                  aCmd.Reply.SetReply(OK,Format(' - Message %d deleted',[AMsgNo]));
                  Exit;
             end
             Else Reason := ' because Message %d IS already deleted.';
        end
        else Reason := ' because Messagenumber %d is out of range.';
        // We 're here when there was an error
        aCmd.Reply.SetReply(ERR,Format(' -Message not deleted'+Reason,[AMsgNo]));
     Finally
            aCmd.Response.Clear;
            DebugOutput(Format('DELE %d',[AMsgNo]),aCmd);
     End;
end;

//before retrieving messages, client asks for a list  of messages
//Server responds with a +OK followed by number of deliverable
//messages and length of messages in bytes. After this a separate
//list of each message and its length is sent to client.
//here we have only one message, but we can continue with message
//number and its length , one per line and finally a '.' character.
//Format of client command is  LIST
procedure TMBoxDataMod.InternalPop3LIST(ASender: TIdCommand;AMessageNum: Integer);
Var    UserData  : tUserData;
       MailData  : tMailData;
       ii        : Integer;
       Start     : Integer;
       Stop      : Integer;
       TotSize   : Integer;
       Undeled   : Integer;
begin
     // Here you return a list of available messages to the client
     Try
        UserData := tUserData(ASender.Context.Data);
        UserData.FillMailList;
        TotSize := 0;
        If AMessageNum > 0 then
        begin
             Start := AMessageNum-1;
             Stop  := Start;
        end
        Else
        Begin
             Start := 0;
             Stop  := UserData.MailList.Count-1;
        end;
        Undeled := 0; // Mailcount
        For ii := Start to Stop do
        begin
             MailData := tMailData(UserData.MailList.Objects[ii]);
             If not MailData.DoDelete Then
             begin
                  TotSize := TotSize + MailData.MailSize;
                  Inc(Undeled);
                  ASender{.CommandHandler}.Response.Add(Format('%d %d',[Succ(II),MailData.MailSize]));
             end;
        end;
        ASender.Reply.SetReply(OK,Format('%d %d',[Undeled,TotSize]));
     Finally
            DebugOutput(Format('LIST %d',[AMessageNum]),ASender);
     End;
end;

procedure TMBoxDataMod.InternalPop3QUIT(ASender: TIdCommand);
Var       UserData : tUserData;
          MAilData : tMailData;
          ii       : Integer;
begin
     // This event is triggered on a client QUIT (a correct disconnect)
     // Here you should delete any messages that have been marked with DELE.

     // NOTE: The +OK response is AUTOMATICALLY sent back to the client, and the
     // connection is dropped.
     Try
        UserData := tUserData(ASender.Context.Data);
        For ii := 0 to UserData.MailList.Count-1 do
        begin
             MailData := tMailData(UserData.MailList.Objects[ii]);
             If MailData.DoDelete then
             begin
                  Try
                     DeleteFile(UserData.MailList[ii]);
                  except;
                  end;
             end;
        end;
        FreeAndNil(UserData);
        ASender.Context.Data := Nil;
     Finally
            DebugOutput('QUIT',ASender);
     End;

end;

procedure TMBoxDataMod.InternalPOP3Retrieve(aCmd: TIdCommand;
  AMsgNo: Integer);
Var  UserData : tUserData;
     MailData : tMailData;

begin
 // Client initiates retrieving each message by issuing a RETR command
 // to server. Server will respond by +OK and will continue by sending
 // message itself. Each message is saved in a database uppon arival
 // by smtp server and is now delivered to user mail agent by pop3 server.

 // Format of RETR command is something like
 // RETR 1 or RETR 2 etc.

 // First, set the response header - this basically tells the client how big the message is.
     Try
        UserData := tUserData(aCmd.Context.Data);
        If (AMsgNO >= 1) and (AMsgNO <= USerData.MailList.Count) then
        begin
             MailData := tMailData(UserData.MailList.Objects[AMsgNO-1]);
             aCmd.Reply.SetReply(OK,Format('%d octets',[MailData.MailSize]));
             // Now populate aCmd.Response with the data to be returned.
             aCmd.Response.LoadFromFile(UserData.MailList[AMsgNO-1]);
        end
        Else aCmd.Reply.SetReply(ERR,Format(' -Message %d Does not exist.',[AMsgNO]));
     Finally
            DebugOutput(Format('RETR %d',[AMsgNO]),aCmd);
     End;
end;

procedure TMBoxDataMod.InternalPop3RETR(ASender: TIdCommand;
  AMessageNum: Integer);
Var  UserData : tUserData;
     MailData : tMailData;

begin
 // Client initiates retrieving each message by issuing a RETR command
 // to server. Server will respond by +OK and will continue by sending
 // message itself. Each message is saved in a database uppon arival
 // by smtp server and is now delivered to user mail agent by pop3 server.

 // Format of RETR command is something like
 // RETR 1 or RETR 2 etc.

 // First, set the response header - this basically tells the client how big the message is.
     Try
        UserData := tUserData(ASender.Context.Data);
        If (AMessageNum >= 1) and (AMessageNum <= USerData.MailList.Count) then
        begin
             MailData := tMailData(UserData.MailList.Objects[AMessageNum-1]);
             ASender.Reply.SetReply(OK,Format('%d octets',[MailData.MailSize]));
             // Now populate ASender.Response with the data to be returned.
             ASender.Response.LoadFromFile(UserData.MailList[AMessageNum-1]);
        end
        Else ASender.Reply.SetReply(ERR,Format(' -Message %d Does not exist.',[AMessageNum]));
     Finally
            DebugOutput(Format('RETR %d',[AMessageNum]),ASender);
     End;
end;

procedure TMBoxDataMod.InternalPop3RSET(ASender: TIdCommand);
Var       UserData   : tUserData;
          MailData   : tMailData;
          ii         : Integer;
begin
     // here is where the client wishes to reset the current state
     // This may be used to reset a list of pending deletes, etc.

     // Set Reply ???
     Try
        UserData := tUserData(ASender.Context.Data);
        for ii := 0 to UserData.MailList.Count-1 do
        begin
             MailData := tMailData(UserData.MailList.Objects[ii]);
             If MailData.DoDelete then MailData.DoDelete := False;
        end;
     Finally
            DebugOutput('RSET',ASender);
     End;
end;

procedure TMBoxDataMod.InternalPOP3Stat(aCmd: TIdCommand; out oCount,
  oSize: Integer);
Var    UserData  : tUserData;
begin
     // here is where the client has asked for the Status of the mailbox
     //When client asks for a statistic of messages server will answer
     //by sending an +OK followed by number of messages and length of them
     //Format of client message is STAT
     Try
        UserData := tUserData(aCmd.Context.Data);
        UserData.FillMailList;
        oCount := UserData.MailList.Count;
        oSize  := UserData.MBoxSize;
     Finally
             DebugOutput('STAT',aCmd);
     End;
end;

procedure TMBoxDataMod.InternalPop3TOP(ASender: TIdCommand; AMessageNum,
  ANumLines: Integer);
(* * )
Var  UserData        : tUserData;
     MailData        : tMailData;
     Line            : String;
     F               : TextFile;
     ii              : Integer;
     InternalMessage : tIDMessage;
(* *)
begin
     // This is where the client has requested the TOP X lines of a particular
     // message to be sent to them
//     InternalMessage := tIdMessage.Create;
     Try
(* *)
        ASender.Reply.SetReply(ERR,' -TOP not supported');
(* * )
// This code didn't work, I've to check out the RFC to see how2do that
        UserData := tUserData(ASender.Context.Data);
        If (AMessageNum >= 1) and (AMessageNum <= USerData.MailList.Count) then
        begin
             MailData := tMailData(UserData.MailList.Objects[AMessageNum-1]);
             ASender.Reply.SetReply(OK,Format('%d octets',[MailData.MailSize]));
             AssignFile(F,UserData.MailList[AMessageNum-1]);
             Reset(F);
             For ii := 1 to ANumLines do
             begin
                  If EOF(F) then Exit;
                  ReadLn(F,Line);

                  // Now populate ASender.Response with the data to be returned.
                  ASender.Response.Add(Line);
             end;
        end
        Else ASender.Reply.SetReply(ERR,Format(' -Message %d Does not exist.',[AMessageNum]));
(* *)
     Finally
            DebugOutput(Format('TOP NR=%d Lns=%d',[AMessageNum,ANumLines]),ASender);
     End;
end;

procedure TMBoxDataMod.InternalPop3UIDL(ASender: TIdCommand;
  AMessageNum: Integer);
Var    UserData  : tUserData;
       MailData  : tMailData;
       ii        : Integer;
       Start     : Integer;
       Stop      : Integer;
       InternalMessage : tIDMessage;
       MyReply   : String;
       SingleLine  : Boolean;

Function RemoveAngels(Const MsgString:String) : String;
Var       Nrs    : Integer;
Begin
     Result := MSGString;
     Nrs := Length(Result);
     If Nrs < 2 then Exit;
     If Result[1] = '<' then
     begin
          Delete(Result,1,1);
          Dec(Nrs);
     end;
     If Result[Nrs] = '>' then Delete(Result,Nrs,1);
end;

begin
     // This is where the client has requested the unique identifier (UIDL) of each
     // message, or a particular message to be sent to it.
     InternalMessage := tIdMessage.Create;
     try
         UserData := tUserData(ASender.Context.Data);
         UserData.FillMailList;
         SingleLine := AMessageNum > 0;
         If SingleLine then
         begin
              Start := AMessageNum-1;
              Stop  := Start;
         end
         Else
         Begin
              Start := 0;
              Stop  := UserData.MailList.Count-1;
         end;
         If (AMessageNum = 0) or (AMessageNum > UserData.MailList.Count) then
         begin
                  ASender.Reply.SetReply(ERR,Format('Message %d does not exist.',[UserData.MailList.Count]));
                  Exit;
         end;
         For ii := Start to Stop do
         begin
              MailData := tMailData(UserData.MailList.Objects[ii]);
              If not MailData.DoDelete Then
              begin
                   InternalMessage.LoadFromFile(UserData.MailList[ii],true);
                   MyReply := (Format('%d %s',[Succ(II),RemoveAngels(InternalMessage.MsgId)]));
                   If not SingleLine then ASender.Response.Add(Format('%d %s',[Succ(II),MyReply]));
              end
              Else
              Begin
                   If SingleLine then  ASender.Reply.SetReply(ERR,Format(' Message %d already deleted',[UserData.MailList.Count]));
              end;
         end;
         If SingleLine then
         begin
              ASender.Reply.SetReply(OK,MyReply);
         end
         else
         begin
         end;
      finally
             FreeAndNil(InternalMessage);
             DebugOutput(Format('UIDL %d',[AMessageNum]),ASender);
      end;
end;

procedure TMBoxDataMod.InternalPOP3CheckUser(aContext: TIdContext;
  aServerContext: TIdPOP3ServerContext);
Var      UserData   : tUserData;
         MBox       : String;
begin
// aServerContext.Username -> examine this for valid username
// aServerContext.Password -> examine this for valid password
// if the user/pass pair are valid, then respond with
// aServerContext.State := Trans
// to reject the user/pass pair, do not change the state
{  This was changed recently, now just return form this proc.
   if the user is not authenticated, throw exception
}
     DBSection.Enter;
     Try
        MBox := GetValidMailBoxName(aServerContext.Username,aServerContext.Password);
        If MBox <> '' Then
        begin
//             LThread.Authenticated := true;
//             LThread.State     := Trans;
             UserData           := tUserData.Create(aServerContext.UserName);
             UserData.MBoxPath  := MBoxRoot+MBox;
             aContext.Data      := UserData;
        end
        else begin
             Raise Exception.Create('Invalid username or password');
        end;
     Finally
            DBSection.Leave;
     End;
end;

procedure TMBoxDataMod.InternalPop3Connect(AContext: TIdContext);
begin
// When a client connects to our server we must reply with +OK, or -ERR
// Set this via Greeting.Text at runtime, or possibly in OnBeforeCommandHandler?
// You may also wish to initialise some global vars here, set the POP3 box to locked state, etc.
end;

procedure TMBoxDataMod.InternalPop3Exception(AContext: TIdContext;
  AException: Exception);
begin
// Handle any exceptions given by the thread here
end;

{*************************************************************************}
{*                                                                       *}
{*                                                                       *}
{*    Housekeeping                                                       *}
{*                                                                       *}
{*************************************************************************}

procedure TMBoxDataMod.InitMailBoxes;
Var       BoxList : tStringList;
          ii      : integer;
          Fn      : String;
begin
     // Verify, that all mailboxes exist.
     // a Mailbox is only a folder where all the mail is stored.
     DBSection.Enter;
     try
        BoxList := GetMailBoxList; // Get a List of all Mailboxnames
        For ii := 0 to Boxlist.Count-1 do
        begin
             ForceDirectories(MBoxRoot+BoxList[ii]);
        end;
     Finally
            FreeAndNil(BoxList);
            DBSection.Leave;
     end;
{
   I decided to have a folder where all sent mail is stored
}
     Fn := MBoxRoot + SentArchive;
     ForceDirectories(Fn);
end;

{*************************************************************************}
{*                                                                       *}
{*     tMailData                                                         *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}
{
   tMailData is used to keep a little bit of information for a User's mail.
   As usual I store this as an object into a StringList. (one of my favorite
   programming techniques) It is allocated and freed as needed with the help
   of its Cunstructor and Destructor.
}
constructor tMailData.Create(const AFileName: String);
begin
     Self.FName      := AFilename;
     Self.DoDelete   := False;
     Self.DoSend     := False;
     Self.MailSize   := GetFileSize(FName);
     Self.MailNumber := 0;
end;

destructor tMailData.Destroy;
begin
     inherited Destroy;
end;

{*************************************************************************}
{*                                                                       *}
{*        TUSERDATA                                                      *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}
{
   The above applies to tUserData as well.
}

constructor tUserData.Create(const AUsrName:String);
begin
     Inherited Create;
     Self.MailList := tStringList.Create;
     Self.UsrName  := AUsrName;
     Self.MBoxSize := 0;
end;

destructor tUserData.Destroy;
Var        MailData : tMailData;
           II       : Integer;
begin
     For ii := 0 to Self.MailList.Count-1 do
     begin
          MailData := (tMailData(Self.MailList.Objects[ii]));
          MailData.Free;
          Self.MailList.Objects[ii] := nil;
     end;
     Self.MailList.Free;
     Inherited Destroy;
end;

procedure tUserData.FillMailList;
{
  Here we look into the User's mailbox and aquire all the
  mails into his(!) MailList
}
Var       MailData : tMailData;
          FileList : tStringList;
          ii       : Integer;
          TotSize  : Integer;
begin
     If Self.MailList.Count > 0 then Exit; // Do not generate twice!
     FileList := tStringList.Create;
     TotSize := 0;
     try
        GetFilesInDir(Self.MBoxPath,FileList,'*.Raw');
        for ii  := 0 to FileList.Count-1 do
        begin
             MailData := tMailData.Create(FileList[ii]);
             MailData.MailNumber := ii;
             Self.MailList.AddObject(FileList[ii],MailData);
             TotSize := TotSize + Integer(FileList.Objects[II]);
        end;
     finally
            Self.MBoxSize := TotSize;
            FileList.Free;
     end;
end;

procedure TMBoxDataMod.InternalPOP3Disconnect(AContext: TIdContext);
{  when Pop3 disconnects, the very last thing to do is to
   call this procedure. Here the cleanup is done.
   As I was told recently, Indy itself will free AContext.Data
   so this will work fine if (and only if!!!) it is a decendant of tObject.
   This is true for us, but I kept it freeing myself.
}
Var       UserData : tUserData;
begin
     If Assigned(AContext.Data) then
     begin
          // User did NOT disconnect properly
          UserData := tUserData(AContext.Data);
          FreeAndNil(UserData);
          AContext.Data := nil;
     end;
end;

procedure TMBoxDataMod.RunServer;
{
   Start both internal servers.
   The Internal servers are ment to communicate with you on your
   own LAN (or your own Computer if you use 127.0.0.1
}
begin
     InternalPop3.Active := True;
     InternalSMTP.Active := True;
end;

procedure TMBoxDataMod.StopServer;
// Nothing to say to this
begin
     try
        InternalPop3.Active := False;
     except
     end;
     try
        InternalSMTP.Active := False;
     except
     end;
end;

procedure TMBoxDataMod.InternalPOP3BeforeCommandHandler(
  ASender: TIdCmdTCPServer; var AData: String; AContext: TIdContext);
begin
//  TestPoint
end;

procedure TMBoxDataMod.InternalPOP3Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
//  TestPoint
end;

procedure TMBoxDataMod.InternalPOP3APOP(ASender: TIdCommand;
  AMailboxID: String; var VUsersPassword: String);
begin
//  TestPoint
end;

{*************************************************************************}
{*                                                                       *}
{*      InternalSMTP - Server                                            *}
{*                                                                       *}
{*                                                                       *}
{*************************************************************************}

{ This is the Internal SMTP-Server Part. Originally supplied as

  Demo Name:  SMTP Server
  Created By: Andy Neillans
          On: 27/10/2002

  Notes:
   Demonstration of SMTPServer (by use of comments only!!)
   Read the RFC to understand how to store and manage server data, and
   therefore be able to use this component effectivly.
}

procedure TMBoxDataMod.InternalSMTPMsgReceive(ASender: TIdSMTPServerContext;
  AMsg: TStream; var LAction: TIdDataReply);
var
//   LMsg          : TIdMessage;
   LStream       : TFileStream;
   UserData      : tUserData;
   CurrMailFName : String;
begin
// When a message is received by the server, this event fires.
// The message data is made available in the AMsg : TStream.
// In this example, we will save it to a temporary file, and then load it using
// IdMessage and parse some header elements.
{ Well, now we will accept this message quietly, save it and put it
  into a queue from which a SMTP - client can read it
  and send it off to the provider's SMTP Server.
}
      UserData      := tUserData(ASender.Data);
      CurrMailFName := Pop3DBMod.GetSendFileName(UserData.MBoxPath);
      LStream       := TFileStream.Create(CurrMailFName, fmCreate);
      Try
         LStream.CopyFrom(AMsg, 0);
         DebugString('SMTP: Mail received from '+UserData.UsrName);
      Finally
             FreeAndNil(LStream);
      End;
      Pop3DBMod.EnterToSendMail(CurrMailFName);
end;

procedure TMBoxDataMod.InternalSMTPRcptTo(ASender: TIdSMTPServerContext;
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

procedure TMBoxDataMod.InternalSMTPUserLogin(ASender: TIdSMTPServerContext;
  const AUsername, APassword: String; var VAuthenticated: Boolean);
Var      UserData   : tUserData;
         MBox       : String;
begin
 // This event is fired if a user attempts to login to the server
 // Normally used to grant relay access to specific users etc.
{ we use the very same mechanism as in POP3Login to grant access for the user }
     DBSection.Enter;
     Try
        MBox := GetValidMailBoxName(AUsername,APassword);
        If MBox <> '' Then
        begin
             VAuthenticated    := True;
             UserData          := tUserData.Create(AUserName);
             UserData.MBoxPath := MBoxRoot+MBox;
             ASender.Data      := UserData;
             DebugString('SMTP: User '+AUserName+' logged in');
        end
        else begin
             DebugString('SMTP: User '+AUserName+' rejected');
        end;
     Finally
            DBSection.Leave;
     End;
end;

procedure TMBoxDataMod.InternalSMTPMailFrom(ASender: TIdSMTPServerContext;
  const AAddress: String; var VAction: TIdMailFromReply);
begin
 // Here we are testing the MAIL FROM line sent to the server.
 // MAIL FROM address comes in via AAddress. VAction sets the return action to the server.

 // The following actions can be returned to the server:
 { mAccept, mReject }

 // For now, we will just always allow the mail from address.
 VAction := mAccept;
end;

(*
procedure TMBoxDataMod.InternalSMTPReceived(ASender: TIdSMTPServerContext;
  AReceived: String);
begin
 // This is a new event in the rewrite of IdSMTPServer for Indy 10.
 // It lets you control the Received: header that is added to the e-mail.
 // If you do not want a Received here to be added, set AReceived := '';
 // Formatting 'keys' are available in the received header -- please check
 // the IdSMTPServer source for more detail.

    AReceived := 'Mail received by internal server using Indy '+ASender.Connection.Version;
end;
*)

procedure TMBoxDataMod.InternalSMTPConnect(AContext: TIdContext);
begin
// TP
end;

procedure TMBoxDataMod.InternalSMTPDisconnect(AContext: TIdContext);
Var       UserData  : tUserData;
begin
      UserData      := tUserData(AContext.Data);
      FreeAndNil(UserData);
      AContext.Data := Nil;
end;

procedure TMBoxDataMod.InternalSMTPException(AContext: TIdContext;
  AException: Exception);
begin
// TP
end;

procedure TMBoxDataMod.InternalSMTPExecute(AContext: TIdContext);
begin
// TP
end;

procedure TMBoxDataMod.InternalSMTPListenException(
  AThread: TIdListenerThread; AException: Exception);
begin
// TP
end;

procedure TMBoxDataMod.InternalSMTPStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
// TP
end;

{*************************************************************************}
{*                                                                       *}
{*         Sending and receiving mail                                    *}
{*                                                                       *}
{*                                                                       *}
{*  This part looks a bit complicated and if you count the lines         *}
{*  you get up to more than 500 just for sending and retrieving a mail.  *}
{*  Well, both can be doe with just a limerick (5 lines) but I'd like    *}
{*  to show you a bit more. Not only the communication with the provider *}
{*  is handled here, but most of that nasty annoying houskeeping         *}
{*  jobs including checking for errors (oh, yes there are often problems *}
{*  in the internet communication).                                      *}
{*  Well, and last (not least hopefully) some comments blowing           *}
{*  the files up a bit, too.                                             *}
{*                                                                       *}
{*************************************************************************}
{
  1. Receiving
  We do not do it the easy way, just getting the mail. We first ask our provider
  for all currently available mail, put it into a list and then working on
  the list. Some features we have to care for: it is pretty good for Tesing when
  you can keep the mail at the provider's while in normal work, you will delete the mail.
  So it would be good to prevent to receive the same mail multiple times.
}

procedure TMBoxDataMod.SetupExternals;
{
  Just set up SMTP and Pop3 clients with the information from the
  Options window
}
begin
     With ExternalSMTP, ProviderForm do
     begin
          if Connected then Disconnect;
          If not SMTPLogin.Checked then AuthType := atNone;
          Host     := SMTPName.Text;
          PassWord := SMTPPWd.Text;
          Port     := StrToInt(SMTPPort.Text);
          UserName := SMTPAccnt.Text;
     end;

     With ExternalPOP3, ProviderForm do
     begin
          if Connected then Disconnect;
          AuthType := atUserPass;
          Host     := POP3Name.Text;
          PassWord := POP3PWd.Text;
          Port     := StrToInt(POP3Port.Text);
          UserName := POP3Accnt.Text;
     end;
end;

Procedure TMBoxDataMod.GetMailInfos(var MailList:tstringList);
Var       Number,
          I         : Integer;
          ii        : Integer;
          MyMsg     : tServerMail;
          Header    : tIDMessage;
Begin
{ Here we just get infos about all the mails. The connection to the provider's mailserver
  has been established and will not be closed.
  You could load here all the headers and store them (or look at them)
  and decide later which mail you'd like to get and which not. that could make
  a mail-client more convinient.
}
     If Assigned(MailList) then FreeAndNil(Maillist); // if there's an old one
     MailList := tStringList.Create;                  // now its a brand new
     ExternalPOP3.ReadTimeout := 3*1000;             // thirty seconds timeout after dialling
     Number := ExternalPOP3.CheckMessages;            // How many maild are at the Provider's
     For I := 1 to Number do                          // MessageNumbers start with 1 !!!
     begin
          Header := tIdMessage.Create(Nil);
          Header.Clear;
          MyMsg := tServermail.Create;
          try
             MyMsg.MailSize    := ExternalPOP3.RetrieveMsgSize(I);
             ExternalPOP3.RetrieveHeader(I,Header);      // Headers only
             MyMsg.MailSubject := Header.Subject;        // Ref
             MyMsg.Mailsentby  := Header.Sender.Text;    // Sender
             MyMsg.MailSentto  := tStringList.Create;    // To
             for ii := 0 to Header.Recipients.Count-1 do
             begin
                  MyMsg.MailSentto.Add(Header.Recipients.Items[ii].Address);
             end;
             MyMsg.MsgId       := Header.MsgId;          // Unique MessageNumber
          except
                DebugException;
                FreeAndNil(MyMsg);                       // oops, an error
          end;
          MailList.AddObject(Header.Sender.Address,Pointer(MyMsg));
          FreeAndNil(Header);
     end;
end;

Procedure TMBoxDataMod.GetAllMail(MailList:tStringList;Const MBoxName:String='');
{
  Now get all the mails from the provider's server which are listed
  in MailList. The connection to the provider is still open and
  will be closed by the calling program
}
Type      tDBMailState = (dbNewMail,dbHeaderOnly,dbOldMail);

Var       I,N,
          MsgNum        : Integer;
          MyMsg         : tServerMail;
          RawFName      : String;
          dbState       : tDBMailState;
          MyStrings     : tStringList;
{
   Here we will get all the mails. Beforehand, we have looked at the Server's site and
   got all the (unique) Mail-IDs.
}

Function CheckDBMail(MailID:String):tDBMailState;
{ Check for completely/partly/unknown mail in Database
  We do not have a database yet, so we have to check for a known
  Mail-ID right now. To do this, we build a List of all maintained
  Mail - IDs and search for a known one. This could be done easily with a StringList
  Of course you can keep this information in a database (as I did, as you can guess
  from the names 'dbOldMail' and 'dbNewMail') The state dbHeaderOnly is not
  handled in this demo, I used it, when I loaded the headers, but was not
  able to load the body of a mail (which happened sometimes). Because we do
  not keep track of loaded Headers, tis is ommitted here.
}
begin
     if MailIDs.IndexOf(MailID) >= 0 then Result := dbOldMail
     Else                                 Result := dbNewMail;
end;

Procedure DeleteMail(const MsgNum:Integer);
{ Delete a mail on the provider's server
  this is done, after retrieval of the mail
  and only if allowed (which is the usual case)
  in the server-options-form
}
begin
     if ProviderForm.DelMail.Checked then  // Option: Delete Mail on Server
     Begin
          ExternalPOP3.Delete(MsgNum);
     end
     Else Begin
          // We should remember having received this mail, so we
          // will not get it a second time. Just add it to the MailIDs - List
          MailIDs.Add(tServerMail(MailList.Objects[Pred(MsgNum)]).MsgId); // MsgNum starts at 1
     end;
end;

Begin  {GetAllMail}
     If Not assigned(MailList) then Exit;      // that would be an error
     If Maillist.Count <=0 then exit;          // nothing to do?
          try  // outermost block
             DebugString(Format('%d message(s) found',[Maillist.Count]));
             For I := 0 to MailList.Count-1 do
             begin
                  MsgNum := I+1; {********* Messagenumbers Start with 1 !!!! *************}
                  MyMsg  := tServerMail(MailList.Objects[I]); // get info
                  If MyMsg <> nil then
                  begin    { Get one Mail and Save it }
                    try
                       { look for Mail already received. Skip if it is there }
                       dbState := CheckDBMail(MyMsg.MsgID);
                       If dbState = dbOldMail then
                       begin
                            // We've seen this one before
                            DeleteMail(MsgNum); // will be deleted only if set in Options
                            Continue;           // Skip processing of this mail
                       end;
// retrieve Message
{
   we retrieve the message as-it-is (raw), no interpretation is performed.
   Then we adjust for some extras and save the mail to a file.
}
                       MyStrings := tStringList.Create;
                       try
                          ExternalPOP3.RetrieveRaw(MsgNum,MyStrings);
{ there is one special character, we have to care for : the dot ('.')
  It is used to indicate the end of a message, so Indy will "byte off" some of them
}
        // Workaround for a line containing one single '.'
                          For N := 0 to MyStrings.Count-1 do
                          begin
                               if MyStrings[N] = '.' then MyStrings[N] := '..';
                          end;
        // Workaround for last dot not saved in mail
                          MyStrings.Add('.');
        // Workarounds end
{
  Now we get the path where to store this mail this includes the mailbox
  name which is guessed from the list the mail is for.
  This could be a file list, then we'd have to save the mail several times.
}
                          RAWFname := GetRawFileName(MBoxRoot,MyMsg);
                          MyStrings.SavetoFile(RAWFname);
{*********** Done with this mail *********************************}
                       finally
                          MyStrings.Free;
                       end;
                       DeleteMail(MsgNum);
                    except
                          DebugException;
                          Exit;
                    end;
                  end { get one mail, MyMsg <> nil ... }
                  else
                  begin { get one mail, MyMsg = nil ... }
                        { there was an error retrieving the header
                          Do whatever you whish to do here
                        }
                  end;
                  FreeAndNil(MyMsg);
                  MailList.Objects[I] := nil;
             end; { for all mails }
        finally
        end;
end;   { GetAllMail }

procedure TMBoxDataMod.SendAllMail;
var       MyList : tList;
          ReschL : tStringList;
          FN     : String;
          P      : PChar;
          Arch   : String;
          EMail  : tIdMessage;
          ii     : Integer;
begin
{
   Sending mail is a pretty easy job to do now: everything is set up already,
   mails to send are stored in a threaded list so we can work on it,
   the mail itself is stored as a file so we just transmit it
}
     Reschl := tStringlist.Create;
     EMail  := tIdMessage.Create;
     While (Pop3DBMod.GetSendMailCount > 0) do  // While there is mail to send
     Begin
          MyList := Pop3DBMod.SendQueue.LockList;
          P := PChar(Mylist[0]);
          Pop3DBMod.SendQueue.UnlockList;
          Pop3DBMod.SendQueue.Remove(P);
          Fn := String(P);
          StrDispose(P);
          If FileExists(Fn) then
           begin
                Email.LoadFromFile(Fn);
                try
                   ExternalSMTP.Send(Email);
{
   I decided to save the sent mails in an archive folder.
   in this version, the root of the archieve and the mail is the same,
   so we can use a simple ReName to have the mail where we want it to be.
}
                   Arch := MBoxRoot + SentArchive + ExtractFileName(Fn);
                   RenameFile(Fn,Arch);
                except
                      DebugException;
{ There was an error in sending a mail. I'd like to re-schedule the file
  but we cannot insert it right now into the Sendqueue or the while-loop
  we are in may run indefinetively
}
                      ReschL.Add(Fn);
                end;
           end
           else begin
// We've got an error here, file to send not found. Handle as you want to...
           end;

     End; {While};
{ Now we can insert the re-scheduled files into the queue }
     For ii := 0 to ReschL.Count-1 do
     begin
          Pop3DBMod.SendQueue.Add(StrNew(PChar(ReSchL[ii])));
     end;
     FreeAndNil(EMail);
     FreeAndNil(ReschL);
end;

procedure TMBoxDataMod.GetSendMail;
{  Here we get and send the mail to our InternetProvider
   For debugging purposes, I heavily used try-except blocks
}
Var       Prvdr    : String;
          MyMailList : tStringList;
begin
     MyMailList := Nil;
     SetupExternals;
// Do we have to dial or connect via LAN
     If ProviderForm.LanChk.Checked then Prvdr := ''
     Else                                Prvdr := ProviderForm.PhoneList.Text;
// Go Online
     If GoOnline(Prvdr) then
     begin
          DebugString('Looking for mail on '+ExternalPop3.Host);
          Try
             ExternalPop3.Connect;
          Except
                DebugException;
                Exit; // If connect didn't work don't try anything else
          End;
          Try
             GetMailInfos(MyMailList);
             GetAllMail(MyMailList);
          Except
                DebugException;
          End;
          Try
             ExternalPop3.Disconnect;
          Except
                DebugException;
          End;

          If Pop3DBMod.GetSendMailCount > 0 then
          begin
               Try
                  DebugString('Sending mail To '+ExternalSMTP.Host);
                  ExternalSMTP.Connect;
               Except
                     DebugException;
                     Exit; // If connect didn't work don't try anything else
               End;
               Try
                  SendAllMail;
               Except
                     DebugException;
               End;
               Try
                  ExternalSMTP.DisConnect;
               Except
                     DebugException;
               End;
          end; { If }
     end;
     If fDoHangup then RasConn.Hangup;
end;

procedure TMBoxDataMod.InternalSMTPReceived(ASender: TIdSMTPServerContext;
  var AReceived: String);
begin
// TP
end;

procedure TMBoxDataMod.InternalSMTPAfterCommandHandler(
  ASender: TIdCmdTCPServer; AContext: TIdContext);
begin
//
end;

procedure TMBoxDataMod.InternalSMTPBeforeCommandHandler(
  ASender: TIdCmdTCPServer; var AData: String; AContext: TIdContext);
begin
//
end;

procedure TMBoxDataMod.InternalSMTPBeforeConnect(AContext: TIdContext);
begin
//
end;

procedure TMBoxDataMod.InternalSMTPBeforeListenerRun(AThread: TIdThread);
begin
//
end;

procedure TMBoxDataMod.InternalPOP3BeforeConnect(AContext: TIdContext);
begin
//
end;

procedure TMBoxDataMod.InternalPOP3BeforeListenerRun(AThread: TIdThread);
begin
//
end;

procedure TMBoxDataMod.InternalPOP3Execute(AContext: TIdContext);
begin
//
end;

procedure TMBoxDataMod.InternalPOP3ListenException(
  AThread: TIdListenerThread; AException: Exception);
begin
//
end;

procedure TMBoxDataMod.InternalPOP3Reset(aCmd: TIdCommand);
begin
//
end;

end.
