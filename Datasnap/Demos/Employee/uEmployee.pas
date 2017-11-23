unit uEmployee;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uRestPoolerDB, Vcl.DBCtrls, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

type
  TfEmployee = class(TForm)
    RESTDataBase: TRESTDataBase;
    rEmployee: TRESTClientSQL;
    dsEmployee: TDataSource;
    rEmployeeEMP_NO: TSmallintField;
    rEmployeeFIRST_NAME: TStringField;
    rEmployeeLAST_NAME: TStringField;
    rEmployeePHONE_EXT: TStringField;
    rEmployeeHIRE_DATE: TSQLTimeStampField;
    rEmployeeDEPT_NO: TStringField;
    rEmployeeJOB_CODE: TStringField;
    rEmployeeJOB_GRADE: TSmallintField;
    rEmployeeJOB_COUNTRY: TStringField;
    rEmployeeSALARY: TFloatField;
    rEmployeeFULL_NAME: TStringField;
    rDepartment: TRESTClientSQL;
    dsDepartment: TDataSource;
    rDepartmentDEPT_NO: TStringField;
    rDepartmentDEPARTMENT: TStringField;
    rDepartmentHEAD_DEPT: TStringField;
    rDepartmentMNGR_NO: TSmallintField;
    rDepartmentBUDGET: TFloatField;
    rDepartmentLOCATION: TStringField;
    rDepartmentPHONE_NO: TStringField;
    fJob: TRESTClientSQL;
    fJobJOB_CODE: TStringField;
    fJobJOB_GRADE: TSmallintField;
    fJobJOB_COUNTRY: TStringField;
    fJobJOB_TITLE: TStringField;
    fJobMIN_SALARY: TFloatField;
    fJobMAX_SALARY: TFloatField;
    fJobJOB_REQUIREMENT: TMemoField;
    fJobLANGUAGE_REQ: TArrayField;
    dsJob: TDataSource;
    Label1: TLabel;
    Label2: TLabel;
    DBEdit2: TDBEdit;
    Label3: TLabel;
    DBEdit3: TDBEdit;
    Label4: TLabel;
    DBEdit4: TDBEdit;
    Label5: TLabel;
    DBEdit5: TDBEdit;
    Label7: TLabel;
    DBEdit7: TDBEdit;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    DBLookupComboBox1: TDBLookupComboBox;
    DBLookupComboBox2: TDBLookupComboBox;
    DBText1: TDBText;
    DBText2: TDBText;
    DBText3: TDBText;
    DBNavigator1: TDBNavigator;
    DBText4: TDBText;
    Label6: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    Label15: TLabel;
    Edit4: TEdit;
    Edit5: TEdit;
    cbxPooler: TComboBox;
    Button3: TButton;
    Bevel2: TBevel;
    Label16: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure rEmployeeBeforePost(DataSet: TDataSet);
    procedure rEmployeeAfterInsert(DataSet: TDataSet);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
   Function GetGenID(GenName  : String;
                     DataBase : TRESTDataBase): Integer;
  public
    { Public declarations }
  end;

var
  fEmployee: TfEmployee;

implementation

{$R *.dfm}

Function TfEmployee.GetGenID(GenName  : String;
                             DataBase : TRESTDataBase): Integer;
Var
 vTempClient : TRESTClientSQL;
Begin
 vTempClient := TRESTClientSQL.Create(Nil);
 Result      := -1;
 Try
  vTempClient.DataBase := DataBase;
  vTempClient.SQL.Add(Format('select gen_id(%s, 1)GenID From rdb$database', [GenName]));
  vTempClient.Active := True;
  Result := vTempClient.FindField('GenID').AsInteger;
 Except

 End;
 vTempClient.Free;
End;

procedure TfEmployee.Button1Click(Sender: TObject);
begin
 If cbxPooler.ItemIndex > -1 Then
  Begin
   RESTDataBase.PoolerName := cbxPooler.Text;
   If RESTDataBase.Active Then
    Begin
     rDepartment.Open;
     fJob.Open;
     rEmployee.Open;
    End;
  End
 Else
  Showmessage('Escolha um Pooler para realizar essa operação...');
end;

procedure TfEmployee.Button2Click(Sender: TObject);
Var
 vError : String;
begin
 If Not (rEmployee.ApplyUpdates(vError)) Then
  MessageDlg(vError, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
end;

procedure TfEmployee.Button3Click(Sender: TObject);
Var
 vTempList : TStringList;
Begin
 rDepartment.Close;
 fJob.Close;
 rEmployee.Close;
 RESTDataBase.PoolerService := Edit4.Text;
 RESTDataBase.PoolerPort    := StrToInt(Edit5.Text);
 RESTDataBase.Active        := True;
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

procedure TfEmployee.rEmployeeAfterInsert(DataSet: TDataSet);
begin
 rEmployeeEMP_NO.AsInteger     := GetGenID('EMP_NO_GEN', rEmployee.DataBase);
 rEmployeeHIRE_DATE.AsDateTime := Now;
end;

procedure TfEmployee.rEmployeeBeforePost(DataSet: TDataSet);
begin
 rEmployeeJOB_GRADE.AsInteger  := fJobJOB_GRADE.AsInteger;
 rEmployeeJOB_COUNTRY.AsString := fJobJOB_COUNTRY.AsString;
end;

end.
