unit uLogin;

interface

uses
  JclWin32, JclSysInfo, ShlObj, ComObj, ActiveX, Registry,
  JvJVCLUtils, JvTypes,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, JvExStdCtrls, JvButton, JvCtrls, DB,
  DBClient, JvExControls, JvLabel,  JvComponentBase,
  JvFormTransparent, jpeg, Mask, JvPageList, JvComputerInfoEx,
  Vcl.ComCtrls, dbxJSON ,
  JvMemoryDataset, Vcl.Imaging.pngimage, JvCombobox;

type
  TFrmLogin = class(TForm)
    Label1: TLabel;
    Label5: TLabel;
    Image3: TImage;
    Shape1: TShape;
    LblVersao: TLabel;
    Bevel1: TBevel;
    LblInfo: TLabel;
    JvPageList1: TJvPageList;
    BtnFinalizar: TJvImgBtn;
    BtnOK: TJvImgBtn;
    JvStandardPage1: TJvStandardPage;
    JvStandardPage2: TJvStandardPage;
    Label7: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    cbEmpresa: TComboBox;
    edUser: TEdit;
    edSenha: TEdit;
    CheckBox3: TCheckBox;
    Label4: TLabel;
    edCNPJ: TMaskEdit;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    JvComputer: TJvComputerInfoEx;
    Image1: TImage;
    JvComboBox1: TJvComboBox;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnFinalizarClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure JvComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FinalizaSistema: Boolean;

  end;

var
  FrmLogin: TFrmLogin;

implementation

uses  uPrincipal, uEnterSenha ,
  uSplashConexao, uDM,  Ufuncoes, NFDXML;
{$R *.dfm}

procedure TFrmLogin.BtnFinalizarClick(Sender: TObject);
begin
  if FinalizaSistema then
  begin
    FrmPrincipal._vfinalisa_sistema := 'S';


    if Assigned(Funcoes) then
      FreeAndNil(Funcoes);

    Application.Terminate;
  end
  else
    ModalResult := mrCancel;
end;

procedure TFrmLogin.BtnOKClick(Sender: TObject);
var
  sSQL, CodUser: string;
  CDS: TClientDataSet;
  MyReg: TRegIniFile;
  vVersaoDB: string;
  //_vsql: string;

//  lURL: string;
//  lResponseget: TStringStream;
//  lResponsepost: TStringStream;
//  lParams: TStringList;

//  i: Int64;
//  jso: TJSONObject;
//  jsop: TJSONPair;

  procedure CreateShortcut(FileName, Parameters, InitialDir, ShortcutName, ShortcutFolder: string);
  var
    MyObject: IUnknown;
    MySLink: IShellLink;
    MyPFile: IPersistFile;
    Directory: string;
    WFileName: WideString;
    MyReg: TRegIniFile;

  begin

    MyObject := CreateComObject(CLSID_ShellLink);
    MySLink := MyObject as IShellLink;
    MyPFile := MyObject as IPersistFile;
    with MySLink do
    begin
      SetArguments(PChar(Parameters));
      SetPath(PChar(FileName));
      SetWorkingDirectory(PChar(InitialDir));
    end;
    MyReg := TRegIniFile.Create('Software\MicroSoft\Windows\CurrentVersion\Explorer');
    Directory := MyReg.ReadString('Shell Folders', 'Desktop', '');
    WFileName := Directory + '\' + ShortcutName + '.lnk';
    MyPFile.Save(PWChar(WFileName), False);
    MyReg.Free;
  end;

begin
  case JvPageList1.ActivePageIndex of
    0: // ID SysPoint
      begin

        FrmSplashConexao := TFrmSplashConexao.Create(nil);
        try
          FrmSplashConexao.JvGradientHeaderPanel1.LabelCaption := 'Conectando ao servidor central...';
          FrmSplashConexao.Memo1.Text := 'Verificando conexão, por favor aguarde...';
          FrmSplashConexao.Memo1.Visible := True;
          FrmSplashConexao.Show;

          dm.Fcnpj := edCNPJ.Text;


          try
              if FileExists(ExtractFilePath(Application.ExeName) + 'libeay32.dll') then
                DeleteFile(PWideChar(ExtractFilePath(Application.ExeName) + 'libeay32.dll'));
              DM.libeay32.DataSaveToFile(ExtractFilePath(Application.ExeName) + 'libeay32.dll');
            except
          end;
          try
              if FileExists(ExtractFilePath(Application.ExeName) + 'ssleay32.dll') then
                DeleteFile(PWideChar(ExtractFilePath(Application.ExeName) + 'ssleay32.dll'));
              DM.ssleay32.DataSaveToFile(ExtractFilePath(Application.ExeName) + 'ssleay32.dll');
          except
          end;

       //   if not Funcoes.DentroFirma then
        //     CreateShortcut(ExtractFilePath(Application.ExeName) + 'SuporteCliente.exe', '', ExtractFilePath(Application.ExeName), 'Suporte OnLine - Point Informática', '');



          Screen.Cursor := crHourGlass;
          try

            LblInfo.Caption := 'Verificando CNPJ, por favor espere...';
            Application.ProcessMessages;
            sSQL := 'select IDSYS_POINT_CLIENTE,idempresa, STATUS, RAZAO_SOCIAL, CNPJ, MENSAGEM from SYS_POINT_CLIENTE where CNPJ = ' + QuotedStr(edCNPJ.Text);

            Funcoes.RetornaSQL(sSQL);

            if dm.Ret_sql.IsEmpty then
            begin
              Application.MessageBox('CNPJ não cadastrado em nosso servidor.', PChar(Application.Title), MB_OK + MB_ICONWARNING);
              Abort;

            end
            else
            begin
              if AnsiSameText( dm.Ret_sql.FieldByName('STATUS').AsString, 'I') then
              begin
                Application.MessageBox(PChar(Format('CNPJ está INATIVADO em nosso servidor.' + #13#10#13#10 + 'Mensagem:' + #13#10 + '%s', [CDS.FieldByName('MENSAGEM').AsString])), PChar(Application.Title), MB_OK + MB_ICONWARNING);
                Abort;
              end
              else
              begin
                if not Funcoes.Empty( dm.Ret_sql.FieldByName('MENSAGEM').AsString) then
                  Application.MessageBox(PChar(Format('Olá, a Point Informática tem uma mensagem para você:' + #13#10#13#10 + '%s', [CDS.FieldByName('MENSAGEM').AsString])), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);

                funcoes.CurrentUser.Idsys_point_cliente := dm.Ret_sql.FieldByName('IDSYS_POINT_CLIENTE').AsString;
                funcoes.CurrentUser.Idempresa := dm.Ret_sql.FieldByName('IDEMPRESA').AsString;
                Funcoes.CurrentUser.RazaoSocial := dm.Ret_sql.FieldByName('RAZAO_SOCIAL').AsString;

                JvPageList1.ActivePageIndex := 1;
                JvComboBox1.Visible := False;

                edUser.SetFocus;

                MyReg := TRegIniFile.Create('Software\DW\');
                try
                  if CheckBox1.Checked then
                    MyReg.WriteString('EMS', 'EMPRESA_CNPJ', edCNPJ.Text);

                  MyReg.WriteBool('EMS', 'EMPRESA_AUT', CheckBox2.Checked);
                finally
                  MyReg.Free;
                end;
              end;
            end;
          finally
            Screen.Cursor := crDefault;
            LblInfo.Caption := EmptyStr;


          end;
        finally
          FrmSplashConexao.Release;
          SetForegroundWindow(Application.Handle);
        end;
      end;
    1:
      begin // Login de Usuário
        if Funcoes.Empty(edUser.Text) or Funcoes.Empty(edSenha.Text) then
        begin
          Application.MessageBox('Digite sua Matrícula e/ou sua Senha para poder continuar.', PChar(Application.Title), MB_OK + MB_ICONWARNING);
          Exit;
        end;

        MyReg := TRegIniFile.Create('Software\Point Informatica\');
        try
          if CheckBox3.Checked then
          begin
            MyReg.WriteString('EMS', 'AUTOLOGIN_USER', edUser.Text);
            MyReg.WriteString('EMS', 'AUTOLOGIN_PASSWORD', edSenha.Text);
          end
          else
          begin
            MyReg.DeleteKey('EMS', 'AUTOLOGIN_USER');
            MyReg.DeleteKey('EMS', 'AUTOLOGIN_PASSWORD');
          end;
        finally
          MyReg.Free;
        end;

        Screen.Cursor := crHourGlass;
        try
          sSQL := 'SELECT COUNT(IDSYS_USER) FROM SYS_USER WHERE LOGIN = ' + QuotedStr('POINT');

          Funcoes.RetornaSQL(sSQL);
          if dm.Ret_sql.Fields[0].AsInteger <= 0 then
          begin
            CodUser := Funcoes.RetornaGUID;

            sSQL := 'INSERT INTO SYS_USER (IDSYS_USER, LOGIN, SENHA, NOME_COMPLETO, EMAIL, INATIVE, ADMINISTRADOR, IDSYS_POINT_CLIENTE , MODULO_NET ) VALUES (' + QuotedStr(CodUser) + ', ' + QuotedStr('POINT') + ' , ' +
              QuotedStr(string( Funcoes.Encrypt(AnsiString('SL204'), funcoes.UserKey))) + ', ' + QuotedStr('POINT INFORMÁTICA') + ', ' + QuotedStr('contato@pointltda.com.br') + ', 0, 1,' + QuotedStr(Trim( funcoes.CurrentUser.Idsys_point_cliente )
              ) + ' ,' + QuotedStr('S') + ')';
            Funcoes.RunSQL(sSQL);
          end;

          // Verificando a versao do cliente, se é inferior a ultima atualizada.
          if (not Funcoes.MaquinaDesenvolvedor) then
          begin
           Funcoes.RetornaSQL('select first 1 VERSAO_CLIENT_APP from SYS_CONFIGAPP');
            vVersaoDB := dm.Ret_sql.Fields[0].AsString;
            if Funcoes.Empty(vVersaoDB) then
              vVersaoDB := '0.0.0.0';

            if Funcoes.VersaoMaior(string(Funcoes.Fversao ), vVersaoDB) then
            begin
             funcoes.RunSQL('update SYS_CONFIGAPP set versao_client_app = ' + QuotedStr(string(Funcoes.Fversao )));
            end
            else
            begin
              if not AnsiSameText(vVersaoDB, string(Funcoes.PegaVersao )) then
              begin
                Application.MessageBox('O sistema não poderá continuar, pois a versão dele está inferior à última utilizada para acessar a base de dados.' +
                  #13#10#13#10 + 'Por favor, atualize sua versão e tente novamente.'#13#10#13#10 +
                  'Favor entrar em contato com o suporte da Point Informática imediatamente.',
                  PChar(Application.Title), MB_OK + MB_ICONWARNING);
                BtnFinalizar.Click;
                Exit;
              end;
            end;
          end;

          if AnsiSameText(edUser.Text, 'POINT') then
          begin
            if (not AnsiSameText(edSenha.Text, 'PI' + FormatDateTime('ddmmhh', Now))) then
            begin
              Application.MessageBox('Senha inválida, por favor digite novamente.', PChar(Application.Title), MB_OK + MB_ICONWARNING);
              Exit;
            end
            else
            begin
              sSQL := 'SELECT * FROM SYS_USER ';
              sSQL := sSQL + ' WHERE (LOGIN = ' + QuotedStr(edUser.Text) + ') and ( idsys_point_cliente = ' + Funcoes.GetIDPointCliente + ' ) ';
            end;
          end
          else
          begin
            sSQL := 'SELECT * FROM SYS_USER ';

            sSQL := sSQL + ' WHERE (LOGIN = ' + QuotedStr(edUser.Text) + ') AND (SENHA = ' + QuotedStr(AnsiString(Funcoes.Encrypt(UpperCase(AnsiString(edSenha.Text)),funcoes.UserKey))) + ') and ( idsys_point_cliente = ' +
              Funcoes.GetIDPointCliente + ' ) ';
          end;
          Funcoes.RetornaSQL(sSQL);
          if dm.Ret_sql.IsEmpty then
          begin
            Application.MessageBox('Usuário não cadastrado no sistema...', PChar(Application.Title), MB_OK + MB_ICONINFORMATION);

            Exit;
          end;

          Funcoes.CurrentUser.UserID := dm.Ret_sql.FieldByName('IDSYS_USER').AsString;
          Funcoes.CurrentUser.Priv := (dm.Ret_sql.FieldByName('PRIVILEGIADO').AsString <> '0');
          Funcoes.CurrentUser.Admin := (dm.Ret_sql.FieldByName('ADMINISTRADOR').AsString <> '0');
          Funcoes.CurrentUser.UserLogin := dm.Ret_sql.FieldByName('LOGIN').AsString;
          Funcoes.CurrentUser.UserPassword := dm.Ret_sql.FieldByName('SENHA').AsString;
          Funcoes.CurrentUser.UserRealName := dm.Ret_sql.FieldByName('NOME_COMPLETO').AsString;
          Funcoes.CurrentUser.UserRights.Text := dm.Ret_sql.FieldByName('UCRIGHTS').AsString;
          Funcoes.CurrentUser.LoadRights(FrmPrincipal);

          sSQL := 'SELECT * FROM EMPRESA';
          Funcoes.RetornaSQL(sSQL);
          dm.CdsEmpresa.LoadFromDataSet(dm.Ret_sql, 0, lmCopy);

          Funcoes.CurrentUser.Idsys_point_cliente := dm.CdsEmpresa.FieldByName('IDSYS_POINT_CLIENTE').AsString;
          Funcoes.CurrentUser.Idempresa := dm.CdsEmpresa.FieldByName('IDEMPRESA').AsString;


          ModalResult := mrOk;
        finally
          Screen.Cursor := crDefault;

        end;

      end;

  end;

end;

procedure TFrmLogin.FormActivate(Sender: TObject);
begin
 

  if (CheckBox1.Checked and CheckBox2.Checked) and (JvPageList1.ActivePageIndex = 0) then
    BtnOK.Click;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
var
  MyReg: TRegIniFile;
  //  _memoria: real;
  //  _configuracao: Boolean;
  //
  //  _vtMemoria, _vtProces, _vtTela: Boolean;

  SL, SL_Decrypted: TStringList;
  i, j: integer;
  dataXML: TNFDXML;
  aNodeRootList: TXmlNode;
  aTempNode, aTempNode2: TXmlNode;

begin
  Funcoes.MaquinaDesenvolvedor := FileExists(Funcoes.FixSlash(ExtractFilePath(Application.ExeName)) + 'point_dev.txt');

  Height := 352;

  edCNPJ.Clear;
  edUser.Clear;
  edSenha.Clear;

  MyReg := TRegIniFile.Create('Software\Point Informatica\');
  try
    edCNPJ.Text := MyReg.ReadString('EMS', 'EMPRESA_CNPJ', '');
    CheckBox1.Checked := False;
    // not Funcoes.Empty(edCNPJ.Text);
    CheckBox2.Checked := MyReg.ReadBool('EMS', 'EMPRESA_AUT', False);

    edUser.Text := MyReg.ReadString('EMS', 'AUTOLOGIN_USER', '');
    edSenha.Text := MyReg.ReadString('EMS', 'AUTOLOGIN_PASSWORD', '');
    CheckBox3.Checked := (not Funcoes.Empty(edUser.Text));

    if Funcoes.MaquinaDesenvolvedor then
    begin
      edUser.Text := 'POINT';
      edSenha.Text := 'PI' + FormatDateTime('ddmmhh', Now);
    end;

  finally
    MyReg.Free;
  end;

  LblVersao.Caption := Funcoes.PegaVersao;

  JvPageList1.ActivePageIndex := 0;

  JvComboBox1.Visible := Funcoes.MaquinaDesenvolvedor;
  if Funcoes.MaquinaDesenvolvedor then
  begin
    SL := TStringList.Create;
    SL_Decrypted := TStringList.Create;
    dataXML := TNFDXML.Create;

    try
      JvComboBox1.Clear;
      SL.LoadFromFile(ExtractFilePath(Application.ExeName) + 'data_config.xml');

      for i := 0 to SL.Count - 1 do
        SL_Decrypted.Add(Funcoes.Decrypt(SL.Strings[i], 2801));

      dataXML.ReadFromString(SL_Decrypted.Text);
      dataXML.XmlFormat := xfReadable;

      if not Assigned(dataXML.Root) then
      begin
        ShowMessage('Arquivo de configuração inválido');
        Application.Terminate;
        Abort;
      end;

      aNodeRootList := dataXML.RootNodeList;
      with aNodeRootList do
      begin
        for i := 0 to NodeCount - 1 do
        begin
          aTempNode := Nodes[i];
          for j := 0 to aTempNode.NodeCount - 1 do
          begin
            aTempNode2 := aTempNode.Nodes[j];

            JvComboBox1.Items.Add(  Trim(aTempNode2.AttributeByName['cnpj'] ) ) ;

          end;
        end;
        JvComboBox1.ItemIndex :=0;
      end;


    finally
     FreeAndNil( SL );
     FreeAndNil( SL_Decrypted );
     FreeAndNil( dataXML );

    end;

  end;

end;

procedure TFrmLogin.JvComboBox1Change(Sender: TObject);
begin
  edCNPJ.Text := JvComboBox1.Text;
end;

end.

