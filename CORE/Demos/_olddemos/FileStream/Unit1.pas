unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uRESTDWFileBuffer,
  Vcl.ExtCtrls;

Type
 TRecordData = Record
  Codigo : Integer;
  Nome   : String;
End;
Type
 TRecordsData = Array of TRecordData;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Button3: TButton;
    Edit3: TEdit;
    Button4: TButton;
    RadioGroup1: TRadioGroup;
    Button5: TButton;
    Button6: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
   vFileBuffer : TRESTDWStreamBuffer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
 If RadioGroup1.ItemIndex = 0 Then
  Begin
   vFileBuffer.FileMode := rdwFileCreateExclusive;
   vFileBuffer.FileName := Edit1.Text;
   If FileExists(vFileBuffer.FileName) Then
    vFileBuffer.FileMode := rdwOpenExclusiveWrite;
   vFileBuffer.StreamMode := rdwFileStream;
  End
 Else
  vFileBuffer.StreamMode := rdwMemoryStream;
 vFileBuffer.New;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 vFileBuffer.WriteLn(Edit2.Text);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 vFileBuffer.Bof := vFileBuffer.Eof;
 Edit3.Text      := vFileBuffer.ReadLn;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
 vFileBuffer.CloseFile;
end;

procedure TForm1.Button5Click(Sender: TObject);
Var
 I, Records, Size : Integer;
 RecordsData      : TRecordsData;
begin
 SetLength(RecordsData, 50); //Cria matriz
 For I := 0 To Length(RecordsData) -1 Do //Cria registros
  Begin
   RecordsData[I].Codigo := I + 1;
   RecordsData[I].Nome   := 'Dado Nº:' + FormatFloat('000', I+1);
  End;
 vFileBuffer.WriteArray(RecordsData, TypeInfo(TRecordsData)); //Cria Stream da Matrix
 SetLength(RecordsData, 0); //Zera a Matriz
end;

procedure TForm1.Button6Click(Sender: TObject);
Var
 I, Records, Size : Integer;
 RecordsData      : TRecordsData;
begin
 Memo1.Clear;
 vFileBuffer.ReadArray(RecordsData, TypeInfo(TRecordsData)); //Le do Stream para a Matriz
 For I := 0 To Length(RecordsData) -1 Do //Le registros
  Memo1.Lines.Add(Format('%d - %s', [RecordsData[I].Codigo, RecordsData[I].Nome]));
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 vFileBuffer.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 vFileBuffer := TRESTDWStreamBuffer.Create;
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
 If RadioGroup1.ItemIndex = 0 Then
  Button1.Caption := 'CreateFile'
 Else
  Button1.Caption := 'CreateStream';
 Edit1.Enabled   := RadioGroup1.ItemIndex = 0;
 If RadioGroup1.ItemIndex = 0 Then
  Begin
   vFileBuffer.FileMode := rdwFileCreateExclusive;
   vFileBuffer.FileName := Edit1.Text;
   If FileExists(vFileBuffer.FileName) Then
    vFileBuffer.FileMode := rdwOpenExclusiveWrite;
   vFileBuffer.StreamMode := rdwFileStream;
  End
 Else
  vFileBuffer.StreamMode := rdwMemoryStream;
end;

end.
