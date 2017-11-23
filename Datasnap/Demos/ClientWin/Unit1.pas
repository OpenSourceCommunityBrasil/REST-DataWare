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
    Button2: TButton;
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
    mComando: TMemo;
    Button3: TButton;
    Bevel3: TBevel;
    Label6: TLabel;
    Button4: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure RESTDataBaseConnection(Sucess: Boolean; const Error: string);
    procedure Button2Click(Sender: TObject);
    procedure RESTClientSQLGetDataError(Sucess: Boolean; const Error: string);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
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
 Caption := 'REST Dataware - Client SQL';
 if Not (Sucess) then
  MessageDlg(Error, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0)
 Else
  Caption := Caption + ' - ' + RESTDataBase.MyIP;
end;

procedure TForm1.Button1Click(Sender: TObject);
Begin
 If cbxPooler.ItemIndex > -1 Then
  Begin
   RESTDataBase.PoolerName := cbxPooler.Text;
   If RESTDataBase.Active Then
    Begin
     RESTClientSQL.Active       := False;
     RESTClientSQL.SQL.Clear;
     RESTClientSQL.SQL.Add(mComando.Text);
     RESTClientSQL.Active       := True;
    End;
  End
 Else
  Showmessage('Escolha um Pooler para realizar essa operação...');
end;

procedure TForm1.Button2Click(Sender: TObject);
Var
 vError    : String;
Begin
 If cbxPooler.ItemIndex > -1 Then
  Begin
   If RESTDataBase.Active Then
    Begin
     RESTClientSQL.Active       := False;
     RESTClientSQL.SQL.Clear;
     RESTClientSQL.SQL.Add(mComando.Text);
     If Not RESTClientSQL.ExecSQL(vError) Then
      Showmessage(vError);
    End;
  End
 Else
  Showmessage('Escolha um Pooler para realizar essa operação...');
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

procedure TForm1.Button4Click(Sender: TObject);
Var
 vError    : String;
Begin
 If cbxPooler.ItemIndex > -1 Then
  Begin
   If RESTDataBase.Active Then
    Begin
     RESTClientSQL.Active       := False;
     RESTClientSQL.SQL.Clear;
     RESTClientSQL.SQL.Add(mComando.Text);
     Try
      RESTClientSQL.ExecOrOpen;
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
