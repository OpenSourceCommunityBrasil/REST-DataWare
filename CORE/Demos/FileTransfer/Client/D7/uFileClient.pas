unit uFileClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, uRESTDWBase, ExtCtrls,
  pngimage, uDWJSONObject, uDWConsts, uDWConstsData, ComCtrls, idComponent,
  acPNG;

type
  TForm4 = class(TForm)
    Label4: TLabel;
    Label5: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    Label7: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    eHost: TEdit;
    ePort: TEdit;
    edPasswordDW: TEdit;
    edUserNameDW: TEdit;
    RESTClientPooler1: TRESTClientPooler;
    Label1: TLabel;
    Button1: TButton;
    Bevel2: TBevel;
    lbLocalFiles: TListBox;
    Button2: TButton;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    cmb_tmp: TComboBox;
    Label2: TLabel;
    ProgressBar1: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure RESTClientPooler1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure RESTClientPooler1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure RESTClientPooler1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  private
    { Private declarations }
   FBytesToTransfer : Int64;
  public
    { Public declarations }
   DirName : String;
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);
Var
 lResponse : String;
 JSONValue : TJSONValue;
Begin
 lbLocalFiles.Clear;
 RESTClientPooler1.Host     := eHost.Text;
 RESTClientPooler1.Port     := StrToInt(ePort.Text);
 RESTClientPooler1.UserName := edUserNameDW.Text;
 RESTClientPooler1.Password := edPasswordDW.Text;
 Try
  Try
   lResponse := RESTClientPooler1.SendEvent('FileList');
   If lResponse <> '' Then
    Begin
     JSONValue := TJSONValue.Create;
     Try
      JSONValue.LoadFromJSON(lResponse);
      lbLocalFiles.Items.Text := JSONValue.Value;
     Finally
      JSONValue.Free;
     End;
    End;
  Except
  End;
 Finally

 End;
End;

procedure TForm4.Button2Click(Sender: TObject);
Var
 lResponse    : String;
 JSONValue    : TJSONValue;
 DWParams     : TDWParams;
 JSONParam    : TJSONParam;
 StringStream : TMemoryStream;
Begin
 If lbLocalFiles.ItemIndex > -1 Then
  Begin
   RESTClientPooler1.Host     := eHost.Text;
   RESTClientPooler1.Port     := StrToInt(ePort.Text);
   RESTClientPooler1.UserName := edUserNameDW.Text;
   RESTClientPooler1.Password := edPasswordDW.Text;
   DWParams                   := TDWParams.Create;
   JSONParam                  := TJSONParam.Create;
   JSONParam.ParamName        := 'Arquivo';
   JSONParam.ObjectDirection  := odIN;
   JSONParam.SetValue(lbLocalFiles.Items[lbLocalFiles.ItemIndex]);
   DWParams.Add(JSONParam);
   Try
    Try
     RESTClientPooler1.Host := eHost.Text;
     RESTClientPooler1.Port := StrToInt(ePort.Text);
     lResponse := RESTClientPooler1.SendEvent('DownloadFile', DWParams);
     If lResponse <> '' Then
      Begin
       JSONValue := TJSONValue.Create;
       Try
        JSONValue.LoadFromJSON(lResponse);
        lResponse             := '';
        StringStream          := TMemoryStream.Create;
        JSONValue.SaveToStream(StringStream);
        Try
         If FileExists(DirName + lbLocalFiles.Items[lbLocalFiles.ItemIndex]) Then
          DeleteFile(DirName + lbLocalFiles.Items[lbLocalFiles.ItemIndex]);
         StringStream.SaveToFile(DirName + lbLocalFiles.Items[lbLocalFiles.ItemIndex]);
         Showmessage('Download concluído...');
        Finally
         FreeAndNil(StringStream);
        End;
       Finally
        FreeAndNil(JSONValue);
       End;
      End;
    Except
    End;
   Finally
    FreeAndNil(DWParams);
   End;
  End
 Else
  Showmessage('Escolha um arquivo para Download...');
End;

procedure TForm4.Button3Click(Sender: TObject);
Var
 DWParams            : TDWParams;
 JSONParam           : TJSONParam;
 lResponse           : String;
 MemoryStream        : TMemoryStream;
Begin
  RESTClientPooler1.RequestTimeOut:= StrToInt(Copy(cmb_tmp.Text, 1,1)) * 60000;
  If OpenDialog1.Execute Then
  Begin
   DWParams                     := TDWParams.Create;
   JSONParam                    := TJSONParam.Create;
   JSONParam.ParamName          := 'Arquivo';
   JSONParam.ObjectDirection    := odIN;
   JSONParam.SetValue(OpenDialog1.FileName);
   DWParams.Add(JSONParam);
   JSONParam                    := TJSONParam.Create;
   JSONParam.ParamName          := 'FileSend';
   JSONParam.ObjectDirection    := odIN;
   JSONParam.ObjectValue        := ovBlob;
   MemoryStream                 := TMemoryStream.Create;
   MemoryStream.LoadFromFile(OpenDialog1.FileName);
   JSONParam.LoadFromStream(MemoryStream);
   MemoryStream.SetSize(0);
   MemoryStream.Free;
   DWParams.Add(JSONParam);
   JSONParam                    := TJSONParam.Create;
   JSONParam.ParamName          := 'Result';
   JSONParam.ObjectDirection    := odOUT;
   JSONParam.SetValue('');
   DWParams.Add(JSONParam);
   lResponse := RESTClientPooler1.SendEvent('SendReplicationFile', DWParams, sePost);
   If lResponse <> '' Then
    Begin
      Try
       If GetBooleanFromString(DWParams.ItemsString['Result'].Value) Then
        Showmessage('Upload concluído...');
      Finally
      End;
    End;
   DWParams.Free;
  End;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
 DirName  := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
             IncludeTrailingPathDelimiter('filelist');
 If Not DirectoryExists(DirName) Then
  ForceDirectories(DirName);
end;

procedure TForm4.RESTClientPooler1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  If FBytesToTransfer = 0 Then // No Update File
   Exit;
  ProgressBar1.Position := AWorkCount;
end;

procedure TForm4.RESTClientPooler1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
 FBytesToTransfer := AWorkCountMax;
 ProgressBar1.Max := FBytesToTransfer;
 ProgressBar1.Position := 0;
end;

procedure TForm4.RESTClientPooler1WorkEnd(ASender: TObject;
  AWorkMode: TWorkMode);
begin
 ProgressBar1.Position := FBytesToTransfer;
 FBytesToTransfer      := 0;
end;

end.
