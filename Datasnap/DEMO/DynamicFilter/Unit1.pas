unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uRestPoolerDB, Vcl.StdCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ImgList,
  Data.DBXCommon, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    DataSource1: TDataSource;
    RESTClientSQL: TRESTClientSQL;
    RESTDataBase: TRESTDataBase;
    Edit4: TEdit;
    Edit5: TEdit;
    Label5: TLabel;
    DBGrid1: TDBGrid;
    Image1: TImage;
    cbxPooler: TComboBox;
    Bevel1: TBevel;
    Label2: TLabel;
    Bevel2: TBevel;
    Label4: TLabel;
    Button3: TButton;
    Bevel3: TBevel;
    Label6: TLabel;
    Edit1: TEdit;
    RESTClientSQLEMP_NO: TSmallintField;
    RESTClientSQLFIRST_NAME: TStringField;
    RESTClientSQLLAST_NAME: TStringField;
    RESTClientSQLPHONE_EXT: TStringField;
    RESTClientSQLHIRE_DATE: TSQLTimeStampField;
    RESTClientSQLDEPT_NO: TStringField;
    RESTClientSQLJOB_CODE: TStringField;
    RESTClientSQLJOB_GRADE: TSmallintField;
    RESTClientSQLJOB_COUNTRY: TStringField;
    RESTClientSQLSALARY: TFloatField;
    RESTClientSQLFULL_NAME: TStringField;
    CheckBox1: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RESTDataBaseConnection(Sucess: Boolean; const Error: string);
    procedure RESTClientSQLGetDataError(Sucess: Boolean; const Error: string);
    procedure Button3Click(Sender: TObject);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.RESTClientSQLGetDataError(Sucess: Boolean;
  const Error: string);
begin
 Showmessage(Error);
end;

procedure TForm1.RESTDataBaseConnection(Sucess: Boolean; const Error: string);
begin
 Caption := 'REST Dataware - Dynamic Filter';
 if Not (Sucess) then
  MessageDlg(Error, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0)
 Else
  Caption := Caption + ' - ' + RESTDataBase.MyIP;
end;

procedure TForm1.Button3Click(Sender: TObject);
Var
 vTempList : TStringList;
Begin
 RESTDataBase.PoolerService := Edit4.Text;
 RESTDataBase.PoolerPort    := StrToInt(Edit5.Text);
 RESTDataBase.Active := True;
 If RESTDataBase.Active Then
  Begin
   cbxPooler.Items.Clear;
   cbxPooler.Text := '';
   vTempList   := RESTDataBase.GetRestPoolers;
   If vTempList <> Nil Then
    If vTempList.Count > 0 Then
     Begin
      cbxPooler.Items.Assign(vTempList);
      cbxPooler.ItemIndex := 0;
     End;
  End;
End;

procedure TForm1.Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
 vTempText : String;
begin
 If cbxPooler.ItemIndex > -1 Then
  Begin
   If RESTDataBase.Active Then
    Begin
     Try
      vTempText := Edit1.Text;
      If chr(Key) in ['a'..'z', 'A'..'Z', '0'..'9', ' '] Then
       Begin
        If Length(vTempText) = 0 Then //Se não tiver texto digitado fecha a consulta
         RESTClientSQL.Close
        Else If Length(vTempText) = 1 Then //Abre aprimeira consulta com dados Filtrados
         Begin
          RESTClientSQL.Close;
          RESTClientSQL.SQL.Clear;
          If CheckBox1.Checked Then
           RESTClientSQL.SQL.Add(Format('SELECT * FROM EMPLOYEE WHERE FIRST_NAME LIKE (''%s'')', ['%' + vTempText + '%']))
          Else
           RESTClientSQL.SQL.Add(Format('SELECT * FROM EMPLOYEE WHERE FIRST_NAME LIKE (''%s'')', [vTempText + '%']));
          RESTClientSQL.Open;
         End
        Else
         RESTClientSQL.DynamicFilter('FIRST_NAME', vTempText, CheckBox1.Checked);
       End
      Else
       Begin
        If Length(vTempText) = 0 Then
         RESTClientSQL.Close
        Else
         RESTClientSQL.DynamicFilter('FIRST_NAME', vTempText, CheckBox1.Checked);
       End;
     Except
      On E : Exception do
       Begin
        Showmessage(E.Message);
       End;
     End;
    End;
  End
 Else
  Showmessage('Escolha um Pooler para realizar essa operação...');
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 RESTClientSQL.Active := False;
 RESTDataBase.Active  := False;
 Form1 := Nil;
 Release;
end;

end.
