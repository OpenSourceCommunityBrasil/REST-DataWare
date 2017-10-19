unit formMain;

interface

uses
  {$IFDEF WINDOWS}Windows,
  {$ELSE}Lcl,{$ENDIF}
  uDWJSON,  Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, fpjson, jsonparser, DB, BufDataset, memds,
  Grids, DBGrids, ExtCtrls, ComCtrls, uRESTDWBase, uRESTDWPoolerDB, uDWConsts,
  uDWJSONObject, uDWJSONTools, IdComponent;

type

  { TForm2 }

  TForm2 = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    DBGrid1: TDBGrid;
    edPasswordDW: TEdit;
    edUserNameDW: TEdit;
    eHost: TEdit;
    ePort: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    mComando: TMemo;
    DataSource1: TDataSource;
    ProgressBar1: TProgressBar;
    RESTDWClientSQL1: TRESTDWClientSQL;
    RESTDWDataBase1: TRESTDWDataBase;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  private
    { Private declarations }
   FBytesToTransfer : Int64;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$IFDEF LCL}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}


{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);
Begin
 {$IFDEF UNIX}
 DateSeparator    := '/';
 ShortDateFormat  := 'dd/mm/yyyy';
 LongDateFormat   := 'dd mmmm yyyy';
 DecimalSeparator := ',';
 CurrencyDecimals := 2;
 {$ENDIF}
 RESTDWDataBase1.PoolerService := eHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(ePort.Text);
 RESTDWDataBase1.Login         := edUserNameDW.Text;
 RESTDWDataBase1.Password      := edPasswordDW.Text;
 RESTDWDataBase1.Compression   := CheckBox1.Checked;
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.sql.clear;
 RESTDWClientSQL1.sql.add(mComando.Text);
 RESTDWClientSQL1.Active       := True;
End;

procedure TForm2.Button2Click(Sender: TObject);
Var
 vError : String;
begin
 RESTDWDataBase1.Close;
 RESTDWDataBase1.PoolerService := eHost.Text;
 RESTDWDataBase1.PoolerPort    := StrToInt(ePort.Text);
 RESTDWDataBase1.Login         := edUserNameDW.Text;
 RESTDWDataBase1.Password      := edPasswordDW.Text;
 RESTDWDataBase1.Compression   := CheckBox1.Checked;
 RESTDWDataBase1.Open;
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.SQL.Clear;
 RESTDWClientSQL1.SQL.Add(mComando.Text);
 If Not RESTDWClientSQL1.ExecSQL(vError) Then
  Showmessage('Erro executando o comando ' + RESTDWClientSQL1.SQL.Text)
 Else
  Showmessage('Comando executado com sucesso...');
end;

procedure TForm2.RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
 If FBytesToTransfer = 0 Then // No Update File
  Exit;
 ProgressBar1.Position := AWorkCount;
end;

procedure TForm2.RESTDWDataBase1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
 FBytesToTransfer      := AWorkCountMax;
 ProgressBar1.Max      := FBytesToTransfer;
 ProgressBar1.Position := 0;
end;

procedure TForm2.RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
 ProgressBar1.Position := FBytesToTransfer;
 FBytesToTransfer      := 0;
end;

end.
