unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, uRestPoolerDB,
  FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope,
  Data.Bind.Controls, FMX.Layouts, Fmx.Bind.Navigator, FMX.ListBox;

type
  TForm2 = class(TForm)
    RESTClientSQL: TRESTClientSQL;
    RESTDataBase: TRESTDataBase;
    Panel1: TPanel;
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    BindingsList1: TBindingsList;
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
    BindSourceDB1: TBindSourceDB;
    ListView1: TListView;
    LinkListControlToField1: TLinkListControlToField;
    ListView2: TListView;
    RESTClientSQL3: TRESTClientSQL;
    RESTClientSQL3EMP_NO: TSmallintField;
    RESTClientSQL3CHANGE_DATE: TSQLTimeStampField;
    RESTClientSQL3UPDATER_ID: TStringField;
    RESTClientSQL3OLD_SALARY: TFloatField;
    RESTClientSQL3PERCENT_CHANGE: TFloatField;
    RESTClientSQL3NEW_SALARY: TFloatField;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    Edit3: TEdit;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure RESTDataBaseBeforeConnect(Sender: TComponent);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.Button1Click(Sender: TObject);
Begin
 RESTDataBase.Active := True;
 If RESTDataBase.Active Then
  Begin
   RESTClientSQL.Active       := False;
   RESTClientSQL.ParamByName('FIRST_NAME').AsString := Edit3.Text;
   RESTClientSQL.Active       := True;
  End;
end;

procedure TForm2.RESTDataBaseBeforeConnect(Sender: TComponent);
begin
 RESTDataBase.PoolerService := Edit1.Text;
 RESTDataBase.PoolerPort    := StrToInt(Edit2.Text);
end;

end.
