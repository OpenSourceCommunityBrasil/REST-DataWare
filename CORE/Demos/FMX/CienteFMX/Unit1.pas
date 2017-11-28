unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  uRESTDWPoolerDB, System.Rtti, FMX.Grid.Style, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, Data.Bind.Components, Data.Bind.Grid,
  Data.Bind.DBScope, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid, FMX.Edit,
  FMX.ListBox, FMX.Memo, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client, system.diagnostics,
  System.TimeSpan, IdComponent, uDWConstsData, IdSSLOpenSSL,system.ioutils,IdSSLOpenSSLHeaders,
  FMX.TabControl, System.Actions, FMX.ActnList;

type
  TForm1 = class(TForm)
    RESTDWDataBase1: TRESTDWDataBase;
    DataSource1: TDataSource;
    BindingsList1: TBindingsList;
    img1: TImage;
    tlb1: TToolBar;
    Text1: TText;
    btn1: TButton;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    lst1: TListBox;
    ListBoxItem1: TListBoxItem;
    edtip: TEdit;
    ListBoxItem2: TListBoxItem;
    edtporta: TEdit;
    Layout4: TLayout;
    Layout5: TLayout;
    mmo1: TMemo;
    RESTDWClientSQL1: TRESTDWClientSQL;
    BindSourceDB1: TBindSourceDB;
    ListBoxItem3: TListBoxItem;
    StringGrid1: TStringGrid;
    LinkGridToDataSourceBindSourceDB12: TLinkGridToDataSource;
    tbc1: TTabControl;
    tablista: TTabItem;
    RESTDWClientSQL1EMP_NO: TSmallintField;
    RESTDWClientSQL1FIRST_NAME: TWideStringField;
    RESTDWClientSQL1LAST_NAME: TWideStringField;
    RESTDWClientSQL1PHONE_EXT: TWideStringField;
    RESTDWClientSQL1HIRE_DATE: TSQLTimeStampField;
    RESTDWClientSQL1DEPT_NO: TWideStringField;
    RESTDWClientSQL1JOB_CODE: TWideStringField;
    RESTDWClientSQL1JOB_GRADE: TSmallintField;
    RESTDWClientSQL1JOB_COUNTRY: TWideStringField;
    RESTDWClientSQL1SALARY: TFloatField;
    RESTDWClientSQL1FULL_NAME: TWideStringField;
    tabaltera: TTabItem;
    actlst1: TActionList;
    ChangeTabaltera: TChangeTabAction;
    ChangeTablista: TChangeTabAction;
    edtnome: TEdit;
    edtnome2: TEdit;
    tlb2: TToolBar;
    btngrava: TButton;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1Tap(Sender: TObject; const Point: TPointF);
    procedure btngravaClick(Sender: TObject);
    procedure StringGrid1CellClick(const Column: TColumn; const Row: Integer);
  private
    { Private declarations }
  public
    fs: TFormatSettings;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.btn1Click(Sender: TObject);
var
Stopwatch: TStopwatch;
Elapsed: TTimeSpan;
begin
  Stopwatch := TStopwatch.StartNew;
  if not RESTDWDataBase1.Connected then
  begin
    RESTDWDataBase1.active := false;
    RESTDWDataBase1.PoolerService := edtip.Text;
    RESTDWDataBase1.PoolerPort := strtoint(edtporta.text);
    RESTDWDataBase1.Active := true;
  end;
  RESTDWClientSQL1.Close;
  RESTDWClientSQL1.SQL.Clear;
  RESTDWClientSQL1.SQL.Text := mmo1.Lines.Text;
  RESTDWClientSQL1.Open;
  Elapsed := Stopwatch.Elapsed;
  listboxitem3.Text:= 'Tempo de Resposta: '+ inttostr(elapsed.Milliseconds)+' milisegundos.';
end;

procedure TForm1.btngravaClick(Sender: TObject);
var serro: string;
begin
if RESTDWClientSQL1.State in [dsEdit,dsInsert] then
  RESTDWClientSQL1.Post;

RESTDWClientSQL1.ApplyUpdates(serro);
if Length(Trim(serro))>0 then
    showmessage(serro);
ChangeTablista.Execute;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 {$IF Defined(ANDROID) OR Defined(IOS)}
 formatsettings.ShortDateFormat:='dd-mm-yyyy';
 formatsettings.DateSeparator:='-';
 formatsettings.DecimalSeparator:='.';
 formatsettings.ThousandSeparator:=',';
 RESTDWDataBase1.DecimalSeparator:=formatsettings.DecimalSeparator;
 {$ELSE}
 formatsettings.ShortDateFormat:='dd-mm-yyyy';
 formatsettings.DateSeparator:='-';
 formatsettings.DecimalSeparator:='.';
 formatsettings.ThousandSeparator:=',';
 RESTDWDataBase1.DecimalSeparator:=formatsettings.DecimalSeparator;
 {$IFEND}
end;

procedure TForm1.StringGrid1CellClick(const Column: TColumn;
  const Row: Integer);
begin
{$IFDEF  MSWINDOWS}
ChangeTabaltera.Execute;
{$ENDIF}
end;

procedure TForm1.StringGrid1Tap(Sender: TObject; const Point: TPointF);
begin
ChangeTabaltera.Execute;
end;

end.

