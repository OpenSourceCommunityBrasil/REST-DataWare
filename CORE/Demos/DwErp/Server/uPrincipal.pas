{
 Esta Unit Contem a funcão que atualiza o banco  [ UpdateDB ]
 Desenvolvida Por  : Fabricio Mata de castro
Empresa : Point informática Ltda - www.pointltda.com.br

}


unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uRESTDWBase, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  Data.DBXFirebird, Data.DB, Data.SqlExpr, uUpdateDB, uClassePonto,
  System.Math, System.StrUtils, UDMservice, Vcl.ComCtrls, JvStringHolder,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TFrmServer = class(TForm)
    ServerMetodos: TRESTServicePooler;
    cbEncode: TCheckBox;
    Bevel1: TBevel;
    ButtonStart: TButton;
    Label13: TLabel;
    Bevel2: TBevel;
    cbPoolerState: TCheckBox;
    SQLConnection: TSQLConnection;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label18: TLabel;
    memoReq: TMemo;
    Label19: TLabel;
    memoResp: TMemo;
    lbLocalFiles: TListBox;
    tupdatelogs: TTimer;
    ScriptMaster: TJvStrHolder;
    Image1: TImage;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ServerMetodosLastRequest(Value: string);
    procedure ServerMetodosLastResponse(Value: string);
    procedure tupdatelogsTimer(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
    vLastRequest, vLastRequestB,

      DirName: String;
    Procedure LoadLocalFiles;
  end;

Function GetFilesServer(Const List: TStrings): Boolean;

var
  FrmServer: TFrmServer;
  StartDir: String;

implementation

{$R *.dfm}

uses NFDXML;

Function GetFilesServer(Const List: TStrings): Boolean;
  procedure ScanFolder(const Path: String; List: TStrings);
  var
    sPath: string;
    rec: TSearchRec;
  begin
    sPath := IncludeTrailingPathDelimiter(Path);
    if FindFirst(sPath + '*.*', faAnyFile, rec) = 0 then
    begin
      repeat
        if (rec.Attr and faDirectory) <> 0 then
        begin
          if (rec.Name <> '.') and (rec.Name <> '..') then
            ScanFolder(IncludeTrailingPathDelimiter(sPath + rec.Name), List);
        end
        else
        begin
          if pos(StartDir, Path) > 0 then
            List.Add(copy(Path, length(StartDir) + 1, length(Path)) + rec.Name)
          else
            List.Add(Path + rec.Name);
        end;
      until FindNext(rec) <> 0;
      FindClose(rec);
    end;
  end;

Begin
  If Not Assigned(List) Then
  Begin
    Result := False;
    Exit;
  end;
  ScanFolder(StartDir, List);
  Result := (List.Count > 0);
End;

Procedure TFrmServer.LoadLocalFiles;
Var
  List: TStringList;
  I: Integer;
Begin
  lbLocalFiles.Clear;
  List := TStringList.Create;
  DirName := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + IncludeTrailingPathDelimiter('filelist');
  StartDir := DirName;
  If Not DirectoryExists(DirName) Then
    ForceDirectories(DirName);
  If GetFilesServer(List) Then
  Begin
    For I := 0 To List.Count - 1 Do
      lbLocalFiles.AddItem(List[I], Nil);
  End;
  List.Free;
End;

procedure TFrmServer.ServerMetodosLastRequest(Value: string);
begin
  vLastRequest := Value;
  tupdatelogs.Enabled := True;
end;

procedure TFrmServer.ServerMetodosLastResponse(Value: string);
begin
  vLastRequestB := Value;
  tupdatelogs.Enabled := True;
end;

procedure TFrmServer.tupdatelogsTimer(Sender: TObject);
Var
  vTempLastRequest, vTempLastRequestB: String;
begin

  Try
    vTempLastRequest := vLastRequest;
    vTempLastRequestB := vLastRequestB;
    If (vTempLastRequest <> '') Then
    Begin
      If memoReq.Lines.Count > 0 Then
        If memoReq.Lines[memoReq.Lines.Count - 1] = vTempLastRequest Then
          Exit;
      If memoReq.Lines.Count = 0 Then
        memoReq.Lines.Add(copy(vTempLastRequest, 1, 100))
      Else
        memoReq.Lines[memoReq.Lines.Count - 1] := copy(vTempLastRequest, 1, 100);
      If length(vTempLastRequest) > 1000 Then
        memoReq.Lines[memoReq.Lines.Count - 1] := memoReq.Lines[memoReq.Lines.Count - 1] + '...';
      If memoResp.Lines.Count > 0 Then
        If memoResp.Lines[memoResp.Lines.Count - 1] = vTempLastRequestB Then
          Exit;
      If memoResp.Lines.Count = 0 Then
        memoResp.Lines.Add(copy(vTempLastRequestB, 1, 100))
      Else
        memoResp.Lines[memoResp.Lines.Count - 1] := copy(vTempLastRequestB, 1, 100);
      If length(vTempLastRequest) > 1000 Then
        memoResp.Lines[memoResp.Lines.Count - 1] := memoResp.Lines[memoResp.Lines.Count - 1] + '...';
    End;
  Finally
    tupdatelogs.Enabled := False;
  End;
end;

procedure TFrmServer.ButtonStartClick(Sender: TObject);
begin
  If Not ServerMetodos.Active Then
  Begin
    ServerMetodos.ServerParams.HasAuthentication := True;
    ServerMetodos.ServerParams.UserName := 'point';
    ServerMetodos.ServerParams.Password := 'gadu!@##@!';
    ServerMetodos.ServicePort := 8080;
    ServerMetodos.Active := True;

    If Not ServerMetodos.Active Then
      Exit;
    ButtonStart.Caption := 'Desativar';
    LoadLocalFiles;
  End
  Else
  Begin
    ServerMetodos.Active := False;
    ButtonStart.Caption := 'Ativar';
    lbLocalFiles.Clear;
  End;
end;

procedure TFrmServer.FormCreate(Sender: TObject);
Var
  sSQL: string;
  PontoInf: Boolean;
  dataXML: TNFDXML;
  aNodeRootList: TXmlNode;
  aTempNode, aTempNode2: TXmlNode;
  j, I: Integer;
  SL, SL_Decrypted: TStringList;
  AtualizouBD: Boolean;
  Qry: TSQLDataSet;
Begin

  if (funcoes.UpdateDB) then
  begin
    dataXML := TNFDXML.Create;
    SL := TStringList.Create;
    SL_Decrypted := TStringList.Create;
    Qry := TSQLDataSet.Create(nil);
    DM_UpdateDB := TDM_UpdateDB.Create(nil);
    try

      SL.LoadFromFile(ExtractFilePath(Application.ExeName) + 'data_config.xml');

      for I := 0 to SL.Count - 1 do
        SL_Decrypted.Add(string(funcoes.Decrypt(string(SL.Strings[I]), 2801)));

      dataXML.ReadFromString(SL_Decrypted.Text);
      dataXML.XmlFormat := xfReadable;

      if not Assigned(dataXML.Root) then
      begin
        ShowMessage('Sem arquivo de configuração ( data_config.xml )');
        Application.Terminate;
        Exit;
        Abort;
      end;

      AtualizouBD := False;
      aNodeRootList := dataXML.RootNodeList;
      with aNodeRootList do
      begin
        for I := 0 to NodeCount - 1 do
        begin
          aTempNode := Nodes[I];
          for j := 0 to aTempNode.NodeCount - 1 do
          begin
            aTempNode2 := aTempNode.Nodes[j];

            if funcoes.Empty(aTempNode2.AttributeByName['file_path']) then
              Continue;

            if (aTempNode2.AttributeByName['ativo'] = '1') then
            begin

              PontoInf := AnsiSameText(Trim(aTempNode2.AttributeByName['pontoinf']), '1');
              SQLConnection.Connected := False;
              // SQLConnection.ConnectionName := 'FBCOMERX3C';
              // SQLConnection.DriverName := 'FIREBIRD';
              SQLConnection.GetDriverFunc := 'getSQLDriverINTERBASE';
              SQLConnection.LibraryName := 'dbxfb.dll';
              SQLConnection.VendorLib := 'fbclient.dll';
              SQLConnection.Params.Values['hostname'] := IfThen(Trim(string(aTempNode2.AttributeByName['dbserver_host'])) = EmptyStr,
                'localhost', string(aTempNode2.AttributeByName['dbserver_host']));
              SQLConnection.Params.Values['database'] := string(aTempNode2.AttributeByName['file_path']);
              SQLConnection.Params.Values['user_name'] := IfThen(Trim(string(aTempNode2.AttributeByName['dbserver_username'])) = EmptyStr,
                'SYSDBA', string(aTempNode2.AttributeByName['dbserver_username']));
              SQLConnection.Params.Values['Password'] := IfThen(Trim(string(aTempNode2.AttributeByName['dbserver_password'])) = EmptyStr,
                'masterkey', string(aTempNode2.AttributeByName['dbserver_password']));
              SQLConnection.Params.Values['servercharset'] := 'WIN1252';
              SQLConnection.LoadParamsOnConnect := False;
              SQLConnection.Connected := True;

              Qry.SQLConnection := SQLConnection;
              Qry.CommandText := 'select VERSAO_APP from SYS_CONFIGAPP where indice=1';
              Qry.Open;

              DM_UpdateDB.DoUpdateDB(aTempNode2.AttributeByName['file_path'],
                IfThen(Trim(string(aTempNode2.AttributeByName['dbserver_username'])) = EmptyStr, 'SYSDBA',
                string(aTempNode2.AttributeByName['dbserver_username'])),
                IfThen(Trim(string(aTempNode2.AttributeByName['dbserver_password'])) = EmptyStr, 'masterkey',
                string(aTempNode2.AttributeByName['dbserver_password'])), 'fbclient.dll', ScriptMaster.Strings);

              sSQL := 'UPDATE OR INSERT INTO SYS_CONFIGAPP (INDICE, VERSAO_APP) VALUES (1, ' + quotedstr(string(funcoes.PegaVersao)) +
                ') MATCHING (INDICE)';
              SQLConnection.ExecuteDirect(sSQL);

              AtualizouBD := True;
            end;

          end;
        end;

      end;
    finally
      DM_UpdateDB.Free;
      SL.Free;
      SL_Decrypted.Free;
      Qry.Free;
      dataXML.Free;

    end;
  end;

  if AtualizouBD then
    Application.Terminate
  else
    FrmServer.Hide;

  ServerMetodos.ServerMethodClass := TServerMetodDM;

  // ServerMetodos.ServerMethodClass := TSMDWCore;
end;

end.
