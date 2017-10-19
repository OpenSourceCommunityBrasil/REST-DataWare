unit uUpdateDB;

interface

uses
// CodeSiteLogging,
{$IFDEF COMPILER7_UP}
  Windows, Forms, StdCtrls, Controls, SysUtils, Classes, ExtCtrls,
    Graphics, JvDataEmbedded;
{$ELSE}
  Windows, vcl.Forms, vcl.StdCtrls, vcl.Controls, SysUtils, Classes, vcl.ExtCtrls, vcl.Graphics,
    JvDataEmbedded;
{$ENDIF COMPILER7_UP}
type
  TDM_UpdateDB = class(TDataModule)
    arqIBE: TJvDataEmbedded;
  private
    { Private declarations }
    function CreateProcessSimple(cmd: string): boolean;
  public
    { Public declarations }
    procedure DoUpdateDB(DBFile, DBUser, DBPassword, DBLibName: string;
      ScriptOficial: TStrings);
  end;

var
  DM_UpdateDB: TDM_UpdateDB;

implementation

{$R *.dfm}

function TDM_UpdateDB.CreateProcessSimple(cmd: string): boolean;
var
  SUInfo: TStartupInfo;
  ProcInfo: TProcessInformation;

begin
  FillChar(SUInfo, SizeOf(SUInfo), #0);
  SUInfo.cb := SizeOf(SUInfo);
  SUInfo.dwFlags := STARTF_USESHOWWINDOW;
  SUInfo.wShowWindow := SW_HIDE;

  Result := CreateProcess(nil, PChar(cmd), nil, nil, false, CREATE_NEW_CONSOLE or
    NORMAL_PRIORITY_CLASS, nil, nil, SUInfo, ProcInfo);

  if (Result) then
  begin
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);

    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end;
end;

procedure TDM_UpdateDB.DoUpdateDB(DBFile, DBUser, DBPassword, DBLibName: string;
  ScriptOficial: TStrings);
var
  sAppPath, sMasterFile, sClientFile, sDifFile, sArqExec: string;
  VL: TStringList;

var
  vForm: TForm;
  vLabel: TLabel;
  vBevel: TBevel;
  vtexto: string;
begin
  vForm := TForm.Create(Application);
  vForm.BorderStyle := bsNone;
  vForm.Position := poDesktopCenter;
  vForm.Width := 250;
  vForm.Height := 150;

  vBevel := TBevel.Create(Application);
  vBevel.Parent := vForm;
  vBevel.Align := alClient;
  vBevel.Shape := bsFrame;

  vLabel := TLabel.Create(vForm);
  vLabel.Parent := vForm;
  vLabel.AutoSize := False;
  vLabel.Alignment := taCenter;
  vLabel.Align := alClient;
  vLabel.Layout := tlCenter;
  vLabel.WordWrap := True;
  vLabel.Font.Size := 10;
  vLabel.Font.Style := [fsBold];
  vLabel.Caption := 'Atualizando banco de dados, por favor espere...';
  vForm.Show;

  Application.ProcessMessages;

  try
    sAppPath := ExtractFilePath(Application.Exename);
    if not FileExists(sAppPath + 'ibescript.exe') then
      arqIBE.DataSaveToFile(sAppPath + 'ibescript.exe');

    sMasterFile := sAppPath + 'mst' + FormatDateTime('ddmmyyyyhhmmsss', Now) +
      '.sql';
    sClientFile := sAppPath + 'clt' + FormatDateTime('ddmmyyyyhhmmsss', Now) +
      '.sql';
    sDifFile := sAppPath + 'dif' + FormatDateTime('ddmmyyyyhhmmsss', Now) +
      '.sql';
    sArqExec := sAppPath + 'exec' + FormatDateTime('ddmmyyyyhhmmsss', Now) +
      '.sql';

    vtexto := ScriptOficial.Text;

    ScriptOficial.SaveToFile(sMasterFile);

   





    VL := TStringList.Create;
    try
      VL.Add('execute ibeblock');
      VL.Add('as');
      VL.Add('begin');

      VL.Add('create connection DestDB dbname ' + QuotedStr(DBFile));
      VL.Add('password ' + QuotedStr(DBPassword) + ' user ' +
        QuotedStr(DBUser));
      VL.Add('clientlib ' + QuotedStr(DBLibName) + ';');

      VL.Add('cbb = ' +
        QuotedStr('execute ibeblock (LogLine variant) as begin ibec_progress(LogLine); end') + ';');

      VL.Add('res = ibec_BackupDatabase(' + QuotedStr(DBFile) + ',' +
        QuotedStr(ChangeFileExt( DBFile, '.FBK')) + ',' + QuotedStr
        ('ClientLib=' + DBLibName + ';Password=' + DBPassword + '; User=' +
          DBUser + ';') + ', cbb);');

      VL.Add('if (res is not null) then');
      VL.Add('ibec_ShowMessage(''ERRO AO EFETUAR BACKUP: '' + res);');

      VL.Add('ibec_ExtractMetadata(DestDB, ' + QuotedStr(sClientFile) + ', ' +
        QuotedStr('ExtractPrivileges') + ', cbb);');
      VL.Add('ibec_CompareMetadata(' + QuotedStr(sMasterFile) + ',' +
        QuotedStr(sClientFile) + ', ' + QuotedStr(sDifFile) + ',' + QuotedStr('') +
        ', cbb);');

      VL.Add('ibec_ExecSQLScript(DestDB, ' + QuotedStr(sDifFile) + ', ' +
        QuotedStr('ServerVersion=FB25; StopOnError=FALSE') + ', cbb);');

      VL.Add('end;');

    // CodeSite.SendMsg( vl.Text);

      VL.SaveToFile(sArqExec);
  //   ScriptOficial.SaveToFile(sMasterFile);

      if not CreateProcessSimple(sAppPath + 'ibescript.exe ' + sArqExec) then
      begin
        Application.MessageBox('Erro ao executar a Atualização no banco de dados.' + #13#10#13#10 +
          'Por favor, entre imediatamente em contato com o Administrador do sistema.',
            PChar(Application.Title), MB_OK + MB_ICONSTOP);
      end;

    finally
      VL.Free;
      if FileExists(sMasterFile) then
        DeleteFile(sMasterFile);
      if FileExists(sClientFile) then
        DeleteFile(sClientFile);
      if FileExists(sDifFile) then
        DeleteFile(sDifFile);
      if FileExists(sArqExec) then
        DeleteFile(sArqExec);
    end;
  finally
    vForm.Close;
    vLabel.Free;
    vForm.Free;
  end;

end;

end.

