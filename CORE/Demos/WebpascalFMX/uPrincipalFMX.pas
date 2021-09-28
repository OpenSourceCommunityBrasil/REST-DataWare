unit uPrincipalFMX;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uDWAbout,
  System.Zip, uRESTDWBase, FMX.Edit, FMX.StdCtrls, FMX.Controls.Presentation,
  System.IOUtils;

type
  TForm9 = class(TForm)
    bIniciar: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ePorta: TEdit;
    eUsername: TEdit;
    ePassword: TEdit;
    RESTServicePooler1: TRESTServicePooler;
    procedure bIniciarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form9: TForm9;

implementation

Uses uDmServiceFMX, ServerUtils;

{$R *.fmx}

procedure TForm9.bIniciarClick(Sender: TObject);
begin
 RESTServicePooler1.ServerMethodClass     := TServerMethodDM;
 RESTServicePooler1.ServerParams.AuthorizationOption := rdwAOBasic;
 TRDWAuthOptionBasic(RESTServicePooler1.ServerParams.OptionParams).Username := eUsername.Text;
 TRDWAuthOptionBasic(RESTServicePooler1.ServerParams.OptionParams).Password := ePassword.Text;
 RESTServicePooler1.ServicePort           := StrToInt(ePorta.Text);
 RESTServicePooler1.Active                := Not RESTServicePooler1.Active;
 If RESTServicePooler1.Active Then
  bIniciar.Text := 'Desativar'
 Else
  bIniciar.Text := 'Iniciar';
end;

Procedure ExtractFiles(FileName, OutputDir : String);
Var
 ZipFile: TZipFile;
begin
 ZipFile := TZipFile.Create; //Zipfile: TZipFile
 Try
  If FileExists(FileName) then
   Begin
    ZipFile.Open(FileName, zmRead);
    ZipFile.ExtractAll(Outputdir);
    ZipFile.Close;
   End;
 Finally
  ZipFile.Free;
 End;
end;

procedure TForm9.FormCreate(Sender: TObject);
Var
 vFileExists : String;
begin
 vFileExists := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'www/404.html');
 If Not FileExists(vFileExists) Then
  ExtractFiles(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'www/www.zip'),
               System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'www/'));
end;

end.
