unit formMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uDWJSONObject, DB, Grids, DBGrids, uRESTDWBase,
  uDWJSONTools, uDWConsts, Vcl.ExtCtrls, Vcl.Imaging.pngimage, uRESTDWPoolerDB,
  JvMemoryDataset, Vcl.ComCtrls, idComponent, Vcl.Buttons, kbmMemTable, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type

  { TForm2 }

  TForm2 = class(TForm)
    eHost: TEdit;
    ePort: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    DataSource1: TDataSource;
    Image1: TImage;
    Bevel1: TBevel;
    Label7: TLabel;
    edPasswordDW: TEdit;
    Label6: TLabel;
    edUserNameDW: TEdit;
    Label8: TLabel;
    Bevel2: TBevel;
    Label1: TLabel;
    Bevel3: TBevel;
    Label2: TLabel;
    DBGrid1: TDBGrid;
    mComando: TMemo;
    Button1: TButton;
    CheckBox1: TCheckBox;
    RESTDWClientSQL1: TRESTDWClientSQL;
    RESTDWDataBase1: TRESTDWDataBase;
    Button2: TButton;
    ProgressBar1: TProgressBar;
    pedit: TEdit;
    lparams: TListBox;
    addparam: TSpeedButton;
    delparam: TSpeedButton;
    Label3: TLabel;
    btnup: TSpeedButton;
    btndown: TSpeedButton;
    ltempo: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure addparamClick(Sender: TObject);
    procedure delparamClick(Sender: TObject);
    procedure btndownClick(Sender: TObject);
    procedure btnupClick(Sender: TObject);
  private
    { Private declarations }
    FBytesToTransfer: Int64;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses
  StopWatch;

{$R *.dfm}

procedure LbMoveItemUp(AListBox: TListBox);
var
  CurrIndex: Integer;
begin
  with AListBox do
    if ItemIndex > 0 then
    begin
      CurrIndex := ItemIndex;
      Items.Move(ItemIndex, (CurrIndex - 1));
      ItemIndex := CurrIndex - 1;
    end;
end;

procedure LbMoveItemDown(AListBox: TListBox);
var
  CurrIndex, LastIndex: Integer;
begin
  with AListBox do
  begin
    CurrIndex := ItemIndex;
    LastIndex := Items.Count;
    if ItemIndex <> -1 then
    begin
      if CurrIndex + 1 < LastIndex then
      begin
        Items.Move(ItemIndex, (CurrIndex + 1));
        ItemIndex := CurrIndex + 1;
      end;
    end;
  end;
end;

procedure TForm2.addparamClick(Sender: TObject);
begin
  if length(pedit.Text) > 0 then
  begin
    lparams.Items.Add(pedit.Text);
    pedit.Clear;
  end;

end;

procedure TForm2.btndownClick(Sender: TObject);
begin
  LbMoveItemDown(lparams);
end;

procedure TForm2.btnupClick(Sender: TObject);
begin
  LbMoveItemup(lparams);
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  i: integer;
  sw: TStopWatch;
  elapsedMilliseconds: cardinal;
begin
  sw := TStopWatch.Create();
  try
    sw.Start;
    RESTDWDataBase1.Close;
    RESTDWDataBase1.PoolerService := eHost.Text;
    RESTDWDataBase1.PoolerPort := StrToInt(ePort.Text);
    RESTDWDataBase1.Login := edUserNameDW.Text;
    RESTDWDataBase1.Password := edPasswordDW.Text;
    RESTDWDataBase1.Compression := CheckBox1.Checked;
    RESTDWDataBase1.Open;
    RESTDWClientSQL1.Close;
    RESTDWClientSQL1.DisableControls;
    RESTDWClientSQL1.SQL.Clear;
    RESTDWClientSQL1.SQL.Add(mComando.Text);

    if RESTDWClientSQL1.ParamCount > 0 then
    begin
      if lparams.Items.Count < RESTDWClientSQL1.ParamCount then
      begin
        showmessage('O numero de parametros tem de ser igual aos da Consulta');
        abort
      end
      else
      begin
        try
          for i := 0 to RESTDWClientSQL1.ParamCount - 1 do
          begin
            RESTDWClientSQL1.ParamByName(RESTDWClientSQL1.Params[i].Name).Value := variant(lparams.Items[i]);
          end;
        except
          on e: exception do
          begin
            showmessage('Erro na passagem de parametros para a Query ! ' + e.Message);
            abort;
          end
          else
            abort;
        end;
      end;
    end;

    RESTDWClientSQL1.Open;
    sw.Stop;

    elapsedMilliseconds := sw.ElapsedMilliseconds;
  finally
    sw.Free;
    RESTDWClientSQL1.EnableControls;
  end;
  ltempo.Caption:= 'Tempo de resposta: '+inttostr(elapsedMilliseconds) + 'Milisegundos';
end;

procedure TForm2.Button2Click(Sender: TObject);
var
  vError: string;
begin
  RESTDWDataBase1.Close;
  RESTDWDataBase1.PoolerService := eHost.Text;
  RESTDWDataBase1.PoolerPort := StrToInt(ePort.Text);
  RESTDWDataBase1.Login := edUserNameDW.Text;
  RESTDWDataBase1.Password := edPasswordDW.Text;
  RESTDWDataBase1.Compression := CheckBox1.Checked;
  RESTDWDataBase1.Open;
  RESTDWClientSQL1.Close;
  RESTDWClientSQL1.SQL.Clear;
  RESTDWClientSQL1.SQL.Add(mComando.Text);
  if not RESTDWClientSQL1.ExecSQL(vError) then
    Application.MessageBox(PChar('Erro executando o comando ' + RESTDWClientSQL1.SQL.Text), 'Erro...', mb_iconerror + mb_ok)
  else
    Application.MessageBox('Comando executado com sucesso...', 'Informação !!!', mb_iconinformation + mb_ok);
end;

procedure TForm2.delparamClick(Sender: TObject);
begin
  lparams.Items.Delete(lparams.ItemIndex);

end;

procedure TForm2.RESTDWDataBase1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  if FBytesToTransfer = 0 then // No Update File
    Exit;
  ProgressBar1.Position := AWorkCount;
end;

procedure TForm2.RESTDWDataBase1WorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  FBytesToTransfer := AWorkCountMax;
  ProgressBar1.Max := FBytesToTransfer;
  ProgressBar1.Position := 0;
end;

procedure TForm2.RESTDWDataBase1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  ProgressBar1.Position := FBytesToTransfer;
  FBytesToTransfer := 0;
end;

end.

