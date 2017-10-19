{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  57357: IdIMAP4ServerDemo.pas 
{
{   Rev 1.3    03/03/2004 01:17:28  CCostelloe
{ Yet another check-in as part of continuing development
}
{
{   Rev 1.2    01/03/2004 23:33:48  CCostelloe
{ Further check-in as part of continuing development
}
{
{   Rev 1.1    26/02/2004 02:12:32  CCostelloe
{ Intermediate check-in - about half the functions now work
}
{
{   Rev 1.0    24/02/2004 10:17:02  CCostelloe
{ Implements demo storage mechanism for TIdIMAP4Server on Windows.
}
unit IdIMAP4ServerDemo;

{STATUS OF CODE: This is still in test (Alpha code).  The following is a list
of tested and untested functions.  See note at the end re known limitations of
testing.  Note that functions to add and delete users will be added at a later
date.
Tested:
    LOGIN username admin
    LOGOUT
    LIST "" *
    NOOP
    CAPABILITY (needs work to return the relevant answers)
    SELECT inbox
    EXAMINE inbox
    CREATE newmailbox
    DELETE mailbox
    RENAME oldmailboxname newmailboxname
    SUBSCRIBE mailbox
    UNSUBSCRIBE mailbox
    LSUB "" *
    CLOSE
    CHECK
    STATUS
    [UID]COPY
    [UID]SEARCH [FROM|TO|CC|BCC|SUBJECT] text
    AddUser
    DeleteUser
Not tested:
    APPEND
    EXPUNGE
    [UID]FETCH
    [UID]STORE
NOTE: The functions listed in "Tested" work at least in those cases where
they should succeed, but have not yet been tested for all error conditions,
e.g. deleting a non-existent directory.
They have only been tested where folder name parameters are passed as single
words, e.g. 'C2 CREATE MYFOLDER'.  They have not been tested for 'C2 CREATE
"MYFOLDER"' or 'C2 CREATE "MY FOLDER"', which will probably require the
insertion of statements like:
  LMailBoxName := StripQuotesIfNecessary(AMailBoxName);
They have not been tested for all combinations of the connection state,
TIdIMAP4PeerContext(ASender.Context).FConnectionState (some commands are
only allowed in certain connection states).
They have not been tested when applied to both read-write and read-only
mailboxes.
}
{
IMPLEMENTATION NOTES:
This is a functioning IMAP server, which at worst gives you a sample IMAP
server that you can tailor to your needs: just change the command handlers
you wish to modify.

This is filesystem specific, i.e. it will only work on Windows-type filesystem
though some untested attempts have been made to make it run on Linux.

The default behaviour uses a directory structure \imapmail\username\mailbox\
into which you should populate it with emails (you could use a TIdPOP3 client
program, or maybe a TIdIMAP4 client via its APPEND command to do this).
The filenames in the directory correspond to unique sequentially-assigned
numbers which serve as UIDs, e.g. 123.txt.

Note: In practice, you should NEVER re-use a previously-assigned UID
unless you have to, and then you must increment the UIDValidity value,
BUT this implementation does not implement the UIDValidity property, it
always uses 9999 as the UIDValidity.

The next free UID is recorded by creating a file whose filename is that
number, followed by .uid, e.g. 234.uid.
If you populate a mailbox using APPEND, this methodology is implemented for you.
If you fill the mailbox through some other method, implement this methodology.

The filenames of the emails are their UID followed by .txt, e.g. 1234.txt.

You can override the default root path of \imapmail by setting RootPath (it
defaults to /var/imapmail in Linux).

Note this code uses PathDelim instead of \ for cross-platform support.

To support this default behaviour, two X commands could be added:
  X ADDUSER UserName Password
  X DELETEUSER UserName
These would add or remove the corresponding directories to support that user.  In
practice, you would probably call these from your server program, but the X
commands would allow an IMAP client to call them.

WARNING: \Seen is not really implemented, would need permanent storage on disk
between sessions to record which messages have been viewed.
The \Seen flag is automatically set in the default behaviour when a mailbox
is selected.

Note BODY.PEEK[] maps to BODY[] because we don't really support \Seen.
}

interface
{$IFDEF INDY100}
{$I Core\IdCompilerDefines.inc}
{$IFDEF DOTNET}
{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}
{$ENDIF}

uses
{
  Classes, SysUtils,
  IdAssignedNumbers, IdContext, IdException, IdExplicitTLSClientServerBase, IdServerIOHandler, IdCmdTCPServer,
  IdCommandHandlers, IdGlobal, IdResourceStrings, IdSSL,
  IdTCPConnection, IdYarn,
  IdIMAP4, //For some defines like TIdIMAP4ConnectionState
  IdReply, IdReplyIMAP4;
}
  Classes,
  IdImap4Server,
  IdAssignedNumbers,
  IdCmdTCPServer,
  IdContext,
  IdCommandHandlers,
  IdException,
  IdExplicitTLSClientServerBase,
  IdIMAP4, //For some defines like TIdIMAP4ConnectionState
  IdMailBox,
  IdMessage,
  IdReply,
  IdReplyIMAP4,
  IdTCPConnection,
  IdYarn;

type
  { TIdIMAP4ServerDemo }
  TIdIMAP4ServerDemo = class(TIdIMAP4Server)
  private
  protected
    // Default mechanism handlers...
    function  NameAndMailBoxToPath      (ALoginName, AMailbox: string): string;
    function  DoesImapMailBoxExist      (ALoginName, AMailbox: string): Boolean;
    function  CreateMailBox             (ALoginName, AMailbox: string): Boolean;
    function  DeleteMailBox             (ALoginName, AMailbox: string): Boolean;
    function  IsMailBoxOpen             (ALoginName, AMailbox: string): Boolean;
    function  SetupMailbox              (ALoginName, AMailBoxName: string; AMailBox: TIdMailBox): Boolean;
    function  GetNextFreeUID            (ALoginName, AMailbox: string): string;
    function  RenameMailBox             (ALoginName, AOldMailboxName, ANewMailboxName: string): Boolean;
    function  ListMailBox               (ALoginName, AMailBoxName: string; var AMailBoxNames: TStringList; var AMailBoxFlags: TStringList): Boolean;
    function  DeleteMessage             (ALoginName, AMailbox: string; AMessage: TIdMessage): Boolean;
    function  CopyMessage               (ALoginName, ASourceMailBox, AMessageUID, ADestinationMailbox: string): Boolean;
    function  GetMessageSize            (ALoginName, AMailbox: string; AMessage: TIdMessage): integer;
    function  GetMessageHeader          (ALoginName, AMailbox: string; AMessage, ATargetMessage: TIdMessage): Boolean;
    function  GetMessageRaw             (ALoginName, AMailbox: string; AMessage: TIdMessage; ALines: TStringList): Boolean;
    function  OpenMailBox               (ASender: TIdCommand; AReadOnly: Boolean): Boolean;
    function  UpdateNextFreeUID         (ALoginName, AMailBoxName, ANewUIDNext: string): Boolean;
    function  GetFileNameToWriteAppendMessage(ALoginName, AMailBoxName, AUID: string): string;
    //Internally used functions...
    procedure OutputCurrentMailboxStats (ASender: TIdCommand);
    function  GetMailBoxes              (ADir, AMailBoxName: string; var AMailBoxNames: TStringList; var AMailBoxFlags: TStringList): Boolean;
    function  LoadMailBox               (ALoginName, AMailBoxName: string; AMailBox: TIdMailBox): Boolean;
    procedure InitComponent             ; override;
    procedure RecursivelyEmptyDir       (ADir: string);
  public
    //The following would be used by a server for user management...
    function  AddUser                   (ALoginName: string): Boolean;
    function  DeleteUser                (ALoginName: string): Boolean;
  published
  end;

implementation

uses
  IdGlobal,
  IdGlobalProtocols,
  IdMessageCollection,
  IdResourceStrings,
  IdResourceStringsProtocols,
  IdSSL,
  IdStream,
  Dialogs,
  Windows,
  SysUtils;

procedure TIdIMAP4ServerDemo.InitComponent;
begin
  inherited;
  OnDefMechDoesImapMailBoxExist             := DoesImapMailBoxExist;
  OnDefMechCreateMailBox                    := CreateMailBox;
  OnDefMechDeleteMailBox                    := DeleteMailBox;
  OnDefMechIsMailBoxOpen                    := IsMailBoxOpen;
  OnDefMechSetupMailbox                     := SetupMailbox;
  OnDefMechNameAndMailBoxToPath             := NameAndMailBoxToPath;
  OnDefMechGetNextFreeUID                   := GetNextFreeUID;
  OnDefMechRenameMailBox                    := RenameMailBox;
  OnDefMechListMailBox                      := ListMailBox;
  OnDefMechDeleteMessage                    := DeleteMessage;
  OnDefMechCopyMessage                      := CopyMessage;
  OnDefMechGetMessageSize                   := GetMessageSize;
  OnDefMechGetMessageHeader                 := GetMessageHeader;
  OnDefMechGetMessageRaw                    := GetMessageRaw;
  OnDefMechOpenMailBox                      := OpenMailBox;
  OnDefMechReinterpretParamAsMailBox        := ReinterpretParamAsMailBox;
  OnDefMechUpdateNextFreeUID                := UpdateNextFreeUID;
  OnDefMechGetFileNameToWriteAppendMessage  := GetFileNameToWriteAppendMessage;
end;

function TIdIMAP4ServerDemo.AddUser(ALoginName: string): Boolean;
var
  LDir: string;
begin
  Result := False;
  //INBOX must always exist.
  LDir := NameAndMailBoxToPath(ALoginName, 'INBOX');  {Do not Localize}
  if DirectoryExists(LDir) = True then begin
    ShowMessage('User already exists (i.e. directory '+LDir+' exists)');  {Do not Localize}
    Exit;
  end;
  LDir := FRootPath;
  if LDir[Length(LDir)] <> PathDelim then begin
    LDir := LDir + PathDelim;
  end;
  LDir := LDir + ALoginName;
  if ForceDirectories(LDir) = False then begin
    ShowMessage('Failed to create users directory '+LDir);  {Do not Localize}
    Exit;
  end;
  if CreateMailBox(ALoginName, 'INBOX') = True then begin  {Do not Localize}
    ShowMessage('Successfully added user and created INBOX for '+ALoginName);  {Do not Localize}
    Result := True;
  end else begin
    ShowMessage('Failed to create INBOX for '+ALoginName);  {Do not Localize}
    Result := False;
  end;
end;

function TIdIMAP4ServerDemo.DeleteUser(ALoginName: string): Boolean;
var
  LDir: string;
begin
  Result := False;
  LDir := NameAndMailBoxToPath(ALoginName, 'INBOX');  {Do not Localize}
  if DirectoryExists(LDir) = False then begin
    ShowMessage('User does not exist (i.e. directory '+LDir+' does not exist)');  {Do not Localize}
    Exit;
  end;
  LDir := FRootPath;
  if LDir[Length(LDir)] <> PathDelim then begin
    LDir := LDir + PathDelim;
  end;
  LDir := LDir + ALoginName;
  RecursivelyEmptyDir(LDir);
  ShowMessage('Successfully deleted user '+ALoginName);  {Do not Localize}
  Result := True;
end;

procedure TIdIMAP4ServerDemo.RecursivelyEmptyDir(ADir: string);
var
  LRet: integer;
  LSrchRec: TSearchRec;
begin
  //Empty the dir first...
  LRet := FindFirst(ADir+PathDelim+'*.*', faDirectory, LSrchRec);  {Do not Localize}
  while LRet = 0 do begin
    if ((LSrchRec.Name <> '.') and (LSrchRec.Name <> '..')) then begin  {Do not Localize}
      if (LSrchRec.Attr and faDirectory) <> 0 then begin
        RecursivelyEmptyDir(ADir+PathDelim+LSrchRec.Name);
      end else begin
        if DeleteFile(ADir+PathDelim+LSrchRec.Name) = False then begin
          ShowMessage('Unable to delete file '+ADir+PathDelim+LSrchRec.Name+' (is it in use?)');
          Exit;
        end;
      end;
    end;
    LRet := FindNext(LSrchRec);
  end;
  FindClose(LSrchRec);
  //Now delete it...
  if RemoveDir(ADir) = False then begin
    ShowMessage('Unable to delete directory '+ADir+' (is it in use?)');
    Exit;
  end;
end;

function TIdIMAP4ServerDemo.DoesImapMailBoxExist(ALoginName, AMailbox: string): Boolean;
var
  LDir: string;
begin
  LDir := NameAndMailBoxToPath(ALoginName, AMailbox);
  Result := DirectoryExists(LDir);
end;

function  TIdIMAP4ServerDemo.CreateMailBox(ALoginName, AMailbox: string): Boolean;
var
  LDir: string;
begin
  Result := False;
  LDir := NameAndMailBoxToPath(ALoginName, AMailbox);
  if CreateDir(LDir) = False then begin
    Exit;
  end;
  //if FileCreate(LDir + PathDelim + '1.uid') = -1 then begin
  if CreateEmptyFile (LDir + PathDelim + '1.uid') = False then begin  {Do not Localize}
    Exit;
  end;
  Result := True;
end;

function  TIdIMAP4ServerDemo.DeleteMailBox(ALoginName, AMailbox: string): Boolean;
var
  LDir: string;
  LRet: integer;
  LSrchRec: TSearchRec;
begin
  Result := False;
  LDir := NameAndMailBoxToPath(ALoginName, AMailbox);
  //Empty the dir first...
  LRet := FindFirst(LDir+PathDelim+'*.*', 0, LSrchRec);  {Do not Localize}
  while LRet = 0 do begin
    if ((LSrchRec.Name <> '.') and (LSrchRec.Name <> '..')) then begin  {Do not Localize}
      if DeleteFile(LDir+PathDelim+LSrchRec.Name) = False then begin
        Exit;
      end;
    end;
    LRet := FindNext(LSrchRec);
  end;
  FindClose(LSrchRec);
  //Now delete it...
  if RemoveDir(LDir) = False then begin
    Exit;
  end;
  Result := True;
end;

function  TIdIMAP4ServerDemo.IsMailBoxOpen(ALoginName, AMailbox: string): Boolean;
begin
  {You don't need to implement this if only one client will be connecting at any
   one time.
   One way to implement this is (a) in DoSelectMailbox, create a dummy file in the
   mailbox directory and delete it when you close the mailbox, and (b) in
   this routine, see if that file exists.}
  Result := False;
end;

function  TIdIMAP4ServerDemo.SetupMailbox(ALoginName, AMailBoxName: string; AMailBox: TIdMailBox): Boolean;
begin
  {The sample default mechanism has the messages stored with the UID as the
  filename.  This also will set up the uid file if not present.}
  AMailBox.Clear;
  AMailBox.Name := AMailBoxName;
  LoadMailBox(ALoginName, AMailBoxName, AMailBox);
  AMailBox.TotalMsgs := AMailBox.MessageList.Count;
  AMailBox.UIDValidity := '9999';  //We don't maintain this  {Do not Localize}
  AMailBox.UIDNext := GetNextFreeUID(ALoginName, AMailBoxName);
  Result := True;
end;

function TIdIMAP4ServerDemo.NameAndMailBoxToPath(ALoginName, AMailbox: string): string;
//if AMailbox is '', we are really only checking if the user's dir exists...
var
  LDir: string;
  LN: integer;
  LMailBox: string;
begin
  LDir := FRootPath;
  if LDir[Length(LDir)] <> PathDelim then begin
    LDir := LDir + PathDelim;
  end;
  LDir := LDir + ALoginName;
  LMailBox := StripQuotesIfNecessary(AMailbox);
  if LMailbox <> '' then begin
    //Must replace mailbox delims with path delims...
    for LN := 1 to Length(LMailbox) do begin
      if LMailbox[LN] = MailBoxSeparator then begin
        LMailbox[LN] := PathDelim;
      end;
    end;
    LDir := LDir + PathDelim + LMailbox;
  end;
  Result := LDir;
end;

function  TIdIMAP4ServerDemo.RenameMailBox(ALoginName, AOldMailboxName, ANewMailboxName: string): Boolean;
var
  LDirOld: string;
  LDirNew: string;
begin
  Result := False;
  LDirOld := NameAndMailBoxToPath(ALoginName, AOldMailboxName);
  LDirNew := NameAndMailBoxToPath(ALoginName, ANewMailboxName);
  if RenameFile(LDirOld, LDirNew) = False then begin
    Exit;
  end;
  Result := True;
end;

function  TIdIMAP4ServerDemo.ListMailBox(ALoginName, AMailBoxName: string; var AMailBoxNames: TStringList; var AMailBoxFlags: TStringList): Boolean;
var
  LDir: string;
begin
  AMailBoxNames.Clear;
  AMailBoxFlags.Clear;
  LDir := NameAndMailBoxToPath(ALoginName, AMailBoxName);
  GetMailBoxes(LDir, AMailBoxName, AMailBoxNames, AMailBoxFlags);
  Result := True;
end;

function  TIdIMAP4ServerDemo.DeleteMessage(ALoginName, AMailbox: string; AMessage: TIdMessage): Boolean;
var
  LFile: string;
begin
  LFile := NameAndMailBoxToPath(ALoginName, AMailbox) + PathDelim + AMessage.UID + '.txt';  {Do not Localize}
  Result := DeleteFile(LFile);
end;

function TIdIMAP4ServerDemo.CopyMessage(ALoginName, ASourceMailBox, AMessageUID, ADestinationMailbox: string): Boolean;
//Note the destination mailbox is NEVER the currently-selected mailbox.
var
  LSourceFile: string;
  LDestFile: string;
  LNewUID: string;
begin
  Result := False;
  LSourceFile := NameAndMailBoxToPath(ALoginName, ASourceMailBox) + PathDelim + AMessageUID + '.txt';  {Do not Localize}
  //We need the next free UID in the destination dir...
  LNewUID := GetNextFreeUID(ALoginName, ADestinationMailBox);
  LDestFile   := NameAndMailBoxToPath(ALoginName, ADestinationMailBox) + PathDelim + LNewUID + '.txt';  {Do not Localize}
  if IndyCopyFile(LSourceFile, LDestFile, True) = False then begin
    Exit;
  end;
  Result := UpdateNextFreeUID(ALoginName, ADestinationMailBox, IntToStr(StrToInt(LNewUID)+1));
end;

function  TIdIMAP4ServerDemo.GetMessageSize(ALoginName, AMailbox: string; AMessage: TIdMessage): integer;
//Return message size, or -1 on error.
var
  LFile: string;
  LRet: integer;
  LSrchRec: TSearchRec;
begin
  LFile := NameAndMailBoxToPath(ALoginName, AMailbox) + PathDelim + AMessage.UID + '.txt';  {Do not Localize}
  LRet := FindFirst(LFile, {FileAttrs} 0, LSrchRec);
  if LRet = 0 then begin
    Result := LSrchRec.Size;
    FindClose(LSrchRec);
    Exit;
  end;
  FindClose(LSrchRec);
  Result := -1;
end;

function  TIdIMAP4ServerDemo.GetMessageHeader(ALoginName, AMailbox: string; AMessage, ATargetMessage: TIdMessage): Boolean;
//We don't want to thrash UIDs and flags in AMessage, so load into ATargetMessage
var
  LFile: string;
begin
  LFile := NameAndMailBoxToPath(ALoginName, AMailbox) + PathDelim + AMessage.UID + '.txt';  {Do not Localize}
  ATargetMessage.LoadFromFile(LFile, True);
  Result := True;
end;

function  TIdIMAP4ServerDemo.GetMessageRaw(ALoginName, AMailbox: string; AMessage: TIdMessage; ALines: TStringList): Boolean;
var
  LFile: string;
begin
  LFile := NameAndMailBoxToPath(ALoginName, AMailbox) + PathDelim + AMessage.UID + '.txt';  {Do not Localize}
  ALines.Clear;
  ALines.LoadFromFile(LFile);
  Result := True;
end;

//######### INTERNALLY USED FUNCTIONS #########

function  TIdIMAP4ServerDemo.LoadMailBox(ALoginName, AMailBoxName: string; AMailBox: TIdMailBox): Boolean;
//This does the initial loading of a mailbox: it adds (empty) messages for every
//message that exists in the mailbox and sets the UID of each message.
//Because it does not really support \Seen (which would require disk storage of
//the flags across sessions), it ALWAYS sets the \Seen flag.
var
  LRet: integer;
  LSrchRec: TSearchRec;
  LDir: string;
  LMsgItem : TIdMessageItem;
  LName: string;
begin
  LDir := NameAndMailBoxToPath(ALoginName, AMailBoxName)+PathDelim;
  LRet := FindFirst(LDir+'*.txt', {FileAttrs} 0, LSrchRec);  {Do not Localize}
  while LRet = 0 do begin
    //Extract the UID from the filename...
    LName := ChangeFileExt(LSrchRec.Name, '');
    LMsgItem := AMailBox.MessageList.Add;
    LMsgItem.IdMessage.UID := LName;
    LMsgItem.IdMessage.Flags := [mfSeen];
    LRet := FindNext(LSrchRec);
  end;
  FindClose(LSrchRec);
  AMailBox.TotalMsgs := AMailBox.MessageList.Count;
  Result := True;
end;

procedure TIdIMAP4ServerDemo.OutputCurrentMailboxStats(ASender: TIdCommand);
begin
    DoSendReply(ASender.Context, '* FLAGS (\Answered \Flagged \Draft \Deleted \Seen)');                {Do not Localize}
    DoSendReply(ASender.Context, '* OK [PERMANENTFLAGS (\Answered \Flagged \Draft \Deleted \Seen)]');  {Do not Localize}
    DoSendReply(ASender.Context, '* '+IntToStr(TIdIMAP4PeerContext(ASender.Context).MailBox.TotalMsgs)+' EXISTS'); {Do not Localize}
    DoSendReply(ASender.Context, '* '+IntToStr(TIdIMAP4PeerContext(ASender.Context).MailBox.RecentMsgs)+' RECENT');           {Do not Localize}
    DoSendReply(ASender.Context, '* OK [UNSEEN '+IntToStr(TIdIMAP4PeerContext(ASender.Context).MailBox.UnseenMsgs)+']');      {Do not Localize}
    DoSendReply(ASender.Context, '* OK [UIDVALIDITY '+TIdIMAP4PeerContext(ASender.Context).MailBox.UIDValidity+']'); {Do not Localize}
    DoSendReply(ASender.Context, '* OK [UIDNEXT '+TIdIMAP4PeerContext(ASender.Context).MailBox.UIDNext+']');     {Do not Localize}
end;

function TIdIMAP4ServerDemo.GetMailBoxes(ADir, AMailBoxName: string; var AMailBoxNames: TStringList; var AMailBoxFlags: TStringList): Boolean;
//Return True if this MailBox has SubMailBoxes
var
  LRet: integer;
  LSrchRec: TSearchRec;
  LTemp: string;
  LDoesMailBoxHaveSubMailBoxes: Boolean;
  LMailBoxName: string;
begin
  Result := False;
  LMailBoxName := StripQuotesIfNecessary(AMailBoxName);
  LRet := FindFirst(ADir+PathDelim+'*.*', faDirectory, LSrchRec);  {Do not Localize}
  while LRet = 0 do begin
    if (LSrchRec.Attr and faDirectory) <> 0 then begin
      //It is a directory...
      if ((LSrchRec.Name <> '.') and (LSrchRec.Name <> '..')) then begin  {Do not Localize}
        Result := True;  //Got at least one SubMailBox
        LTemp := '';
        if LMailBoxName <> '' then begin
          LTemp := LMailBoxName + MailBoxSeparator;
        end;
        LTemp := LTemp + LSrchRec.Name;
        LDoesMailBoxHaveSubMailBoxes := GetMailBoxes(ADir+PathDelim+LSrchRec.Name, LTemp, AMailBoxNames, AMailBoxFlags);
        AMailBoxNames.Add(LTemp);
        if LDoesMailBoxHaveSubMailBoxes = True then begin
          AMailBoxFlags.Add('\HasChildren');  {Do not Localize}
        end else begin
          AMailBoxFlags.Add('\HasNoChildren');  {Do not Localize}
        end;
      end;
    end;
    LRet := FindNext(LSrchRec);
  end;
  FindClose(LSrchRec);
end;

function  TIdIMAP4ServerDemo.GetNextFreeUID(ALoginName, AMailbox: string): string;
var
  LLargestUIDInUse: Integer;
  LRet: integer;
  LSrchRec: TSearchRec;
  LDir: string;
  LName: string;
begin
  //Find (or set) the next free
  LDir := NameAndMailBoxToPath(ALoginName, AMailbox)+PathDelim;
  LRet := FindFirst(LDir+'*.uid', {FileAttrs} 0, LSrchRec);  {Do not Localize}
  if LRet = 0 then begin
    LName := ChangeFileExt(LSrchRec.Name, '');
    Result := LName;
    Exit;
  end;
  FindClose(LSrchRec);
  //There is no .uid file present, so set one up (happens, for example,
  //with newly-created mailboxes)...
  LLargestUIDInUse := 0;
  LRet := FindFirst(LDir+'*.txt', {FileAttrs} 0, LSrchRec);  {Do not Localize}
  while LRet = 0 do begin
    //Extract the UID from the filename...
    LName := ChangeFileExt(LSrchRec.Name, '');
    if StrToInt(LName) > LLargestUIDInUse then begin
      LLargestUIDInUse := StrToInt(LName);
    end;
    LRet := FindNext(LSrchRec);
  end;
  FindClose(LSrchRec);
  FileCreate(LDir + IntToStr(LLargestUIDInUse+1) + '.uid');  {Do not Localize}
  Result := IntToStr(LLargestUIDInUse+1);
end;

function  TIdIMAP4ServerDemo.UpdateNextFreeUID(ALoginName, AMailBoxName, ANewUIDNext: string): Boolean;
var
  LRet: integer;
  LSrchRec: TSearchRec;
  LDir: string;
begin
  Result := False;
  //Delete any existing .uid file...
  LDir := NameAndMailBoxToPath(ALoginName, AMailBoxName)+PathDelim;
  LRet := FindFirst(LDir+'*.uid', {FileAttrs} 0, LSrchRec);  {Do not Localize}
  if LRet = 0 then begin
    if DeleteFile(LDir+LSrchRec.Name) = False then begin
      Exit;
    end;
  end;
  FindClose(LSrchRec);
  //Create the new UID file...
  {if FileCreate(LDir + ANewUIDNext + '.uid') <> -1 then begin
    Result := True;
  end;}
  Result := CreateEmptyFile(LDir + ANewUIDNext + '.uid');  {Do not Localize}
end;

function  TIdIMAP4ServerDemo.GetFileNameToWriteAppendMessage(ALoginName, AMailBoxName, AUID: string): string;
var
  LDir: string;
begin
  LDir := NameAndMailBoxToPath(ALoginName, AMailBoxName)+PathDelim;
  Result := LDir + AUID + '.txt';  {Do not Localize}
end;

function TIdIMAP4ServerDemo.OpenMailBox(ASender: TIdCommand; AReadOnly: Boolean): Boolean;
var
  LParams: TStringList;
begin
  Result := False;
  LParams := TStringList.Create;
  BreakApart(ASender.UnparsedParams, ' ', LParams); {Do not Localize}
  if ReinterpretParamAsMailBox(LParams, 0) = False then begin
    SendBadReply(ASender, 'Mailbox parameter is invalid.');  {Do not Localize}
    LParams.Free;
    Exit;
  end;
  if LParams.Count < 1 then begin
    //Incorrect number of params...
    SendIncorrectNumberOfParameters(ASender);
    LParams.Free;
    Exit;
  end;
  if DoesImapMailBoxExist(TIdIMAP4PeerContext(ASender.Context).LoginName, LParams[0]) = False then begin
    SendNoReply(ASender, 'Mailbox does not exist.');  {Do not Localize}
    LParams.Free;
    Exit;
  end;
  {Get everything you need for this mailbox...}
  SetupMailbox(TIdIMAP4PeerContext(ASender.Context).LoginName,
    LParams[0],
    TIdIMAP4PeerContext(ASender.Context).MailBox);
  LParams.Free;
  if AReadOnly = True then begin
    TIdIMAP4PeerContext(ASender.Context).MailBox.State := msReadOnly;
  end else begin
    TIdIMAP4PeerContext(ASender.Context).MailBox.State := msReadWrite;
  end;
  {Send the stats...}
  OutputCurrentMailboxStats(ASender);
  Result := True;
end;

end.
