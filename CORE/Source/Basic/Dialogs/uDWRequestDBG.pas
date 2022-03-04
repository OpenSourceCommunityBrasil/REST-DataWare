unit uDWRequestDBG;

{$I uRESTDW.inc}

interface

uses
 {$IFDEF FPC}
  MenuIntf, IDECommands, ToolBarIntf, LCLType, uDWResponseTranslator,
  uDWAbout, DB, uDWDataset, uDWConstsData, uRESTDWPoolerDB, Grids, DBGrids,
  ComCtrls, StdCtrls, Controls, Buttons, ExtCtrls, Classes, Variants, LCL,
  SysUtils
 {$ELSE}
  ToolsAPI, jpeg, Windows, Controls, Buttons, Classes, StdCtrls, ExtCtrls, ComCtrls,
  Grids, DBGrids, uDWAbout, uDWResponseTranslator, DB, uDWDataset, uDWConstsData,
  Messages, SysUtils, Variants, uRESTDWPoolerDB,
  Dialogs
 {$ENDIF}
  , Menus, Forms, Graphics, uDWJSONInterface, uDWConstsCharset, IdSSLOpenSSL, uDWConsts;

Type
 PDWRequestParams = ^TDWRequestParams;
 TDWRequestParams = Record
  Param, Value : String;
End;

Type
 PDWJsonParserItem = ^TDWJsonParserItem;
 TDWJsonParserItem = Class
  ElementName,
  JsonValue : String;
End;

{$IFNDEF FPC}
Type
 TCustomMenuItemDW = class(TNotifierObject, IOTAWizard, IOTAMenuWizard)
  Function GetIDString : String;
  Function GetName     : String;
  Function GetState    : TWizardState;
     // Launch the AddIn
  Procedure Execute;
  Function GetMenuText : String;
 End;
 TCustomMenuHandler = class(TObject)
    // Handle custom menu
  Procedure HandleClick(Sender: TObject);
End;
{$ENDIF}

type

  { TfRequestDebbug }

  TfRequestDebbug = class(TForm)
    paTopo: TPanel;
    Image1: TImage;
    labSistema: TLabel;
    paPortugues: TPanel;
    Image3: TImage;
    paEspanhol: TPanel;
    Image4: TImage;
    paIngles: TPanel;
    Image2: TImage;
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    cbRequestType: TComboBox;
    PageControl1: TPageControl;
    tsAuth: TTabSheet;
    tsHeaders: TTabSheet;
    tsBody: TTabSheet;
    tsProxy: TTabSheet;
    sbSendRequest: TSpeedButton;
    Panel3: TPanel;
    Label2: TLabel;
    Panel4: TPanel;
    cbRequest: TComboBox;
    pcResponse: TPageControl;
    tsJSON: TTabSheet;
    tsRAW: TTabSheet;
    Panel5: TPanel;
    Label3: TLabel;
    TreeView1: TTreeView;
    Panel6: TPanel;
    mRAW: TMemo;
    DataSource1: TDataSource;
    RESTDWClientSQL1: TRESTDWClientSQL;
    DWResponseTranslator1: TDWResponseTranslator;
    DWClientREST1: TDWClientREST;
    cbOAuth0: TCheckBox;
    eUsername: TEdit;
    ePassword: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    cbHaveSSL: TCheckBox;
    eUserAgent: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    eAccept: TEdit;
    Label9: TLabel;
    eContentEncoding: TEdit;
    Label10: TLabel;
    eContentType: TEdit;
    cbProxy: TCheckBox;
    eProxyUsername: TEdit;
    eProxyPassword: TEdit;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    eProxyServer: TEdit;
    eProxyPort: TEdit;
    Label14: TLabel;
    Panel8: TPanel;
    DBGrid1: TDBGrid;
    Label4: TLabel;
    pSSL: TPanel;
    cbSSLv2: TCheckBox;
    cbSSLv23: TCheckBox;
    cbSSLv3: TCheckBox;
    cbTLSv12: TCheckBox;
    cbTLSv11: TCheckBox;
    cbTLSv1: TCheckBox;
    Panel7: TPanel;
    pParamBody: TPanel;
    Panel9: TPanel;
    sbNewParam: TSpeedButton;
    sbDeleteParam: TSpeedButton;
    lvBodyParams: TListView;
    rbParams: TRadioButton;
    rbRawBody: TRadioButton;
    pRAWBody: TPanel;
    mRAWBody: TMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure lvBodyParamsCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvBodyParamsCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure sbNewParamClick(Sender: TObject);
    procedure sbDeleteParamClick(Sender: TObject);
    procedure cbHaveSSLClick(Sender: TObject);
    procedure cbOAuth0Click(Sender: TObject);
    procedure cbProxyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbSendRequestClick(Sender: TObject);
    procedure eContentTypeExit(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure rbParamsClick(Sender: TObject);
    procedure rbRawBodyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
   Procedure SetLVColumnColour(Var Sender    : TCustomListView;
                               ColIdx        : Integer);
   Procedure ChecksState;
   Procedure ValidateRequestResultType(Value : String);
   Procedure BuildRequest;
   Procedure BuildTreeJSON(Value: String);
   Procedure LoadItem;
   Procedure BuildCustomHeaders(var CustomHeaders: TStringList);
   Procedure ClearTree;
   procedure OpenGridRequest(Value: String);
    { Private declarations }
  public
    { Public declarations }
  end;

  Procedure AddIDEMenu;

var
  fRequestDebbug    : TfRequestDebbug;
  mnuitem           : TMenuItem;
  {$IFNDEF FPC}
  CustomMenuHandler : TCustomMenuHandler = Nil;
  NTAServices       : INTAServices;
  {$ENDIF}

implementation

uses uDWReqParamsEditor, ServerUtils;

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

Function CreateItem(TreeView  : TTreeView;
                    treeNode  : TTreeNode;
                    ItemName,
                    JsonValue : String) : TTreeNode;
Var
 vClassName,
 vValue      : String;
 vJsonValue  : PDWJsonParserItem;
 I           : Integer;
 bJsonValue  : TDWJSONObject;
 bJsonValueB : TDWJSONBase;
 bJsonArrayB : TDWJSONArray;
 Function TextClass(Value : String) : String;
 Begin
  If (Lowercase(Value) = Lowercase('TJSONObject')) Or
     (Lowercase(Value) = Lowercase('TDWJSONObject')) Then
   Result := '{}'
  Else If (Lowercase(Value) = Lowercase('TJSONArray')) Or
          (Lowercase(Value) = Lowercase('TDWJSONArray')) Then
   Result := '[]';
 End;
Begin
 vValue        := Trim(JsonValue);
 Result        := Nil;
 If Trim(vValue) <> '' Then
  Begin
   If vValue[InitStrPos] = '{' Then
    Begin
     bJsonValue  := TDWJSONObject.Create(JsonValue);
     If bJsonValue.PairCount > 0 Then
      Begin
       If ItemName <> '' Then
        Begin
         Result := TreeView.Items.AddChild(treeNode, ItemName + ' - ' + TextClass(bJsonValue.Classname));
         New(vJsonValue);
         vJsonValue^             := TDWJsonParserItem.Create;
         vJsonValue^.ElementName := ItemName;
         vJsonValue^.JsonValue   := JsonValue;
         Result.Data             := vJsonValue;
//         vJsonValue^.Free;
//         Dispose(vJsonValue);
        End
       Else
        Result := treeNode;
       For I := 0 To bJsonValue.PairCount -1 Do
        Begin
         vClassName := bJsonValue.Pairs[I].ClassName;
         If (Lowercase(vClassName) = Lowercase('TJSONObject'))   Or
            (Lowercase(vClassName) = Lowercase('TDWJSONObject')) Or
            (Lowercase(vClassName) = Lowercase('TJSONArray'))    Or
            (Lowercase(vClassName) = Lowercase('TDWJSONArray')) Then
          CreateItem(TreeView, Result, bJsonValue.Pairs[I].Name, bJsonValue.Pairs[I].Value)
         Else
          Begin
           If bJsonValue.Pairs[I].Name <> '' Then
            TreeView.Items.AddChild(Result, Format('%s = %s', [bJsonValue.Pairs[I].Name, bJsonValue.Pairs[I].Value]))
           Else
            TreeView.Items.AddChild(Result, bJsonValue.Pairs[I].Value);
          End;
        End;
      End;
     FreeAndNil(bJsonValue);
    End
   Else If vValue[InitStrPos] = '[' Then
    Begin
     bJsonValue  := TDWJSONObject.Create(JsonValue);
     bJsonArrayB := TDWJSONArray(bJsonValue);
     If bJsonArrayB.ElementCount > 0 Then
      Begin
       Result := TreeView.Items.AddChild(treeNode, ItemName + ' - []');
       New(vJsonValue);
       vJsonValue^             := TDWJsonParserItem.Create;
       vJsonValue^.ElementName := ItemName;
       vJsonValue^.JsonValue   := JsonValue;
       Result.Data             := vJsonValue;
//       vJsonValue^.Free;
//       Dispose(vJsonValue);
      End;
     For I := 0 To bJsonArrayB.ElementCount -1 do
      Begin
       Try
        bJsonValueB := bJsonArrayB.GetObject(I);
        vClassName  := '';
        If ((Lowercase(TDWJSONObject(bJsonValueB).tojson) <> 'null') and
            (Lowercase(TDWJSONObject(bJsonValueB).tojson) <> '')) Then
         Begin
          If (TDWJSONObject(bJsonValueB).Classtype = TDWJSONObject) Then
           vClassName  := 'TJSONObject'
          Else
           vClassName  := TDWJSONObject(bJsonValueB).ClassName;
         End;
        If (Lowercase(vClassName) = Lowercase('TJSONObject'))   Or
           (Lowercase(vClassName) = Lowercase('TDWJSONObject')) Or
           (Lowercase(vClassName) = Lowercase('TJSONArray'))    Or
           (Lowercase(vClassName) = Lowercase('TDWJSONArray')) Then
         Begin
          CreateItem(TreeView, TreeView.Items.AddChild(Result, TextClass(vClassName)),
                     '', TDWJSONObject(bJsonValueB).ToJSON);
         End
        Else
         Begin
          If TDWJSONObject(bJsonValueB).Pairs[I].Name <> '' Then
           TreeView.Items.AddChild(Result, Format('%s = %s', [TDWJSONObject(bJsonValueB).Pairs[I].Name, TDWJSONObject(bJsonValueB).Pairs[I].Value]))
          Else
           TreeView.Items.AddChild(Result, TDWJSONObject(bJsonValueB).Pairs[I].Value);
         End;
       Finally
        FreeAndNil(bJsonValueB);
       End;
      End;
     FreeAndNil(bJsonArrayB);
    End;
  End;
End;

Function TrashRemove(Value : String) : String;
Begin
 Result := StringReplace(Value,  #13, '', [rfReplaceAll]);
 Result := StringReplace(Result, #10, '', [rfReplaceAll]);
 Result := StringReplace(Result, #9,  '', [rfReplaceAll]);
End;

Procedure TfRequestDebbug.ClearTree;
Var
 I          : Integer;
 vJsonValue : PDWJsonParserItem;
Begin
 For I := 0 To TreeView1.Items.Count -1 Do
  Begin
   If Assigned(TreeView1.Items[I].Data) Then
    Begin
     vJsonValue := TreeView1.Items[I].Data;
     TDWJsonParserItem(vJsonValue^).Free;
     Dispose(vJsonValue);
    End;
  End;
 TreeView1.Items.Clear;
End;

Procedure TfRequestDebbug.BuildTreeJSON(Value : String);
Var
 I          : Integer;
 bJsonValue : TDWJSONObject;
begin
 If Not tsJSON.TabVisible Then
  Exit;
 Try
  bJsonValue  := TDWJSONObject.Create(TrashRemove(Value));
 Except
  ValidateRequestResultType('');
  Raise Exception.Create('Invalid Request : ' + TrashRemove(Value));
  Exit;
 End;
 try
  ClearTree;
  If bJsonValue.PairCount > 0 Then
   Begin
    For I := 0 To bJsonValue.PairCount -1 Do
     Begin
      If (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TJSONObject'))   Or
         (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TDWJSONObject')) Or
         (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TJSONArray'))    Or
         (Lowercase(bJsonValue.pairs[I].classname) = Lowercase('TDWJSONArray')) Then
       CreateItem(TreeView1, Nil, bJsonValue.pairs[I].Name, bJsonValue.pairs[I].Value)
      Else
       Begin
        CreateItem(TreeView1, Nil, '', bJsonValue.ToJSON);
        Break;
       End;
     End;
   End;
 Finally
  FreeAndNil(bJsonValue);
  TreeView1.FullExpand;
  OpenGridRequest(TrashRemove(Value));
 End;
end;

Procedure TfRequestDebbug.OpenGridRequest(Value : String);
Begin
 RESTDWClientSQL1.Close;
 RESTDWClientSQL1.Fields.Clear;
 RESTDWClientSQL1.FieldDefs.Clear;
 DWResponseTranslator1.FieldDefs.Clear;
 DWResponseTranslator1.ElementRootBaseName := '';
 DBGrid1.Columns.Clear;
 RESTDWClientSQL1.OpenJson(Value);
End;

Procedure TfRequestDebbug.LoadItem;
Begin
 If TreeView1.Selected <> Nil Then
  Begin
   If Assigned(TreeView1.Selected.Data) Then
    OpenGridRequest(TDWJsonParserItem(TreeView1.Selected.Data^).JsonValue);
  End;
End;

Procedure TfRequestDebbug.SetLVColumnColour(Var Sender : TCustomListView;
                                   ColIdx     : Integer);
Const
 cRainbow: array[0..2] of TColor = ($FFCCCC, $CCFFCC, $CCCCFF);
Begin
 TListView(Sender).Canvas.Brush.Color := cRainBow[ColIdx];
End;

procedure TfRequestDebbug.lvBodyParamsCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
 SetLVColumnColour(Sender, 0);
End;

procedure TfRequestDebbug.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
 ClearTree;
 fRequestDebbug := Nil;
 Release;
end;

procedure TfRequestDebbug.lvBodyParamsCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
Begin
 If SubItem = 0 Then Exit;
 SetLVColumnColour(Sender, SubItem);
End;

procedure TfRequestDebbug.sbNewParamClick(Sender: TObject);
Var
 it            : TlistItem;
 RequestParams : PDWRequestParams;
 vItemIndex    : Integer;
 vParamsEditor : TfParamsEditor;
Begin
 it                   := lvBodyParams.Items.add;
 it.Caption           := 'param' + IntToStr(lvBodyParams.Items.Count);
 it.SubItems.Add('value' + IntToStr(lvBodyParams.Items.Count));
 New(RequestParams);
 RequestParams^.Param := it.Caption;
 RequestParams^.Value := Trim(it.SubItems.Text);
 it.Data              := RequestParams;
 vItemIndex           := it.Index;
 vParamsEditor        := TfParamsEditor.Create(Self);
 vParamsEditor.Listitem := it;
 If vParamsEditor.Showmodal <> mrOk Then
  lvBodyParams.Items.Delete(vItemIndex);
end;

procedure TfRequestDebbug.sbDeleteParamClick(Sender: TObject);
begin
 If lvBodyParams.Selected <> Nil Then
  lvBodyParams.Items.Delete(lvBodyParams.Selected.Index)
 Else
  Application.MessageBox('Select one item to Delete.', 'Error...', mb_IconError + mb_Ok);
end;

procedure TfRequestDebbug.ChecksState;
Begin
 If Not pSSL.Enabled Then
  Begin
   pSSL.Color       := clRed;
   cbSSLv2.Checked  := False;
   cbSSLv23.Checked := cbSSLv2.Checked;
   cbSSLv3.Checked  := cbSSLv2.Checked;
   cbTLSv12.Checked := cbSSLv2.Checked;
   cbTLSv11.Checked := cbSSLv2.Checked;
   cbTLSv1.Checked  := cbSSLv2.Checked;
  End
 Else
  pSSL.Color        := clBlue; 
End;

procedure TfRequestDebbug.cbHaveSSLClick(Sender: TObject);
begin
 pSSL.Enabled := TCheckBox(Sender).Checked;
 ChecksState;
end;

procedure TfRequestDebbug.cbOAuth0Click(Sender: TObject);
begin
 eUsername.Enabled := cbOAuth0.Checked;
 ePassword.Enabled := eUsername.Enabled;
end;

procedure TfRequestDebbug.cbProxyClick(Sender: TObject);
begin
 eProxyServer.Enabled   := cbProxy.Checked;
 eProxyPort.Enabled     := eProxyServer.Enabled;
 eProxyUsername.Enabled := eProxyPort.Enabled;
 eProxyPassword.Enabled := eProxyUsername.Enabled;
end;

Procedure TfRequestDebbug.ValidateRequestResultType(Value : String);
Var
 vActiveFlag : Boolean;
Begin
 vActiveFlag            := Not (tsJSON.TabVisible) And (Pos('json', lowercase(Value)) > 0);
 tsJSON.TabVisible      := Pos('json', lowercase(Value)) > 0;
 tsJSON.Visible         := tsJSON.TabVisible;
 If vActiveFlag Then
  pcResponse.ActivePage := tsJSON;
End;

procedure TfRequestDebbug.FormCreate(Sender: TObject);
begin
 ValidateRequestResultType(eContentType.Text);
 paTopo.Color := TColor($002A2A2A);
end;

Procedure TfRequestDebbug.BuildRequest;
Begin
 DWClientREST1.UserAgent       := eUserAgent.Text;
 DWClientREST1.Accept          := eAccept.Text;
 DWClientREST1.ContentEncoding := eContentEncoding.Text;
 DWClientREST1.ContentType     := eContentType.Text;
 DWClientREST1.UseSSL          := cbHaveSSL.Checked;
 DWClientREST1.SSLVersions     := [];
 DWClientREST1.RequestCharset  := esUtf8;
 If DWClientREST1.UseSSL Then
  Begin
   If cbSSLv2.Checked Then
    DWClientREST1.SSLVersions := DWClientREST1.SSLVersions + [sslvSSLv2];
   If cbSSLv23.Checked Then
    DWClientREST1.SSLVersions := DWClientREST1.SSLVersions + [sslvSSLv23];
   If cbSSLv3.Checked Then
    DWClientREST1.SSLVersions := DWClientREST1.SSLVersions + [sslvSSLv3];
   If cbTLSv1.Checked Then
    DWClientREST1.SSLVersions := DWClientREST1.SSLVersions + [sslvTLSv1];
   {$IFNDEF OLDINDY}
   If cbTLSv11.Checked Then
    DWClientREST1.SSLVersions := DWClientREST1.SSLVersions + [sslvTLSv1_1];
   If cbTLSv12.Checked Then
    DWClientREST1.SSLVersions := DWClientREST1.SSLVersions + [sslvTLSv1_2];
   {$ENDIF}
  End;
 If cbOAuth0.Checked Then
  DWClientREST1.AuthenticationOptions.AuthorizationOption  := rdwAOBasic
 Else
  DWClientREST1.AuthenticationOptions.AuthorizationOption  := rdwAONone;
 If DWClientREST1.AuthenticationOptions.AuthorizationOption = rdwAOBasic Then
  Begin
   TRDWAuthOptionBasic(DWClientREST1.AuthenticationOptions.OptionParams).Username := eUsername.Text;
   TRDWAuthOptionBasic(DWClientREST1.AuthenticationOptions.OptionParams).Password := ePassword.Text;
  End;
 DWClientREST1.ProxyOptions.BasicAuthentication := cbProxy.Checked;
 If DWClientREST1.ProxyOptions.BasicAuthentication Then
  Begin
   DWClientREST1.ProxyOptions.ProxyUsername := eProxyUsername.Text;
   DWClientREST1.ProxyOptions.ProxyPassword := eProxyPassword.Text;
  End;
 DWClientREST1.ProxyOptions.ProxyServer     := eProxyServer.Text;
 DWClientREST1.ProxyOptions.ProxyPort       := StrToInt(eProxyPort.Text);
End;

Procedure TfRequestDebbug.BuildCustomHeaders(Var CustomHeaders : TStringList);
Var
 I : Integer;
Begin
 CustomHeaders.Clear;
 For I := 0 To lvBodyParams.Items.Count -1 Do
  CustomHeaders.Add(Format('%s=%s', [TDWRequestParams(lvBodyParams.Items[I].Data^).Param,
                                     TDWRequestParams(lvBodyParams.Items[I].Data^).Value]));
End;

procedure TfRequestDebbug.sbSendRequestClick(Sender: TObject);
Var
 vCustomHeaders : TStringList;
 vCustomReply   : TStringStream;
 vShowViewer    : Boolean;
Begin
 vShowViewer    := True;
 BuildRequest;
 Try
  vCustomReply   := TStringStream.Create('');
  vCustomHeaders := TStringList.Create;
  Try
   If rbParams.Checked Then
    BuildCustomHeaders(vCustomHeaders)
   Else
    vCustomHeaders.Text := mRAWBody.Text; 
   Case cbRequestType.ItemIndex Of
    0 ://GET
     Begin
      DWClientREST1.Get (cbRequest.Text, vCustomHeaders, vCustomReply);
      If vCustomReply.Size > 0 Then
       Begin
        vShowViewer    := False;
        mRAW.Text      := vCustomReply.DataString;
        BuildTreeJSON(mRAW.Text);
       End;
     End;
    1 ://POST
     Begin
      DWClientREST1.Post(cbRequest.Text, vCustomHeaders, vCustomReply);
      If vCustomReply.Size > 0 Then
       Begin
        vShowViewer    := False;
        mRAW.Text      := vCustomReply.DataString;
        BuildTreeJSON(mRAW.Text);
       End;
     End;
    2 ://PUT
     Begin
      DWClientREST1.Put(cbRequest.Text, vCustomHeaders, vCustomReply);
      If vCustomReply.Size > 0 Then
       Begin
        vShowViewer    := False;
        mRAW.Text      := vCustomReply.DataString;
       End;
     End;
    3 ://DELETE
     Begin
      DWClientREST1.Delete(cbRequest.Text, vCustomHeaders, vCustomReply);
      If vCustomReply.Size > 0 Then
       Begin
        vShowViewer    := False;
        mRAW.Text      := vCustomReply.DataString;
       End;
     End;
    4 ://PATCH
     Begin
      DWClientREST1.Patch(cbRequest.Text, vCustomHeaders, vCustomReply);
      If vCustomReply.Size > 0 Then
       Begin
        vShowViewer    := False;
        mRAW.Text      := vCustomReply.DataString;
       End;
     End;
   End;
   ValidateRequestResultType(eContentType.Text);
  Finally
   FreeAndNil(vCustomHeaders);
   FreeAndNil(vCustomReply);
  End;
  Application.MessageBox('Request has been executed.', 'Information!!!', mb_IconInformation + mb_Ok);
 Except
  On E : Exception do
   Begin
    If vShowViewer Then
     ValidateRequestResultType('');
    mRAW.Text := e.Message;
    Application.MessageBox('Request Error.', 'Error...', mb_IconError + mb_Ok);
   End;
 End; 
End;

procedure TfRequestDebbug.eContentTypeExit(Sender: TObject);
begin
 ValidateRequestResultType(eContentType.Text);
end;

procedure TfRequestDebbug.TreeView1Click(Sender: TObject);
begin
 LoadItem;
end;

procedure TfRequestDebbug.rbParamsClick(Sender: TObject);
begin
 pParamBody.Visible := rbParams.Checked;
 pRAWBody.Visible   := Not pParamBody.Visible;
end;

procedure TfRequestDebbug.rbRawBodyClick(Sender: TObject);
begin
 pRAWBody.Visible   := rbRawBody.Checked;
 pParamBody.Visible := Not pRAWBody.Visible;
end;

{$IFNDEF FPC}
Procedure TCustomMenuItemDW.Execute;
Begin
 ShowMessage(Format('%s - %s', [DWDialogoTitulo, DWCodeProject + ' - ' + DWVERSAO]));
End;

function TCustomMenuItemDW.GetIDString: string;
begin
  Result := 'RDW.RequestDebbug';
end;

function TCustomMenuItemDW.GetMenuText: string;
begin
  Result := 'IOTAWizardMenu';
end;

Function TCustomMenuItemDW.GetName: string;
Begin
 Result := 'RDWRequestDebbug';
End;

Function TCustomMenuItemDW.GetState: TWizardState;
Begin
 Result := [wsEnabled];
End;

Procedure TCustomMenuHandler.HandleClick(Sender: TObject);
Begin
 If fRequestDebbug = Nil Then
  fRequestDebbug := TfRequestDebbug.Create(Application);
 fRequestDebbug.Show;
End;
{$ELSE}
procedure IDEMenuSectionClicked(Sender : TObject);
Begin
 If fRequestDebbug = Nil Then
  fRequestDebbug := TfRequestDebbug.Create(Application);
 fRequestDebbug.Show;
End;
{$ENDIF}

Procedure AddIDEMenu;
{$IFNDEF FPC}
Var
 I             : Integer;
 IDEMenuItem,
 ToolsMenuItem : TMenuItem;
{$ENDIF}
Begin
 {$IFDEF FPC}
  RegisterIDEMenuCommand(mnuTools, rsLazarusDWPackage, rsDwRequestDBGName, nil, @IDEMenuSectionClicked);
 {$ELSE}
  {$IF CompilerVersion > 21}
   If Supports(BorlandIDEServices, INTAServices, NTAServices) then
    begin
     CustomMenuHandler := TCustomMenuHandler.Create;
     mnuitem := TMenuItem.Create(nil);
     mnuitem.Caption := rsDwRequestDBGName;
     mnuitem.OnClick := CustomMenuHandler.HandleClick;
     NTAServices.AddActionMenu('ToolsMenu', Nil, mnuitem, False, True);
    End;
  {$ELSE}
   If Supports(BorlandIDEServices, INTAServices, NTAServices) Then
    Begin
     If NTAServices.MainMenu <> Nil Then
      Begin
       IDEMenuItem := NTAServices.MainMenu.Items;
       ToolsMenuItem := nil;
       For I := 0 to IDEMenuItem.Count - 1 do
        If CompareText(IDEMenuItem.Items[I].Name, 'ToolsMenu') = 0 then
         ToolsMenuItem := IDEMenuItem.Items[I];
       If ToolsMenuItem <> Nil Then
        Begin
         If ToolsMenuItem.Find(rsDwRequestDBGName) = Nil Then
          Begin
           CustomMenuHandler := TCustomMenuHandler.Create;
           mnuitem           := TMenuItem.Create(nil);
           mnuitem.Caption   := rsDwRequestDBGName;
           mnuitem.OnClick   := CustomMenuHandler.HandleClick;
           ToolsMenuItem.Insert(0, mnuitem);
          End;
        End;
      End;
    End;
  {$IFEND}
 {$ENDIF}
End;

Procedure RemoveIDEMenu;
{$IFNDEF FPC}
Var
 NTAServices   : INTAServices;
 HelpMenu      : TComponent;
 I             : Integer;
 IDEMenuItem,
 ToolsMenuItem : TMenuItem;
{$ENDIF}
Begin
 If Assigned(mnuitem) then
  Begin
   {$IFDEF FPC}

   {$ELSE}
    {$IF CompilerVersion > 21}
     HelpMenu := Application.MainForm.FindComponent('ToolsMenu');
     If HelpMenu Is TMenuItem Then
      TMenuItem(HelpMenu).Remove(mnuitem);
     If Assigned(mnuitem) then
      FreeAndNil(mnuitem);
     If Assigned(CustomMenuHandler) then
      FreeAndNil(CustomMenuHandler);
    {$ELSE}
     If Supports(BorlandIDEServices, INTAServices, NTAServices) Then
      Begin
       IDEMenuItem := NTAServices.MainMenu.Items;
       ToolsMenuItem := nil;
       For I := 0 to IDEMenuItem.Count - 1 do
        If CompareText(IDEMenuItem.Items[I].Name, 'ToolsMenu') = 0 then
         ToolsMenuItem := IDEMenuItem.Items[I];
       If ToolsMenuItem <> Nil Then
        If ToolsMenuItem.Find(rsDwRequestDBGName) <> Nil Then
         ToolsMenuItem.Delete(ToolsMenuItem.Find(rsDwRequestDBGName).MenuIndex);
       If Assigned(mnuitem) then
        FreeAndNil(mnuitem);
       If Assigned(CustomMenuHandler) then
        FreeAndNil(CustomMenuHandler);
      End;  
    {$IFEND}
   {$ENDIF}
  End;
End;

procedure TfRequestDebbug.FormShow(Sender: TObject);
begin
 paTopo.Color := TColor($002A2A2A);
end;

Initialization
 mnuitem           := Nil;
 {$IFNDEF FPC}
 CustomMenuHandler := Nil;
 {$ENDIF}

Finalization
 RemoveIDEMenu;

end.
