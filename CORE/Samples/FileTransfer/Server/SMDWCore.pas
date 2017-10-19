unit SMDWCore;

interface

uses Windows, SysUtils, Classes, uDWConsts, uDWConstsData, uDWJSONTools, System.JSON, uDWJSONObject,
     Winapi.ShellAPI, TypInfo, Dialogs, ServerUtils, SysTypes;

Type
{$METHODINFO ON}
  TSMDWCore = class(TServerMethods)
  Private
   Function ChangeBar          (Value        : String)    : String;
   Function FileList : String;
   Function DownloadFile       (Var Params   : TDWParams) : String;Overload;
   Function SendReplicationFile(Var Params   : TDWParams) : String;
   Function GetPathFile(Empresa, TipoEmpresa : String) : String;
  public
   { Public declarations }
   Constructor Create    (aOwner : TComponent); Override;
   Destructor  Destroy; Override;
   Procedure   vReplyEvent(SendType   : TSendEvent;
                           Context    : String;
                           Var Params : TDWParams;
                           Var Result : String);
  End;
{$METHODINFO OFF}

implementation

uses StrUtils, uPrincipal;

Procedure TSMDWCore.vReplyEvent(SendType   : TSendEvent;
                                Context    : String;
                                Var Params : TDWParams;
                                Var Result : String);
Var
 JSONObject : TJSONObject;
Begin
 JSONObject := TJSONObject.Create;
 Case SendType Of
  seGET, sePOST :
   Begin
    If UpperCase(Context) = Uppercase('DownloadFile') Then
     Result := DownloadFile(Params)
    Else If UpperCase(Context) = Uppercase('SendReplicationFile') Then
     Result := SendReplicationFile(Params)
    Else If UpperCase(Context) = Uppercase('FileList') Then
     Result := FileList
    Else
     Begin
      JSONObject.AddPair(TJSONPair.Create('STATUS',   'NOK'));
      JSONObject.AddPair(TJSONPair.Create('MENSAGEM', 'Método não encontrado'));
      Result := JSONObject.ToJSON;
     End;
   End;
 End;
 JSONObject.Free;
End;

Constructor TSMDWCore.Create (aOwner : TComponent);
Begin
 Inherited Create (aOwner);
 OnReplyEvent := vReplyEvent;
End;

Destructor TSMDWCore.Destroy;
Begin
 Inherited Destroy;
End;

Function TSMDWCore.ChangeBar(Value : String) : String;
Begin
 Result := StringReplace(Value, '/', '\', [rfReplaceAll, rfIgnoreCase]);
End;

Function StringToHex(S : String) : String;
Var
 I : Integer;
Begin
 Result:= '';
 For I := 1 To Length(S) Do
  Result:= Result + IntToHex(ord(S[i]),2);
End;

Function TSMDWCore.GetPathFile(Empresa, TipoEmpresa : String) : String;
Begin
 Result := Format('%sREPLICACAO\%s\%s\', [IncludeTrailingPathDelimiter(ExtractFilePath(ParamSTR(0))),
                                          Empresa, TipoEmpresa]);
End;

Function TSMDWCore.SendReplicationFile(Var Params : TDWParams) : String;
Var
 vArquivo, vDiretorio: String;
 JSONValue    : TJSONValue;
 vFileIn,
 vFile        : TMemoryStream;
 Procedure DelFilesFromDir(Directory, FileMask : String; Const DelSubDirs: Boolean = False);
 Var
  SourceLst: string;
  FOS: TSHFileOpStruct;
 Begin
  FillChar(FOS, SizeOf(FOS), 0);
  FOS.Wnd   := 0;
  FOS.wFunc := FO_DELETE;
  SourceLst := IncludeTrailingPathDelimiter(Directory) + FileMask + #0;
  FOS.pFrom := PChar(SourceLst);
  If Not DelSubDirs Then
   FOS.fFlags := FOS.fFlags OR FOF_FILESONLY;
  // Remove the next line if you want a confirmation dialog box
  FOS.fFlags := FOS.fFlags OR FOF_NOCONFIRMATION;
  // Add the next line for a "silent operation" (no progress box)
  // FOS.fFlags := FOS.fFlags OR FOF_SILENT;
  SHFileOperation(FOS);
 End;
Begin
  If (Params.ItemsString['Arquivo']     <> Nil) Then
  Begin
   vDiretorio := '';
   If (Params.ItemsString['Diretorio'] <> Nil) Then
   begin
     if Params.ItemsString['Diretorio'].value <> '' then
     begin
       vDiretorio := IncludeTrailingPathDelimiter(Params.ItemsString['Diretorio'].value);
       ForceDirectories(fServer.DirName + vDiretorio);
     end;
   end;
   JSONValue          := TJSONValue.Create;
   JSONValue.Encoding := GetEncoding(fServer.rspServerFiles.Encoding);
   vArquivo           := fServer.DirName + vDiretorio + Trim(ExtractFileName(Params.ItemsString['Arquivo'].Value));
   If FileExists(vArquivo) Then
    DeleteFile(vArquivo);
   vFileIn            := TMemoryStream.Create;
   Params.ItemsString['FileSend'].SaveToStream(vFileIn);
   Try
    vFileIn.Position   := 0;
    vFileIn.SaveToFile(vArquivo);
    fServer.LoadLocalFiles;
   Finally
    Params.ItemsString['Result'].SetValue(GetStringFromBoolean(vFileIn.Size > 0));
    Result := 'SEND(OK)';
    vFileIn.Clear;
    vFileIn.Free;
   End;
  End;
End;

Function TSMDWCore.DownloadFile(Var Params : TDWParams) : String;
Var
 JSONValue    : TJSONValue;
 vFile        : TMemoryStream;
 vArquivo     : String;
 vFileExport  : TStringStream;
Begin
 If (Params.ItemsString['Arquivo']     <> Nil) Then
  Begin
   JSONValue             := TJSONValue.Create;
   JSONValue.Encoding    := Params.Encoding;
   JSONValue.ObjectValue := ovBlob;
   vArquivo              := fServer.DirName + Trim(Params.ItemsString['Arquivo'].Value);
   If (vArquivo     <> '') Then
    Begin
     Try
      If FileExists(vArquivo) Then
       Begin
        vFile := TMemoryStream.Create;
        Try
         vFile.LoadFromFile(vArquivo);
         vFile.Position  := 0;
        Except

        End;
        JSONValue.LoadFromStream(vFile);
        Result  := JSONValue.ToJSON;
       End;
     Finally
      FreeAndNil(vFile);
      FreeAndNil(JSONValue);
     End;
    End;
  End;
End;

Function TSMDWCore.FileList : String;
Var
 JSONValue   : TJSONValue;
 vArquivo    : String;
 vFileExport : TStringStream;
 List        : TStringList;
Begin
 List               := TStringList.Create;
 GetFilesServer(List);
 JSONValue          := TJSONValue.Create;
 JSONValue.Encoding := GetEncoding(fServer.rspServerFiles.Encoding);
 Try
  vFileExport       := TStringStream.Create(List.Text, JSONValue.Encoding);
  vFileExport.Position  := 0;
  JSONValue.LoadFromStream(vFileExport);
  Result := JSONValue.ToJSON;
 Finally
  FreeAndNil(vFileExport);
  FreeAndNil(List);
  FreeAndNil(JSONValue);
 End;
End;

End.




