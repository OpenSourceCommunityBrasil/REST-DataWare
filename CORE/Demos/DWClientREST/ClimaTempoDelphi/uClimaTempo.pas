unit uClimaTempo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Vcl.StdCtrls, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uDWConstsData, uRESTDWPoolerDB, uDWResponseTranslator,
  uDWAbout, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Imaging.pngimage,
  uDWDataset, Vcl.ComCtrls;


type  TBusca = (tCod, tCid);

type
  TfrmClimaTempo = class(TForm)
    DWClientRESTClima: TDWClientREST;
    DWResponseClima: TDWResponseTranslator;
    DWClima: TRESTDWClientSQL;
    imPrevisao: TImage;
    cbRetornoPais: TComboBox;
    memWeather: TFDMemTable;
    memMain: TFDMemTable;
    lbl_temp: TLabel;
    lbl_descricao: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lbl_max: TLabel;
    lbl_min: TLabel;
    lbl_umidade: TLabel;
    lbl_vento: TLabel;
    DWClientRESTIcon: TDWClientREST;
    lbl_Cidade: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    edToken: TEdit;
    btnCod: TButton;
    btCidade: TButton;
    Label3: TLabel;
    edCodCid: TEdit;
    Label8: TLabel;
    edCidade: TEdit;
    Label9: TLabel;
    edUF: TEdit;
    edtCodCidClimaTempo: TLabeledEdit;
    edtTokenClimaTempo: TLabeledEdit;
    Button1: TButton;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    Memo1: TMemo;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    DataSource3: TDataSource;
    lbl_Data: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure ExecuteApi(Busca : TBusca);
    procedure ExecutaApiClimaTempo(Busca: TBusca);
    procedure btnCodClick(Sender: TObject);
    procedure btCidadeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
   sPath : String;
   Procedure GetImageByUrl(URL: string; APicture: TPicture);
  public
    { Public declarations }
  end;

const
  vToken = '';

var
  frmClimaTempo: TfrmClimaTempo;


implementation

uses
  uDWJSONObject, uDWConsts, Web.HTTPApp;

{$R *.dfm}

{ TfrmClimaTempo }


Procedure TfrmClimaTempo.GetImageByUrl(URL: string; APicture: TPicture);
Var
 Png  : Tpngimage;
 Strm : TMemoryStream;
Begin
 Screen.Cursor := crHourGlass;
 Png := Tpngimage.Create;
 Strm := TMemoryStream.Create;
 Try
  If Trim(DWClientRESTClima.ProxyOptions.ProxyServer) <> '' then
   Begin
    DWClientRESTIcon.ProxyOptions.BasicAuthentication := DWClientRESTClima.ProxyOptions.BasicAuthentication;
    DWClientRESTIcon.ProxyOptions.ProxyServer         := DWClientRESTClima.ProxyOptions.ProxyServer;
    DWClientRESTIcon.ProxyOptions.ProxyPort           := DWClientRESTClima.ProxyOptions.ProxyPort;
    DWClientRESTIcon.ProxyOptions.ProxyUsername       := DWClientRESTClima.ProxyOptions.ProxyUsername;
    DWClientRESTIcon.ProxyOptions.ProxyPassword       := DWClientRESTClima.ProxyOptions.ProxyPassword;
   End;
  DWClientRESTIcon.Get(URL, Nil, Strm);
  If (Strm.Size > 0) then
   Begin
    Strm.Position := 0;
    Png.LoadFromStream(Strm);
    APicture.Assign(Png);
   End;
 Finally
  Strm.Free;
  Png.Free;
  Screen.Cursor := crDefault;
 End;
End;

procedure TfrmClimaTempo.btCidadeClick(Sender: TObject);
begin
  ExecuteApi(tCid);
end;

procedure TfrmClimaTempo.btnCodClick(Sender: TObject);
begin
  ExecuteApi(tCod);
end;

procedure TfrmClimaTempo.Button1Click(Sender: TObject);
begin
ExecutaApiClimaTempo(TCod);
end;

procedure TfrmClimaTempo.ExecutaApiClimaTempo(Busca: TBusca);
var  AUrl: string;
     vTempJson: String;
     pathImg  : String;
     vJson    : TJSONValue;
     DwTranslator: TDWResponseTranslator;
begin
  try

    Screen.Cursor := crSQLWait;
    sPath:= '';
    case Busca of
      tCod:
      begin
        if (edtCodCidClimaTempo.Text = '') then
        begin
          ShowMessage('Digite um código de cidade');
          if edtCodCidClimaTempo.CanFocus then
             edtCodCidClimaTempo.SetFocus;

          exit;
        end;
        //AUrl := format('http://api.openweathermap.org/data/2.5/weather?id=%s&appid=%s&units=metric&lang=%s',[edCodCid.Text,edToken.Text,Copy(cbRetornoPais.Text, 0, 2)]);
        AUrl := 'http://apiadvisor.climatempo.com.br/api/v1/weather/locale/'+edtCodCidClimaTempo.Text+'/current?token='+edtTokenClimaTempo.Text;
      end;
      //tCid:
      //begin
      //  if (edCidade.Text = '') and (edUF.Text = '') then
      //  begin
      //    ShowMessage('Digite uma cidade');
      //    exit;
      //  end;
      //  AUrl := format('http://api.openweathermap.org/data/2.5/weather?q=%s,%s&appid=%s&units=metric&lang=%s',[HTTPEncode(edCidade.Text),edUF.Text,edToken.Text, Copy(cbRetornoPais.Text, 0, 2)]);
      //end;
    end;

    try
      DWClima.Close;
      DWResponseClima.FieldDefs.Clear;
      DWResponseClima.RequestOpenUrl:= AUrl;
      DWClima.FieldDefs.Clear;
      DWClima.Fields.Clear;
      DWClima.Open;

      Memo1.Lines.Text:=DWResponseClima.Open(rtGet,AUrl);
    except
      Exception.Create('Erro ao ler URL! Tente novamente!');
    end;


    if (DWClima.FieldCount > 1) then
    begin
      lbl_Cidade.Caption:=DWClima.FieldByName('name').AsString+'-'+DWClima.FieldByName('state').AsString;


      vJson         := TJSONValue.Create;
      DwTranslator  := TDWResponseTranslator.Create(self);

      vTempJson:= DWClima.FieldByName('data').AsString;
      vJson.WriteToDataset(vTempJson, memMain, DwTranslator, rtJSONAll);

      if not memMain.IsEmpty then
      begin
        lbl_descricao.Caption := memMain.FieldByName('condition').AsString;
        lbl_temp.Caption      := memMain.FieldByName('temperature').AsString;
        lbl_max.Caption       := 'Não Há';//memMain.FieldByName('temp_max').AsString + 'ºc';
        lbl_min.Caption       := 'Não Há';//memMain.FieldByName('temp_min').AsString + 'ºc';
        lbl_umidade.Caption   := memMain.FieldByName('humidity').AsString + '%';
        lbl_vento.Caption     := memMain.FieldByName('wind_velocity').AsString+ 'km';;
        lbl_Data.Caption      := 'Atualizado em:'+memMain.FieldByName('Date').AsString;
      end;


      //DwTranslator.FieldDefs.Clear;
      //vTempJson:= DWClima.FieldByName('weather').AsString;
      //vJson.WriteToDataset(vTempJson, memWeather, DwTranslator, rtJSONAll);

     // if not memWeather.IsEmpty then
     // begin
     //   lbl_descricao.Caption   := memWeather.FieldByName('description').AsString;
        //GetImageByUrl('http://openweathermap.org/img/w/'+memMain.FieldByName('icon').AsString+'.png', imPrevisao.Picture);

        sPath   := sPath + 'imagens\'+ memMain.FieldByName('icon').AsString +'.png';
        if (sPath <> EmptyStr) then
          imPrevisao.Picture.LoadFromFile(sPath);

      //end;
    end;
  finally
    vJson.Free;
    DwTranslator.Free;
    Screen.Cursor := crDefault;
  end;

end;

procedure TfrmClimaTempo.ExecuteApi(Busca: TBusca);
var  AUrl: string;
     vTempJson: String;
     pathImg  : String;
     vJson    : TJSONValue;
     DwTranslator: TDWResponseTranslator;
begin
  try
    Screen.Cursor := crSQLWait;
    sPath:= '';
    case Busca of
      tCod:
      begin
        if (edCodCid.Text = '') then
        begin
          ShowMessage('Digite um código de cidade');
          exit;
        end;
        AUrl := format('http://api.openweathermap.org/data/2.5/weather?id=%s&appid=%s&units=metric&lang=%s',[edCodCid.Text,edToken.Text,Copy(cbRetornoPais.Text, 0, 2)]);
      end;
      tCid:
      begin
        if (edCidade.Text = '') and (edUF.Text = '') then
        begin
          ShowMessage('Digite uma cidade');
          exit;
        end;
        AUrl := format('http://api.openweathermap.org/data/2.5/weather?q=%s,%s&appid=%s&units=metric&lang=%s',[HTTPEncode(edCidade.Text),edUF.Text,edToken.Text, Copy(cbRetornoPais.Text, 0, 2)]);
      end;
    end;

    try
      DWClima.Close;
      DWResponseClima.FieldDefs.Clear; //Adicionado para corrigir o erro
      DWResponseClima.RequestOpenUrl:= AUrl;
      DWClima.FieldDefs.Clear;
      DWClima.Fields.Clear;
      DWClima.Open;

      Memo1.Lines.Text:=DWResponseClima.Open(rtGet,AUrl);
    except
      Exception.Create('Erro ao ler URL! Tente novamente!');
    end;

    if (DWClima.FieldCount > 1) then
    begin
      //Nome da cidade
      lbl_Cidade.Caption:=DWClima.FieldByName('name').AsString;

      vJson         := TJSONValue.Create;
      DwTranslator  := TDWResponseTranslator.Create(self);

      vTempJson:= DWClima.FieldByName('main').AsString;
      memMain.Close;
      memMain.FieldDefs.Clear;
      memMain.Fields.Clear;
      vJson.WriteToDataset(vTempJson, memMain, DwTranslator, rtJSONAll);

      if not memMain.IsEmpty then
      begin
        lbl_temp.Caption      := Copy(memMain.FieldByName('temp').AsString, 0,2);
        lbl_max.Caption       := memMain.FieldByName('temp_max').AsString + 'ºc';
        lbl_min.Caption       := memMain.FieldByName('temp_min').AsString + 'ºc';
        lbl_umidade.Caption   := memMain.FieldByName('humidity').AsString + '%';
        lbl_vento.Caption     := Copy(memMain.FieldByName('pressure').AsString, 0,2) + 'km';;
        lbl_Data.Caption      := 'Atualizado em:'+DateTimeToStr(now);
      end;


      DwTranslator.FieldDefs.Clear;
      vTempJson:= DWClima.FieldByName('weather').AsString;
      vJson.WriteToDataset(vTempJson, memWeather, DwTranslator, rtJSONAll);

      if not memWeather.IsEmpty then
      begin
        lbl_descricao.Caption   := memWeather.FieldByName('description').AsString;
        GetImageByUrl('http://openweathermap.org/img/w/'+memWeather.FieldByName('icon').AsString+'.png', imPrevisao.Picture);
        {
        sPath   := sPath + 'imagens\'+ memWeather.FieldByName('icon').AsString +'.png';
        if (sPath <> EmptyStr) then
          imPrevisao.Picture.LoadFromFile(sPath);
        } // decrepted
      end;
    end;
  finally
    vJson.Free;
    DwTranslator.Free;
    Screen.Cursor := crDefault;
  end;

end;

procedure TfrmClimaTempo.FormCreate(Sender: TObject);
begin
  sPath:= ExtractFilePath(Application.ExeName);
end;

end.

