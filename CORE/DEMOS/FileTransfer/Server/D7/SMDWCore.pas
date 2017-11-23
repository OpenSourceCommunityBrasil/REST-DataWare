unit SMDWCore;

interface

uses Windows, SysUtils, Classes, uDWConsts, uDWJSONTools, uLkJSON, uDWJSONObject,
     ShellAPI, TypInfo, Dialogs, ServerUtils, SysTypes;

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
   Function    ReplyEvent(SendType   : TSendEvent;
                          Context    : String;
                          Var Params : TDWParams) : String;Override;
  End;
{$METHODINFO OFF}

implementation

uses StrUtils, uPrincipal;

Function TSMDWCore.ReplyEvent(SendType   : TSendEvent;
                              Context    : String;
                              Var Params : TDWParams) : String;
Var
 JSONObject : TlkJSONobject;
Begin
 JSONObject := TlkJSONobject.Create;
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
      JSONObject.Add('STATUS',   'NOK');
      JSONObject.Add('MENSAGEM', 'Método não encontrado');
      Result := JSONObject.Value;
     End;
   End;
 End;
 JSONObject.Free;
End;

Constructor TSMDWCore.Create (aOwner : TComponent);
Begin
 Inherited Create (aOwner);
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
 vArquivo     : String;
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
   JSONValue          := TJSONValue.Create;
   vArquivo           := fServer.DirName + Trim(ExtractFileName(Params.ItemsString['Arquivo'].Value));
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
 JSONValue     : TJSONValue;
 vArquivo      : String;
 vFileExport   : TStringStream;
 vMemoryExport : TMemoryStream;
 List          : TStringList;
Begin
 List               := TStringList.Create;
 GetFilesServer(List);
 JSONValue          := TJSONValue.Create;
 Try
  vFileExport       := TStringStream.Create(List.Text);
  vFileExport.Position  := 0;
  vMemoryExport     := TMemoryStream.Create;
  vMemoryExport.CopyFrom(vFileExport, vFileExport.Size);
  vMemoryExport.Position  := 0;
  JSONValue.LoadFromStream(vMemoryExport);
  Result := JSONValue.ToJSON;
 Finally
  FreeAndNil(vFileExport);
  FreeAndNil(vMemoryExport);
  FreeAndNil(List);
  FreeAndNil(JSONValue);
 End;
End;

End.




