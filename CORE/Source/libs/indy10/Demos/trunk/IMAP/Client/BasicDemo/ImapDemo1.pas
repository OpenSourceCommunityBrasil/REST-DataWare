{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  57998: ImapDemo1.pas 
{
{   Rev 1.0    13/04/2004 22:31:28  CCostelloe
{ Basic demo
}
unit ImapDemo1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls,
  IdUserPassProvider,
  IdSASLCollection,
  IdSASLLogin,
  IdMessage,
  IdIMAP4;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Button1: TButton;
    Label4: TLabel;
    StringGrid1: TStringGrid;
    Button2: TButton;
    Label5: TLabel;
    ListBox1: TListBox;
    Label6: TLabel;
    Label7: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    //LTheSASLListEntry: TIdSASLListEntry;
    TheImap: TIdIMAP4;
    ThePassProvider: TIdUserPassProvider;
    TheSASLLogin: TIdSASLLogin;
    UsersFolders: TStringList;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
    i: integer;
    bRet: Boolean;
begin
    if Button1.Caption = 'Disconnect' then begin
        Screen.Cursor := crHourGlass;
        TheImap.Disconnect;
        Button1.Caption := 'Connect';
        Screen.Cursor := crDefault;
    end else begin
        Screen.Cursor := crHourGlass;
        TheImap.Host := Edit1.Text;
        TheImap.Username := Edit2.Text;
        TheImap.Password := Edit3.Text;
        //LTheSASLListEntry := TheSmtp.FSASLMechanisms.Add;
        //LTheSASLListEntry.SASL := TheSASLLogin;
        TheImap.Connect;
        ListBox1.Clear;
        bRet := TheImap.ListMailBoxes(UsersFolders);
        if bRet = False then begin
            ShowMessage('Failed to retrieve folder names!');
        end;
        for i := 0 to UsersFolders.Count-1 do begin
            ListBox1.Items.Add(UsersFolders[i]);
        end;
        Button1.Caption := 'Disconnect';
        Screen.Cursor := crDefault;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    TheImap := TIdIMAP4.Create(nil);
    ThePassProvider := TIdUserPassProvider.Create(nil);
    TheSASLLogin := TIdSASLLogin.Create(nil);
    UsersFolders := TStringList.Create;
    StringGrid1.Cells[0, 0] := 'Relative number';
    StringGrid1.Cells[1, 0] := 'UID';
    StringGrid1.Cells[2, 0] := 'Read?';
    StringGrid1.Cells[3, 0] := 'Subject';
    StringGrid1.ColWidths[0] := 100;
    StringGrid1.ColWidths[1] := 100;
    StringGrid1.ColWidths[2] := 50;
    StringGrid1.ColWidths[3] := 290;
    StringGrid1.RowCount := 2;
    StringGrid1.Cells[0, 1] := '';
    StringGrid1.Cells[1, 1] := '';
    StringGrid1.Cells[2, 1] := '';
    StringGrid1.Cells[3, 1] := '';
end;

procedure TForm1.ListBox1Click(Sender: TObject);
var
    TheFlags: TIdMessageFlagsSet;
    TheUID: string;
    i: integer;
    nCount: integer;
    TheMsg: TIdMessage;
    MailBoxName: string;
begin
    if ListBox1.ItemIndex <> -1 then begin
        Screen.Cursor := crHourGlass;
        MailBoxName := ListBox1.Items[ListBox1.ItemIndex];
        if TheImap.SelectMailBox(MailBoxName) = False then begin
            Screen.Cursor := crDefault;
            ShowMessage('Error selecting '+MailBoxName);
            Exit;
        end;
        TheMsg := TIdMessage.Create(nil);
        nCount := TheImap.MailBox.TotalMsgs;
        if nCount = 0 then begin
            StringGrid1.RowCount := 2;
            StringGrid1.Cells[0, 1] := '';
            StringGrid1.Cells[1, 1] := '';
            StringGrid1.Cells[2, 1] := '';
            StringGrid1.Cells[3, 1] := '';
            ShowMessage('There are no messages in '+MailBoxName);
        end else begin
            StringGrid1.RowCount := nCount + 1;
            for i := 0 to nCount-1 do begin
                TheImap.GetUID(i+1, TheUID);
                TheImap.UIDRetrieveFlags(TheUID, TheFlags);
                TheImap.UIDRetrieveHeader(TheUID, TheMsg);
                StringGrid1.Cells[0, i+1] := IntToStr(i+1);
                StringGrid1.Cells[1, i+1] := TheUID;
                if mfSeen in TheFlags then begin
                    StringGrid1.Cells[2, i+1] := 'Yes';
                end else begin
                    StringGrid1.Cells[2, i+1] := 'No';
                end;
                StringGrid1.Cells[3, i+1] := TheMsg.Subject;
            end;
        end;
        TheMsg.Destroy;
        Screen.Cursor := crDefault;
    end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
    if Button1.Caption = 'Disconnect' then begin
        TheImap.Disconnect;
    end;
    UsersFolders.Destroy;
    TheSASLLogin.Destroy;
    ThePassProvider.Destroy;
    TheImap.Destroy;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
    TheUID: string;
begin
    //Delete selected message..
    if StringGrid1.Selection.Top > 0 then begin
        Screen.Cursor := crHourGlass;
        TheUID := StringGrid1.Cells[1, StringGrid1.Selection.Top];
        if TheImap.UIDDeleteMsg(TheUID) = True then begin
            if TheImap.ExpungeMailBox = True then begin
                Screen.Cursor := crDefault;
                ShowMessage('Successfully deleted message - select another mailbox then reselect this mailbox to see its omission');
            end else begin
                Screen.Cursor := crDefault;
                ShowMessage('Succeeded in setting delete flag on message, but expunge failed - is this a read-only mailbox?');
            end;
        end else begin
            Screen.Cursor := crDefault;
            ShowMessage('Failed to set delete flag on message - is this a read-only mailbox?');
        end;
    end;
end;

end.
