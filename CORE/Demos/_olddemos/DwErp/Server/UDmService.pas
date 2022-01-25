{
 Esta Unit é usada para se criar os metodos que serao consumodos pelo DW Core
Desenvolvida Por  : Fabricio Mata de castro
Empresa : Point informática Ltda - www.pointltda.com.br

}





unit UDmService;

interface

uses

  System.SysUtils, System.Classes, uDWDatamodule, uRESTDWPoolerDB,
  uRestDWDriverFD, System.JSON, uDWJSONObject, FireDAC.Comp.Client,
  uDWConstsData, uDWConsts, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Phys.FBDef, FireDAC.Stan.StorageJSON,
  FireDAC.Phys, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Stan.Intf,
  FireDAC.Comp.UI, Data.DB, Datasnap.DBClient, FireDAC.Comp.DataSet,

  uClassePonto, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  JvStringHolder, Vcl.Forms,
  Vcl.Dialogs, System.StrUtils,

  Data.FireDACJSONReflect, FireDAC.Stan.StorageBin, Datasnap.Provider,
  uDWJSONTools;

type
  TServerMetodDM = class(TServerMethodDataModule)
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    RESTDWDriverFD1: TRESTDWDriverFD;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    Server_FDConnection: TFDConnection;
    qry: TFDQuery;
    FDStanStorageBinLink1: TFDStanStorageBinLink;
    FDMem: TFDMemTable;
    Qryapplyupdate: TFDQuery;
    procedure ServerMethodDataModuleReplyEvent(SendType: TSendEvent; Context: string; var Params: TDWParams; var Result: string);
    procedure ServerMethodDataModuleWelcomeMessage(Welcomemsg: string);
  private
    { Private declarations }
    function setarbanco(Pcnpj: string): boolean;
    Function Runsql(Var Params: TDWParams): String;
    Function ApllyUpdadte(Var Params: TDWParams): String;
    function RetornaSequencia(var Params: TDWParams): string;
    Function RetornaSql(Var Params: TDWParams): String;

  public
    { Public declarations }
    vfuncoes: TClassePonto;

  end;

var
  ServerMetodDM: TServerMetodDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uPrincipal, NFDXML;

{$R *.dfm}

function TServerMetodDM.ApllyUpdadte(var Params: TDWParams): String;
Var
  JSONValue: TJSONValue;
  Vqry, _vsql, _Vcnpj: string;

  aTag: WideString;
  j, _Posini: integer;
  ExecSql: TStringList;
  vEncoding: TEncoding;

Begin

  JSONValue := TJSONValue.Create;
  JSONValue.Encoding := GetEncoding(TEncodeSelect(vEncoding));
  ExecSql := TStringList.Create;
  Try
    If (Params.ItemsString['SQL'] <> Nil) Then
      _vsql := StringReplace(Params.ItemsString['SQL'].Value, #$D#$A, '', [rfReplaceAll]);

    If (Params.ItemsString['IDEMPRESA'] <> Nil) Then
      Funcoes.Idempresa:= Params.ItemsString['IDEMPRESA'].Value;

    If (Params.ItemsString['SYS_POINT_CLIENTE'] <> Nil) Then
      Funcoes.IDSYS_POINT_CLIENTE:= Params.ItemsString['SYS_POINT_CLIENTE'].Value;



    If (Params.ItemsString['CNPJ'] <> Nil) Then
      _Vcnpj := Params.ItemsString['CNPJ'].Value;

    if setarbanco(_Vcnpj) then
    begin
      if Server_FDConnection.Connected then
      begin
        Server_FDConnection.StartTransaction;
        try
          while Length(_vsql) > 0 do
          begin
            aTag := 'º';
            _Posini := Pos(aTag, _vsql);
            Vqry := EmptyStr;
            if (_Posini > 0) then
            begin

              Vqry := copy(_vsql, 0, _Posini - 1);

              JSONValue.WriteToDataset(dtFull, Vqry, FDMem);

              ExecSql := funcoes.InSertUpdate(FDMem, JSONValue.tagname);

              for j := 0 to ExecSql.Count - 1 do
                Server_FDConnection.ExecSql(ExecSql.Strings[j]);

              _vsql := copy(_vsql, _Posini + 1, Length(_vsql));

            end
            else
            begin
              Vqry := _vsql;
              JSONValue.WriteToDataset(dtFull, Vqry, FDMem);
              ExecSql := funcoes.InSertUpdate(FDMem, funcoes.peganometabela(Vqry));
              for j := 0 to ExecSql.Count - 1 do
              begin

                Server_FDConnection.ExecSql(ExecSql.Strings[j]);

              end;
              break;
            end;
            if funcoes.Empty(_vsql) then
            begin
              Server_FDConnection.Commit;
              if (Params.ItemsString['RESULTADO'] <> nil) then
                Params.ItemsString['RESULTADO'].SetValue('OK');
            end;

          end;
        except

          on e: exception do
          begin
            Server_FDConnection.Rollback;

            if (Params.ItemsString['RESULTADO'] <> nil) then
              Params.ItemsString['RESULTADO'].SetValue(e.Message);
          end;
        end;
      end;
    end;
  Finally
    FreeAndNil(JSONValue);
    FreeAndNil(ExecSql);
  End;

end;

function TServerMetodDM.RetornaSequencia(var Params: TDWParams): string;

Var
  _vtabela, _vsql, _Vcnpj: string;
  Vparametro: Variant;
  fdQuery: TFDQuery;
  aTag: WideString;
  i, _Posini: integer;
  ASYS_POINT_CLIENTE: string;
  AEmpresa: string;
  ATabela: string;
  ACampo: string;
  Apendencia, Avaloratual: integer;
  FCommand: TFDCommand;
begin

  If (Params.ItemsString['SQL'] <> Nil) Then
    _vsql := Params.ItemsString['SQL'].Value;

  If (Params.ItemsString['CNPJ'] <> Nil) Then
    _Vcnpj := Params.ItemsString['CNPJ'].Value;

  If (Params.ItemsString['TABELA'] <> Nil) Then
    _vtabela := Params.ItemsString['TABELA'].Value;

  if setarbanco(_Vcnpj) then
  begin
    if Server_FDConnection.Connected then
    begin
      i := 0;
      aTag := ',';
      while Length(_vsql) > 0 do
      begin
        _Posini := Pos(aTag, _vsql);
        if (_Posini > 0) then
        begin
          Vparametro := copy(_vsql, 0, _Posini - 1);
          case i of
            0:
              ASYS_POINT_CLIENTE := Vparametro;
            1:
              AEmpresa := Vparametro;
            2:
              ATabela := Vparametro;
            3:
              ACampo := Vparametro;
            4:
              Apendencia := Vparametro;
            5:
              Avaloratual := Vparametro;

          end;
          inc(i);
        end;

        _vsql := copy(_vsql, _Posini + 1, Length(_vsql));

      end;
      fdQuery := TFDQuery.Create(Nil);

      Try
        fdQuery.Connection := Server_FDConnection;
        _vsql := 'select ID_RETORNO from PRC_SEQUENCIADORA( :PSYS_POINT_CLIENTE, :PEMPRESA,:PTABELA,:PCAMPO,:PPENDENCIA,:PVALORATUAL)';

        fdQuery.SQL.Text := _vsql;

        fdQuery.ParamByName('PSYS_POINT_CLIENTE').AsString := ASYS_POINT_CLIENTE;
        fdQuery.ParamByName('PEMPRESA').AsString := AEmpresa;
        fdQuery.ParamByName('PTABELA').AsString := AnsiUpperCase(ATabela);
        fdQuery.ParamByName('PCAMPO').AsString := AnsiUpperCase(ACampo);
        fdQuery.ParamByName('PPENDENCIA').AsInteger := Apendencia;
        fdQuery.ParamByName('PVALORATUAL').AsInteger := Avaloratual;
        fdQuery.Prepare;
        fdQuery.Open;

        if (Params.ItemsString['RESULTADO'] <> nil) then
          Params.ItemsString['RESULTADO'].SetValue(fdQuery.FieldByName('ID_RETORNO').AsString);

      Finally

        FreeAndNil(fdQuery);
      End;

    end;
  end;

end;

function TServerMetodDM.RetornaSql(var Params: TDWParams): String;
Var
  JSONValue: TJSONValue;
  _vtabela, _vsql, _Vcnpj: string;
  fdQuery: TFDQuery;

Begin
  JSONValue := TJSONValue.Create;
  JSONValue.Encoding := GetEncoding(FrmServer.ServerMetodos.Encoding);
  Try
    If (Params.ItemsString['SQL'] <> Nil) Then
      _vsql := Params.ItemsString['SQL'].Value;

    If (Params.ItemsString['CNPJ'] <> Nil) Then
      _Vcnpj := Params.ItemsString['CNPJ'].Value;

    If (Params.ItemsString['TABELA'] <> Nil) Then
      _vtabela := Params.ItemsString['TABELA'].Value;

    if setarbanco(_Vcnpj) then
    begin
      if Server_FDConnection.Connected then
      begin
        fdQuery := TFDQuery.Create(Nil);
        Try
          fdQuery.Connection := Server_FDConnection;
          fdQuery.SQL.Add(_vsql);
          fdQuery.Open;
          JSONValue.LoadFromDataset(_vtabela, fdQuery, True);

          Result := JSONValue.ToJSON;

          if (Params.ItemsString['RESULTADO'] <> nil) then
            Params.ItemsString['RESULTADO'].SetValue(Result);

        Finally
          FreeAndNil(fdQuery);
        End;

      end;
    end;
  Finally
    FreeAndNil(JSONValue);

  End;

end;

function TServerMetodDM.Runsql(var Params: TDWParams): String;
Var
  JSONValue: TJSONValue;
  _vtabela, _vsql, _Vcnpj: string;
  fdQuery: TFDQuery;

Begin
  JSONValue := TJSONValue.Create;
  JSONValue.Encoding := GetEncoding(FrmServer.ServerMetodos.Encoding);
  Try
    If (Params.ItemsString['SQL'] <> Nil) Then
      _vsql := Params.ItemsString['SQL'].Value;

    If (Params.ItemsString['CNPJ'] <> Nil) Then
      _Vcnpj := Params.ItemsString['CNPJ'].Value;

    if setarbanco(_Vcnpj) then
    begin
      if Server_FDConnection.Connected then
      begin
        Try
          fdQuery := TFDQuery.Create(nil);
          try
            fdQuery.Connection := Server_FDConnection;
            fdQuery.SQL.Text := _vsql;
            fdQuery.ExecSql(_vsql);
          finally
            FreeAndNil(fdQuery);
          end;
          if (Params.ItemsString['RESULTADO'] <> nil) then
            Params.ItemsString['RESULTADO'].SetValue('OK');

        except

          if (Params.ItemsString['RESULTADO'] <> nil) then
            Params.ItemsString['RESULTADO'].SetValue('Erro');

        End;

      end;
    end;
  Finally
    FreeAndNil(JSONValue);

  End;

end;

procedure TServerMetodDM.ServerMethodDataModuleReplyEvent(SendType: TSendEvent; Context: string; var Params: TDWParams; var Result: string);
Var
  // JSONObject: TJSONObject;
  _Vcnpj: string;
Begin
  // JSONObject := TJSONObject.Create;
  Case SendType Of
    seGET, sePOST:
      Begin
        If UpperCase(Context) = UpperCase('DownloadFile') Then
          // Result := DownloadFile(Params)
        Else If UpperCase(Context) = UpperCase('SendReplicationFile') Then
          // Result := SendReplicationFile(Params)
        Else If UpperCase(Context) = UpperCase('FileList') Then
          // Result := FileList
        Else If UpperCase(Context) = UpperCase('runsql') Then
          Result := Runsql(Params)
        Else If UpperCase(Context) = UpperCase('ApllyUpdadte') Then
          Result := ApllyUpdadte(Params)
        Else If UpperCase(Context) = UpperCase('RestonaId') Then
          Result := RetornaSequencia(Params)

        Else
        Begin
          If (Params.ItemsString['CNPJ'] <> Nil) Then
            _Vcnpj := Params.ItemsString['CNPJ'].Value;
          if _Vcnpj <> EmptyStr then
            setarbanco(_Vcnpj);
        End;

      End;
  End;
  // JSONObject.Free;
End;

procedure TServerMetodDM.ServerMethodDataModuleWelcomeMessage(Welcomemsg: string);
begin

  setarbanco(Welcomemsg);

end;

function TServerMetodDM.setarbanco(Pcnpj: string): boolean;
Var
  PontoInf: boolean;
  dataXML: TNFDXML;
  aNodeRootList: TXmlNode;
  aTempNode, aTempNode2: TXmlNode;
  j, i: integer;
  SL, SL_Decrypted: TStringList;
  servidor: string;
Begin

  dataXML := TNFDXML.Create;
  SL := TStringList.Create;
  SL_Decrypted := TStringList.Create;

  try

    SL.LoadFromFile(ExtractFilepath(Application.Exename) + 'data_config.xml');

    for i := 0 to SL.Count - 1 do
      SL_Decrypted.Add(string(funcoes.Decrypt(string(SL.Strings[i]), 2801)));

    dataXML.ReadFromString(SL_Decrypted.Text);
    dataXML.XmlFormat := xfReadable;

    if not Assigned(dataXML.Root) or (funcoes.SoNumeros(Pcnpj) = EmptyStr) then
    begin
      showmessage('Sem arquivo de configuração ( data_config.xml )');
      Application.Terminate;
      Exit;
      Abort;
    end;

    aNodeRootList := dataXML.RootNodeList;
    with aNodeRootList do
    begin
      for i := 0 to NodeCount - 1 do
      begin
        Result := false;
        aTempNode := Nodes[i];
        for j := 0 to aTempNode.NodeCount - 1 do
        begin
          aTempNode2 := aTempNode.Nodes[j];

          if funcoes.Empty(aTempNode2.AttributeByName['file_path']) then
            Continue;

          // PontoInf := AnsiSameText(Trim(aTempNode2.AttributeByName['pontoinf']), '1');

          if Trim(Pcnpj) = Trim(aTempNode2.AttributeByName['cnpj']) then
          begin
            Server_FDConnection.Connected := false;
            servidor := IfThen(Trim(string(aTempNode2.AttributeByName['dbserver_host'])) = EmptyStr, 'localhost',
              string(aTempNode2.AttributeByName['dbserver_host']));
            Server_FDConnection.Params.Clear;
            Server_FDConnection.Params.Add('DriverID=FB');
            Server_FDConnection.Params.Add('Server=' + servidor);
            Server_FDConnection.Params.Add('Port=' + '3050');
            Server_FDConnection.Params.Add('Database=' + string(aTempNode2.AttributeByName['file_path']));
            Server_FDConnection.Params.Add('User_Name=' + 'SYSDBA');
            Server_FDConnection.Params.Add('Password=' + 'masterkey');
            Server_FDConnection.Params.Add('Protocol=TCPIP');
            Server_FDConnection.Params.Add('CharacterSet=WIN1252');
            Server_FDConnection.UpdateOptions.CountUpdatedRecords := false;
            Server_FDConnection.Connected := True;
            Result := True;

          end;
        end;
      end;

    end;
  finally
    SL.Free;
    SL_Decrypted.Free;

    dataXML.Free;
  end;

end;

initialization

funcoes := TClassePonto.Create;

finalization

funcoes.Free;

end.
