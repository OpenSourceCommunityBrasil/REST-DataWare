unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uRestPoolerDB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.StorageBin,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TForm4 = class(TForm)
    RESTDataBase: TRESTDataBase;
    RESTClientSQL1: TRESTClientSQL;
    RESTClientSQL2: TRESTClientSQL;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    RESTClientSQL1DEPT_NO: TStringField;
    RESTClientSQL1DEPARTMENT: TStringField;
    RESTClientSQL1HEAD_DEPT: TStringField;
    RESTClientSQL1MNGR_NO: TSmallintField;
    RESTClientSQL1BUDGET: TFloatField;
    RESTClientSQL1LOCATION: TStringField;
    RESTClientSQL1PHONE_NO: TStringField;
    RESTClientSQL2EMP_NO: TSmallintField;
    RESTClientSQL2FIRST_NAME: TStringField;
    RESTClientSQL2LAST_NAME: TStringField;
    RESTClientSQL2PHONE_EXT: TStringField;
    RESTClientSQL2HIRE_DATE: TSQLTimeStampField;
    RESTClientSQL2DEPT_NO: TStringField;
    RESTClientSQL2JOB_CODE: TStringField;
    RESTClientSQL2JOB_GRADE: TSmallintField;
    RESTClientSQL2JOB_COUNTRY: TStringField;
    RESTClientSQL2SALARY: TFloatField;
    RESTClientSQL2FULL_NAME: TStringField;
    Label1: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    Label2: TLabel;
    Edit4: TEdit;
    Edit5: TEdit;
    cbxPooler: TComboBox;
    Button3: TButton;
    Bevel2: TBevel;
    Label4: TLabel;
    Button1: TButton;
    Bevel3: TBevel;
    Label6: TLabel;
    procedure RESTClientSQL1AfterDelete(DataSet: TDataSet);
    procedure RESTClientSQL2BeforePost(DataSet: TDataSet);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
   Function GetGenID(GenName  : String;
                     DataBase : TRESTDataBase): Integer;
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

Function TForm4.GetGenID(GenName  : String;
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

procedure TForm4.Button1Click(Sender: TObject);
begin
 If cbxPooler.ItemIndex > -1 Then
  Begin
   RESTDataBase.PoolerName := cbxPooler.Text;
   If RESTDataBase.Active Then
    Begin
     RESTClientSQL1.Close;
     RESTClientSQL1.Open;
    End;
  End
 Else
  Showmessage('Escolha um Pooler para realizar essa operação...');
end;

procedure TForm4.Button3Click(Sender: TObject);
Var
 vTempList : TStringList;
Begin
 RESTClientSQL1.Close;
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

procedure TForm4.RESTClientSQL1AfterDelete(DataSet: TDataSet);
Var
 vError : String;
begin
 If Not (TRESTClientSQL(DataSet).ApplyUpdates(vError)) Then
  Begin
   MessageDlg(vError, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
   Abort;
  End;
end;

procedure TForm4.RESTClientSQL2BeforePost(DataSet: TDataSet);
begin
 RESTClientSQL2EMP_NO.AsInteger := GetGenID('EMP_NO_GEN', RESTClientSQL2.DataBase);
end;

end.
