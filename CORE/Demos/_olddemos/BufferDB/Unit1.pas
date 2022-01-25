unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uRESTDWBufferDb, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, uDWAbout, uRESTDWPoolerDB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uDWConstsData, uDWConsts, Vcl.ExtCtrls, uRESTDWFileBuffer;

type
  TfGenFile = class(TForm)
    RESTDWClientSQL1: TRESTDWClientSQL;
    RESTDWDataBase1: TRESTDWDataBase;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Button1: TButton;
    eFilename: TEdit;
    rgFileType: TRadioGroup;
    cbHeaders: TCheckBox;
    dwFileBufferDB: TRESTDWBufferDB;
    Button2: TButton;
    RESTDWClientSQL2: TRESTDWClientSQL;
    RESTDWClientSQL2ID: TIntegerField;
    RESTDWClientSQL2BLOBIMAGE: TBlobField;
    RESTDWClientSQL2BLOBTEXT: TMemoField;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fGenFile: TfGenFile;

implementation

{$R *.dfm}

procedure TfGenFile.Button1Click(Sender: TObject);
Var
 vCustomFieldDef : TCustomFieldDef;
 vDataStream     : TStringStream;
begin
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.Open;
 dwFileBufferDB.Dataset := RESTDWClientSQL1;
 dwFileBufferDB.FileOptions.HeaderFields       := cbHeaders.Checked;
 dwFileBufferDB.FileOptions.FileName           := eFilename.Text;
 //Limpa FieldDefs de customizados
 dwFileBufferDB.FieldDefs.Clear;
 If rgFileType.ItemIndex = 0 Then
  Begin
   dwFileBufferDB.MaskOptions.DefaultFieldSize  := 0;
   dwFileBufferDB.FileOptions.FileType          := ftbCSVFile;
   dwFileBufferDB.MaskOptions.DateFormat        := 'dd/mm/yyyy';
   dwFileBufferDB.MaskOptions.TimeFormat        := 'hh:mm:ss';
   dwFileBufferDB.MaskOptions.DateTimeFormat    := 'dd/mm/yyyy hh:mm:ss';
   dwFileBufferDB.FileOptions.OnlyCustomFields  := False;
  End
 Else
  Begin
   dwFileBufferDB.MaskOptions.DefaultFieldSize  := 50;
   dwFileBufferDB.MaskOptions.DateFormat        := 'ddmmyyyy';
   dwFileBufferDB.MaskOptions.TimeFormat        := 'hhmmss';
   dwFileBufferDB.MaskOptions.DateTimeFormat    := 'ddmmyyyyhhmmss';
   dwFileBufferDB.FileOptions.FileType          := ftbFixedText;
   dwFileBufferDB.FileOptions.OnlyCustomFields  := True;
   //Cria e configura FieldDefs para especificar dados customizados
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 5;
   vCustomFieldDef.InsertChar                := '0';
   vCustomFieldDef.InsertCharLeft            := True;
   vCustomFieldDef.FieldName                 := 'EMP_NO';
   vCustomFieldDef.KeyField                  := True;
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 15;
   vCustomFieldDef.InsertChar                := ' ';
   vCustomFieldDef.FieldName                 := 'FIRST_NAME';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 20;
   vCustomFieldDef.InsertChar                := ' ';
   vCustomFieldDef.FieldName                 := 'LAST_NAME';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 14;
   vCustomFieldDef.InsertChar                := '0';
   vCustomFieldDef.InsertCharLeft            := True;
   vCustomFieldDef.MaskOptions.DateTimeFormat := 'ddmmyyyyhhmmss';
   vCustomFieldDef.FieldName                 := 'HIRE_DATE';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 3;
   vCustomFieldDef.InsertChar                := '0';
   vCustomFieldDef.InsertCharLeft            := True;
   vCustomFieldDef.FieldName                 := 'PHONE_EXT';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 10;
   vCustomFieldDef.InsertChar                := '0';
   vCustomFieldDef.InsertCharLeft            := True;
   vCustomFieldDef.MaskOptions.ExcludeDecimalSeparator := True;
   vCustomFieldDef.FieldName                 := 'SALARY';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
  End;
//Gera Arquivo de Dataset
 dwFileBufferDB.DatasetToFile;
 Application.MessageBox('Dados Gerados com sucesso', 'Informação', mb_iconinformation + mb_ok);
end;

procedure TfGenFile.Button2Click(Sender: TObject);
Var
 vCustomFieldDef : TCustomFieldDef;
 vDataStream     : TStringStream;
begin
 RESTDWClientSQL2.Close;
 RESTDWClientSQL2.Open;
 dwFileBufferDB.Dataset := RESTDWClientSQL2;
 dwFileBufferDB.FileOptions.HeaderFields       := cbHeaders.Checked;
 dwFileBufferDB.FileOptions.FileName           := eFilename.Text;
 //Limpa FieldDefs de customizados
 dwFileBufferDB.FieldDefs.Clear;
 If rgFileType.ItemIndex = 0 Then
  Begin
   dwFileBufferDB.MaskOptions.DefaultFieldSize  := 0;
   dwFileBufferDB.FileOptions.FileType          := ftbCSVFile;
   dwFileBufferDB.MaskOptions.DateFormat        := 'dd/mm/yyyy';
   dwFileBufferDB.MaskOptions.TimeFormat        := 'hh:mm:ss';
   dwFileBufferDB.MaskOptions.DateTimeFormat    := 'dd/mm/yyyy hh:mm:ss';
   dwFileBufferDB.FileOptions.OnlyCustomFields  := False;
  End
 Else
  Begin
   dwFileBufferDB.MaskOptions.DefaultFieldSize  := 50;
   dwFileBufferDB.MaskOptions.DateFormat        := 'ddmmyyyy';
   dwFileBufferDB.MaskOptions.TimeFormat        := 'hhmmss';
   dwFileBufferDB.MaskOptions.DateTimeFormat    := 'ddmmyyyyhhmmss';
   dwFileBufferDB.FileOptions.FileType          := ftbFixedText;
   dwFileBufferDB.FileOptions.OnlyCustomFields  := True;
   //Cria e configura FieldDefs para especificar dados customizados
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 5;
   vCustomFieldDef.InsertChar                := '0';
   vCustomFieldDef.InsertCharLeft            := True;
   vCustomFieldDef.FieldName                 := 'EMP_NO';
   vCustomFieldDef.KeyField                  := True;
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 15;
   vCustomFieldDef.InsertChar                := ' ';
   vCustomFieldDef.FieldName                 := 'FIRST_NAME';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 20;
   vCustomFieldDef.InsertChar                := ' ';
   vCustomFieldDef.FieldName                 := 'LAST_NAME';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 14;
   vCustomFieldDef.InsertChar                := '0';
   vCustomFieldDef.InsertCharLeft            := True;
   vCustomFieldDef.MaskOptions.DateTimeFormat := 'ddmmyyyyhhmmss';
   vCustomFieldDef.FieldName                 := 'HIRE_DATE';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 3;
   vCustomFieldDef.InsertChar                := '0';
   vCustomFieldDef.InsertCharLeft            := True;
   vCustomFieldDef.FieldName                 := 'PHONE_EXT';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
   vCustomFieldDef                           := TCustomFieldDef(dwFileBufferDB.FieldDefs.Add);
   vCustomFieldDef.FieldSize                 := 10;
   vCustomFieldDef.InsertChar                := '0';
   vCustomFieldDef.InsertCharLeft            := True;
   vCustomFieldDef.MaskOptions.ExcludeDecimalSeparator := True;
   vCustomFieldDef.FieldName                 := 'SALARY';
   vCustomFieldDef.FieldType                 := FieldTypeToObjectValue(RESTDWClientSQL1.FindField(vCustomFieldDef.FieldName).DataType);
  End;
//Le de Arquivo de Dataset
 dwFileBufferDB.FileToDataset;
 RESTDWClientSQL2.ApplyUpdates;
 Application.MessageBox('Dados Lidos com sucesso', 'Informação', mb_iconinformation + mb_ok);
end;

procedure TfGenFile.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 FreeAndNil(dwFileBufferDB);
 Release;
end;

procedure TfGenFile.FormCreate(Sender: TObject);
begin
 eFilename.Text := IncludeTrailingPathDelimiter(ExtractFilePath(ParamSTR(0))) + 'IMAGELIST.txt';
end;

end.
