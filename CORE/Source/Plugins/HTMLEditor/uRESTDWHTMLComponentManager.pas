unit uRESTDWHTMLComponentManager;

{$I uRESTDW.inc}
{$IFDEF FPC}
{$mode delphi}{$H+}
{$ENDIF}

Interface

uses
 Classes, SysUtils, StrUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Dialogs,
 Graphics, IniFiles, ImgList, Buttons, Grids,
 {$IFDEF FPC}
 EditBtn, Zipper,
 {$ELSE}
  {$IFDEF DELPHIXE2UP}
 System.Zip,
  {$ENDIF}
 {$ENDIF}
 uRESTDWHTMLIDECompat;

const
 CRESTDWHTMLProject = 'REST Dataware HTML Designer';
 CRESTDWHTMLVersion = '2.1';
 CRESTDWHTMLCreator = 'REST Dataware';
 CRESTDWHTMLTester = 'Gledson Prego';

type
 {$IFDEF FPC}
 TRESTDWHTMLFileNameEdit = class(TEditButton)
 {$ELSE}
  {$IFDEF DELPHI2009UP}
 TRESTDWHTMLFileNameEdit = class(TButtonedEdit)
  {$ELSE}
 TRESTDWHTMLFileNameEdit = class(TEdit)
  {$ENDIF}
 {$ENDIF}
 private
  FFilter : String;
  procedure BrowseClick(Sender : TObject);
 public
  constructor Create(AOwner : TComponent); override;
 published
  property Filter : String read FFilter write FFilter;
 end;

Procedure RESTDWCopyFileClassic(
 const ASource,
 ADestination : String);

Function RESTDWHTMLComponentsPath(const AEditorLibrariesPath : String) : String;
Function RESTDWHTMLResolveJSClass(const AEditorLibrariesPath,
 AJsFileName, AClassName : String; Out AHTML : String;
 Out AVisual : Boolean; Out APlacement : String) : Boolean;

Procedure InstallRESTDWHTMLComponent(const AEditorLibrariesPath : String);

Procedure ConfigureRESTDWHTMLComponents(const AEditorLibrariesPath : String);

Procedure ConfigureRESTDWHTMLProject(AProducer : TObject; const AEditorLibrariesPath : String);

implementation

uses
 uRESTDWHTMLPageProducerAdapter;

procedure RESTDWHTMLExtractZipFile(const AFileName, ADestination : String);
{$IFDEF FPC}
var
 LUnZipper : TUnZipper;
{$ENDIF}
begin
 {$IFDEF FPC}
 LUnZipper := TUnZipper.Create;
 try
  LUnZipper.FileName := AFileName;
  LUnZipper.OutputPath := ADestination;
  LUnZipper.Examine;
  LUnZipper.UnZipAllFiles;
 finally
  LUnZipper.Free;
 end;
 {$ELSE}
  {$IFDEF DELPHIXE2UP}
 TZipFile.ExtractZipFile(AFileName, ADestination);
  {$ELSE}
 Raise Exception.Create('ZIP extraction requires Delphi XE2 or newer.');
  {$ENDIF}
 {$ENDIF}
end;

Procedure RESTDWCopyFileClassic(
 const ASource,
 ADestination : String);
Var
 LSource,
 LDestination : TFileStream;
Begin
 LSource := TFileStream.Create(
  ASource,
  fmOpenRead Or fmShareDenyWrite
 );
 Try
  LDestination := TFileStream.Create(
   ADestination,
   fmCreate
  );
  Try
   LDestination.CopyFrom(
    LSource,
    0
   );
  Finally
   LDestination.Free;
  End;
 Finally
  LSource.Free;
 End;
End;

constructor TRESTDWHTMLFileNameEdit.Create(AOwner : TComponent);
begin
 inherited Create(AOwner);
 {$IFDEF FPC}
 Button.Visible := True;
 Button.Hint := 'Browse...';
 OnButtonClick := BrowseClick;
 {$ELSE}
  {$IFDEF DELPHI2009UP}
 RightButton.Visible := True;
 RightButton.Hint := 'Browse...';
 OnRightButtonClick := BrowseClick;
  {$ELSE}
 Hint := 'Double-click to browse...';
 ShowHint := True;
 OnDblClick := BrowseClick;
  {$ENDIF}
 {$ENDIF}
end;

procedure TRESTDWHTMLFileNameEdit.BrowseClick(Sender : TObject);
var
 D : TOpenDialog;
begin
 D := TOpenDialog.Create(nil);
 try
  D.Filter := FFilter;
  if D.Execute then
   Text := D.FileName;
 finally
  D.Free;
 end;
end;

Function SafeName(const AValue : String) : String;
Var
 I : Integer;
Begin
 Result := Trim(AValue);
 For I := Length(Result) DownTo 1 Do
  If Not (
      ((Result[I] >= 'a') And (Result[I] <= 'z')) Or
      ((Result[I] >= 'A') And (Result[I] <= 'Z')) Or
      ((Result[I] >= '0') And (Result[I] <= '9')) Or
      (Result[I] = '_') Or
      (Result[I] = '-')
     ) Then
   Delete(Result,I,1);
 If Result = '' Then
  Result := 'Component';
End;

Function RESTDWHTMLComponentsPath(
 const AEditorLibrariesPath : String) : String;
Begin
 Result :=
  IncludeTrailingPathDelimiter(
   AEditorLibrariesPath
  ) +
  'Packages';
 ForceDirectories(Result);
End;

Function RESTDWHTMLReadAllText(const AFileName : String) : String;
Var
 L : TStringList;
Begin
 Result := '';
 If Not FileExists(AFileName) Then
  Exit;
 L := TStringList.Create;
 Try
  L.LoadFromFile(AFileName);
  Result := L.Text;
 Finally
  L.Free;
 End;
End;

Function RESTDWHTMLJSUnescape(const AValue : String) : String;
Begin
 Result := StringReplace(AValue,'\`','`',[rfReplaceAll]);
 Result := StringReplace(Result,'\n',sLineBreak,[rfReplaceAll]);
 Result := StringReplace(Result,'\r','',[rfReplaceAll]);
 Result := StringReplace(Result,'\\','\',[rfReplaceAll]);
End;

Function RESTDWHTMLExtractJSValue(
 const AClassText, AName, ADefault : String) : String;
Var
 LLower,LNeedle : String;
 P,Q,R : Integer;
 C : Char;
Begin
 Result := ADefault;
 LLower := LowerCase(AClassText);
 LNeedle := LowerCase('static ' + AName);
 P := Pos(LNeedle,LLower);
 If P = 0 Then Exit;
 P := PosEx('=',AClassText,P + Length(LNeedle));
 If P = 0 Then Exit;
 Inc(P);
 While (P <= Length(AClassText)) And (AClassText[P] <= ' ') Do Inc(P);
 If P > Length(AClassText) Then Exit;
 C := AClassText[P];
 If Not (C In ['''','"','`']) Then
 Begin
  Q := P;
  While (Q <= Length(AClassText)) And
        Not (AClassText[Q] In [';','}',#13,#10]) Do Inc(Q);
  Result := Trim(Copy(AClassText,P,Q - P));
  Exit;
 End;
 Q := P + 1;
 R := Q;
 While R <= Length(AClassText) Do
 Begin
  If (AClassText[R] = C) And
     ((R = Q) Or (AClassText[R - 1] <> '\')) Then Break;
  Inc(R);
 End;
 If R <= Length(AClassText) Then
  Result := RESTDWHTMLJSUnescape(Copy(AClassText,Q,R - Q));
End;

Function RESTDWHTMLExtractJSHTML(const AClassText : String) : String;
Var
 LLower : String;
 P,Q,R : Integer;
 C : Char;
Begin
 Result := '';
 LLower := LowerCase(AClassText);
 P := Pos('static createhtml',LLower);
 If P = 0 Then Exit;
 P := PosEx('return',LLower,P);
 If P = 0 Then Exit;
 Inc(P,Length('return'));
 While (P <= Length(AClassText)) And (AClassText[P] <= ' ') Do Inc(P);
 If P > Length(AClassText) Then Exit;
 C := AClassText[P];
 If Not (C In ['''','"','`']) Then Exit;
 Q := P + 1;
 R := Q;
 While R <= Length(AClassText) Do
 Begin
  If (AClassText[R] = C) And
     ((R = Q) Or (AClassText[R - 1] <> '\')) Then Break;
  Inc(R);
 End;
 If R <= Length(AClassText) Then
  Result := RESTDWHTMLJSUnescape(Copy(AClassText,Q,R - Q));
End;

Function RESTDWHTMLResolveJSClass(
 const AEditorLibrariesPath,AJsFileName,AClassName : String;
 Out AHTML : String; Out AVisual : Boolean;
 Out APlacement : String) : Boolean;
Var
 LFileName,LText,LLower,LClassText,LNeedle,LVisual : String;
 P,B,I,Depth : Integer;
 C,
 Quote : Char;
 InString,
 Escaped : Boolean;
Begin
 Result := False;
 AHTML := '';
 AVisual := True;
 APlacement := 'body';
 If (Trim(AJsFileName) = '') Or (Trim(AClassName) = '') Then Exit;
 LFileName := AJsFileName;
 If Not FileExists(LFileName) Then
  LFileName :=
   IncludeTrailingPathDelimiter(
    RESTDWHTMLComponentsPath(AEditorLibrariesPath)
   ) + AJsFileName;
 If Not FileExists(LFileName) Then Exit;
 LText := RESTDWHTMLReadAllText(LFileName);
 LLower := LowerCase(LText);
 LNeedle := LowerCase('class ' + AClassName);
 P := Pos(LNeedle,LLower);
 If P = 0 Then Exit;
 B := PosEx('{',LText,P + Length(LNeedle));
 If B = 0 Then Exit;
 Depth := 0;
 InString := False;
 Escaped := False;
 Quote := #0;
 I := B;
 While I <= Length(LText) Do
 Begin
  C := LText[I];
  If InString Then
  Begin
   If Escaped Then
    Escaped := False
   Else If C = '\' Then
    Escaped := True
   Else If C = Quote Then
    InString := False;
  End
  Else If C In ['''','"','`'] Then
  Begin
   InString := True;
   Quote := C;
  End
  Else If C = '{' Then
   Inc(Depth)
  Else If C = '}' Then
  Begin
   Dec(Depth);
   If Depth = 0 Then
    Break;
  End;
  Inc(I);
 End;
 If Depth <> 0 Then Exit;
 LClassText := Copy(LText,B + 1,I - B - 1);
 AHTML := RESTDWHTMLExtractJSHTML(LClassText);
 LVisual := LowerCase(
  RESTDWHTMLExtractJSValue(LClassText,'visual','true')
 );
 AVisual := Not SameText(LVisual,'false');
 APlacement :=
  RESTDWHTMLExtractJSValue(LClassText,'placement','body');
 If Trim(APlacement) = '' Then APlacement := 'body';
 Result := True;
End;

Procedure AddLabeledEdit(AOwner : TComponent; AParent : TWinControl;
 const ACaption : String; ATop : Integer; Var AEdit : TEdit);
Var
 L : TLabel;
Begin
 L := TLabel.Create(AOwner);
 L.Parent := AParent;
 L.Left := 16;
 L.Top := ATop;
 L.Caption := ACaption;
 AEdit := TEdit.Create(AOwner);
 AEdit.Parent := AParent;
 AEdit.Left := 190;
 AEdit.Top := ATop - 4;
 AEdit.Width := 430;
End;

Procedure InstallRESTDWHTMLComponent(
 const AEditorLibrariesPath : String);
Var
 F : TForm;
 EPackage,EURL,EPalette,EName,EType,ELabel,EHint,EFile,EExtension : TEdit;
 EZip,EIcon,EJS : TRESTDWHTMLFileNameEdit;
 LOptions : TLabel;
 MOptions : TMemo;
 BOk,BCancel : TButton;
 R : Integer;
 Root,PackageFile,ComponentSection,OptionsSection,LibRoot,
 LJsFileName,LIconFileName : String;
 Ini : TIniFile;
 I : Integer;
Begin
 F := TForm.CreateNew(Nil,1);
 Try
  F.Caption := 'REST Dataware - Install Component';
  F.Position := poScreenCenter;
  F.Width := 690;
  F.Height := 720;
  F.BorderStyle := bsDialog;
  AddLabeledEdit(F,F,'Package',24,EPackage);
  EPackage.Text := 'Custom';
  AddLabeledEdit(F,F,'Palette',62,EPalette);
  EPalette.Text := 'Custom';
  AddLabeledEdit(F,F,'Name Class',100,EName);
  With TLabel.Create(F) Do Begin Parent:=F; Left:=16; Top:=142; Caption:='JsFileName'; End;
  EJS:=TRESTDWHTMLFileNameEdit.Create(F); EJS.Parent:=F; EJS.Left:=190; EJS.Top:=138;
  EJS.Width:=474; EJS.Filter:='JavaScript|*.js|All files|*.*';
  AddLabeledEdit(F,F,'Class Type',180,EType);
  EType.Text := 'div';
  AddLabeledEdit(F,F,'Label Class',218,ELabel);
  AddLabeledEdit(F,F,'Palette Hint',256,EHint);
  AddLabeledEdit(F,F,'html_extension',294,EExtension);
  With TLabel.Create(F) Do Begin Parent:=F; Left:=16; Top:=336; Caption:='Local library ZIP'; End;
  EZip:=TRESTDWHTMLFileNameEdit.Create(F); EZip.Parent:=F; EZip.Left:=190; EZip.Top:=332;
  EZip.Width:=474; EZip.Filter:='ZIP library|*.zip';
  AddLabeledEdit(F,F,'External library URL',374,EURL);
  AddLabeledEdit(F,F,'LibFilename',412,EFile);
  With TLabel.Create(F) Do Begin Parent:=F; Left:=16; Top:=454; Caption:='Class Icon'; End;
  EIcon:=TRESTDWHTMLFileNameEdit.Create(F); EIcon.Parent:=F; EIcon.Left:=190; EIcon.Top:=450;
  EIcon.Width:=474; EIcon.Filter:='Images|*.png;*.bmp;*.ico;*.jpg;*.jpeg|All files|*.*';
  LOptions := TLabel.Create(F); LOptions.Parent := F; LOptions.Left := 16; LOptions.Top := 496;
  LOptions.Caption := 'Component options (Name=DefaultValue, one per line)';
  MOptions := TMemo.Create(F); MOptions.Parent := F; MOptions.Left := 16; MOptions.Top := 516;
  MOptions.Width := 648; MOptions.Height := 120; MOptions.ScrollBars := ssVertical;
  BOk := TButton.Create(F); BOk.Parent := F; BOk.Left := 480; BOk.Top := 650; BOk.Width := 88;
  BOk.Caption := 'OK'; BOk.ModalResult := mrOk; BOk.Default := True;
  BCancel := TButton.Create(F); BCancel.Parent := F; BCancel.Left := 576; BCancel.Top := 650; BCancel.Width := 88;
  BCancel.Caption := 'Cancel'; BCancel.ModalResult := mrCancel; BCancel.Cancel := True;
  R := F.ShowModal;
  If R <> mrOk Then Exit;
  If Trim(EPackage.Text) = '' Then Raise Exception.Create('Package is required.');
  If Trim(EName.Text) = '' Then Raise Exception.Create('Name Class is required.');
  If Trim(EPalette.Text) = '' Then EPalette.Text := 'Custom';
  If Trim(EType.Text) = '' Then EType.Text := 'div';
  Root := RESTDWHTMLComponentsPath(AEditorLibrariesPath);
  PackageFile := IncludeTrailingPathDelimiter(Root) + SafeName(EPackage.Text) + '.ini';
  ComponentSection := 'Component.' + SafeName(EName.Text);
  OptionsSection := 'Options.' + SafeName(EName.Text);
  Ini := TIniFile.Create(PackageFile);
  Try
   LJsFileName := Trim(EJS.Text);
   If (LJsFileName <> '') And FileExists(LJsFileName) Then
   Begin
    RESTDWCopyFileClassic(LJsFileName,IncludeTrailingPathDelimiter(Root)+ExtractFileName(LJsFileName));
    LJsFileName := ExtractFileName(LJsFileName);
   End;
   If LJsFileName = '' Then
    LJsFileName := Ini.ReadString('Package','JsFileName','');
   If LJsFileName = '' Then
    Raise Exception.Create('JsFileName is required. The JavaScript package must export NameClass and createHTML().');
   Ini.WriteString('Package','Name',EPackage.Text);
   Ini.WriteBool('Package','Enabled',True);
   Ini.WriteString('Package','JsFileName',LJsFileName);
   Ini.WriteString('Package','FormatVersion','1');
   If Ini.ReadString('Package','Order','') = '' Then
    Ini.WriteInteger('Package','Order',1000);
   Ini.WriteString(ComponentSection,'Name',EName.Text);
   Ini.WriteString(ComponentSection,'NameClass',EName.Text);
   Ini.WriteString(ComponentSection,'Palette',EPalette.Text);
   Ini.WriteString(ComponentSection,'JsFileName',LJsFileName);
   Ini.WriteString(ComponentSection,'ClassType',EType.Text);
   Ini.WriteString(ComponentSection,'LabelClass',ELabel.Text);
   Ini.WriteString(ComponentSection,'Hint',EHint.Text);
   Ini.WriteString(ComponentSection,'html_extension',EExtension.Text);
   Ini.WriteString(ComponentSection,'LibFilename',EFile.Text);
   Ini.WriteString(ComponentSection,'URL',EURL.Text);
   Ini.WriteString(ComponentSection,'InstallerVersion','Phoenix');
   Ini.WriteBool(ComponentSection,'Installed',True);
   LibRoot := IncludeTrailingPathDelimiter(Root)+SafeName(EPackage.Text)+'_'+SafeName(EName.Text)+'_libs';
   If Trim(EZip.Text) <> '' Then
   Begin
    If Not FileExists(EZip.Text) Then Raise Exception.Create('Local library ZIP not found: '+EZip.Text);
    ForceDirectories(LibRoot);
    RESTDWHTMLExtractZipFile(EZip.Text,IncludeTrailingPathDelimiter(LibRoot));
    Ini.WriteString(ComponentSection,'LocalPath',LibRoot);
   End
   Else Ini.WriteString(ComponentSection,'LocalPath','');
   LIconFileName := '';
   If (Trim(EIcon.Text) <> '') And FileExists(EIcon.Text) Then
   Begin
    LIconFileName := SafeName(EPackage.Text)+'_'+SafeName(EName.Text)+ExtractFileExt(EIcon.Text);
    RESTDWCopyFileClassic(EIcon.Text,IncludeTrailingPathDelimiter(Root)+LIconFileName);
   End;
   Ini.WriteString(ComponentSection,'ClassIcon',LIconFileName);
   Ini.EraseSection(OptionsSection);
   For I := 0 To MOptions.Lines.Count - 1 Do
    If Pos('=',MOptions.Lines[I]) > 1 Then
     Ini.WriteString(OptionsSection,
      Trim(Copy(MOptions.Lines[I],1,Pos('=',MOptions.Lines[I])-1)),
      Trim(Copy(MOptions.Lines[I],Pos('=',MOptions.Lines[I])+1,MaxInt)));
  Finally
   Ini.Free;
  End;
 Finally
  F.Free;
 End;
End;

Type
 TComponentOptionsForm = Class(TForm)
 Private
  FRoot : String;
  FPackages : TListView;
  FComponents : TListView;
  FOptions : TStringGrid;
  FSettingsPanel : TPanel;
  FApplyPanel : TPanel;
  FApplyButton : TButton;
  FStatusLabel : TLabel;
  FOriginalValues : TStringList;
  FCurrentFile : String;
  FCurrentSection : String;
  FImages : TImageList;
  Function AddComponentIcon(const AFileName : String) : Integer;
  Procedure LoadPackages;
  Procedure PackageClick(Sender : TObject);
  Procedure ComponentClick(Sender : TObject);
  Procedure OptionSetEditText(Sender : TObject; ACol, ARow : Integer; const Value : String);
  Procedure ApplyOptionClick(Sender : TObject);
  Procedure SaveChangedValues;
  Procedure UpdateApplyState;
 Public
  Constructor CreateOptions(const ARoot : String);
  Destructor Destroy; Override;
 End;

Constructor TComponentOptionsForm.CreateOptions(const ARoot : String);
Var
 B : TButton;
 LButtons,
 LListsPanel : TPanel;
Begin
 Inherited CreateNew(Nil,1);
 FRoot := ARoot;
 FCurrentFile := '';
 FCurrentSection := '';
 FOriginalValues := TStringList.Create;
 Caption := 'REST Dataware - Configure Packages';
 Position := poScreenCenter;
 Width := 1060;
 Height := 640;
 BorderStyle := bsSizeable;
 FImages := TImageList.Create(Self);
 FImages.Width := 24;
 FImages.Height := 24;
 LListsPanel := TPanel.Create(Self);
 LListsPanel.Parent := Self;
 LListsPanel.Align := alLeft;
 LListsPanel.Width := 520;
 LListsPanel.BevelOuter := bvNone;
 LListsPanel.Caption := '';
 FPackages := TListView.Create(LListsPanel);
 FPackages.Parent := LListsPanel;
 FPackages.Align := alLeft;
 FPackages.Width := 220;
 FPackages.ViewStyle := vsReport;
 FPackages.ReadOnly := True;
 FPackages.RowSelect := True;
 FPackages.HideSelection := False;
 FPackages.Columns.Add.Caption := 'Package / Palette';
 FPackages.Columns[0].Width := 190;
 FPackages.OnClick := PackageClick;
 FComponents := TListView.Create(LListsPanel);
 FComponents.Parent := LListsPanel;
 FComponents.Align := alClient;
 FComponents.ViewStyle := vsReport;
 FComponents.ReadOnly := True;
 FComponents.RowSelect := True;
 FComponents.HideSelection := False;
 FComponents.SmallImages := FImages;
 FComponents.Columns.Add.Caption := 'Component';
 FComponents.Columns[0].Width := 270;
 FComponents.OnClick := ComponentClick;
 LButtons := TPanel.Create(Self);
 LButtons.Parent := Self;
 LButtons.Align := alBottom;
 LButtons.Height := 42;
 LButtons.BevelOuter := bvNone;
 LButtons.Caption := '';
 B := TButton.Create(LButtons);
 B.Parent := LButtons;
 B.Align := alRight;
 B.Width := 96;
 B.Caption := 'Close';
 B.ModalResult := mrOk;
 B.Default := True;
 FSettingsPanel := TPanel.Create(Self);
 FSettingsPanel.Parent := Self;
 FSettingsPanel.Align := alClient;
 FSettingsPanel.BevelOuter := bvNone;
 FSettingsPanel.Caption := '';
 FApplyPanel := TPanel.Create(FSettingsPanel);
 FApplyPanel.Parent := FSettingsPanel;
 FApplyPanel.Align := alBottom;
 FApplyPanel.Height := 38;
 FApplyPanel.BevelOuter := bvNone;
 FApplyPanel.Caption := '';
 FApplyButton := TButton.Create(FApplyPanel);
 FApplyButton.Parent := FApplyPanel;
 FApplyButton.Align := alRight;
 FApplyButton.Width := 86;
 FApplyButton.Caption := 'OK';
 FApplyButton.Enabled := False;
 FApplyButton.OnClick := ApplyOptionClick;
 FStatusLabel := TLabel.Create(FApplyPanel);
 FStatusLabel.Parent := FApplyPanel;
 FStatusLabel.Align := alClient;
 FStatusLabel.Layout := tlCenter;
 FStatusLabel.Caption := '';
 FOptions := TStringGrid.Create(FSettingsPanel);
 FOptions.Parent := FSettingsPanel;
 FOptions.Align := alClient;
 FOptions.ColCount := 2;
 FOptions.RowCount := 1;
 FOptions.FixedRows := 0;
 FOptions.FixedCols := 1;
 FOptions.DefaultRowHeight := 21;
 FOptions.ColWidths[0] := 190;
 FOptions.ColWidths[1] := 330;
 FOptions.Cells[0,0] := 'Component Setting';
 FOptions.Cells[1,0] := 'Value';
 FOptions.Options := FOptions.Options + [goEditing,goColSizing,goDrawFocusSelected];
 FOptions.OnSetEditText := OptionSetEditText;
 LoadPackages;
 If FPackages.Items.Count = 0 Then
  FStatusLabel.Caption := 'No package INI found in Packages.'
 Else
  FStatusLabel.Caption := 'Select a package and a component.';
End;

Destructor TComponentOptionsForm.Destroy;
Begin
 FOriginalValues.Free;
 Inherited Destroy;
End;

Function TComponentOptionsForm.AddComponentIcon(const AFileName : String) : Integer;
Var
 P : TPicture;
 B : TBitmap;
 LFileName : String;
Begin
 Result := -1;
 LFileName := AFileName;
 If (Trim(LFileName) <> '') And Not FileExists(LFileName) Then
 Begin
  If FileExists(ExpandFileName(IncludeTrailingPathDelimiter(FRoot) + LFileName)) Then
   LFileName := ExpandFileName(IncludeTrailingPathDelimiter(FRoot) + LFileName)
  Else
   LFileName := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFileDir(FRoot)) + LFileName);
 End;
 If (Trim(LFileName) = '') Or Not FileExists(LFileName) Then Exit;
 P := TPicture.Create;
 B := TBitmap.Create;
 Try
  Try
   P.LoadFromFile(LFileName);
   B.SetSize(24,24);
   B.Canvas.StretchDraw(Rect(0,0,24,24),P.Graphic);
   Result := FImages.Add(B,Nil);
  Except
   Result := -1;
  End;
 Finally
  B.Free;
  P.Free;
 End;
End;

Procedure TComponentOptionsForm.LoadPackages;
Var
 S : TSearchRec;
 I : TIniFile;
 Item : TListItem;
 LName : String;
Begin
 FPackages.Items.Clear;
 If FindFirst(IncludeTrailingPathDelimiter(FRoot)+'*.ini',faAnyFile,S)<>0 Then Exit;
 Try
  Repeat
   I := TIniFile.Create(IncludeTrailingPathDelimiter(FRoot)+S.Name);
   Try
    LName := I.ReadString('Package','Name',ChangeFileExt(S.Name,''));
    Item := FPackages.Items.Add;
    Item.Caption := LName;
    Item.SubItems.Add(S.Name);
   Finally
    I.Free;
   End;
  Until FindNext(S)<>0;
 Finally
  FindClose(S);
 End;
 If FPackages.Items.Count > 0 Then
 Begin
  FPackages.ItemIndex := 0;
  FPackages.Items[0].Selected := True;
  FPackages.Items[0].Focused := True;
  PackageClick(FPackages);
 End;
End;

Procedure TComponentOptionsForm.PackageClick(Sender : TObject);
Var
 I : TIniFile;
 Sections : TStringList;
 K : Integer;
 S,N,LIcon : String;
 Item : TListItem;
Begin
 FComponents.Items.Clear;
 FOptions.FixedRows := 0;
 FOptions.RowCount := 1;
 FOriginalValues.Clear;
 FApplyButton.Enabled := False;
 FCurrentFile := '';
 FCurrentSection := '';
 If FPackages.Selected = Nil Then
  If (FPackages.ItemIndex >= 0) And (FPackages.ItemIndex < FPackages.Items.Count) Then
   FPackages.Items[FPackages.ItemIndex].Selected := True;
 If (FPackages.Selected=Nil) Or (FPackages.Selected.SubItems.Count=0) Then Exit;
 FCurrentFile := IncludeTrailingPathDelimiter(FRoot)+FPackages.Selected.SubItems[0];
 I := TIniFile.Create(FCurrentFile);
 Sections := TStringList.Create;
 Try
  I.ReadSections(Sections);
  For K := 0 To Sections.Count - 1 Do
  Begin
   S := Sections[K];
   If Pos('Component.',S) <> 1 Then Continue;
   N := I.ReadString(S,'Name',Copy(S,Length('Component.')+1,MaxInt));
   Item := FComponents.Items.Add;
   Item.Caption := N;
   Item.SubItems.Add(S);
   LIcon := I.ReadString(S,'ClassIcon','');
   Item.ImageIndex := AddComponentIcon(LIcon);
  End;
 Finally
  Sections.Free;
  I.Free;
 End;
 If FComponents.Items.Count > 0 Then
 Begin
  FComponents.ItemIndex := 0;
  FComponents.Items[0].Selected := True;
  FComponents.Items[0].Focused := True;
  ComponentClick(FComponents);
 End;
End;

Procedure TComponentOptionsForm.ComponentClick(Sender : TObject);
Var
 I : TIniFile;
 Keys : TStringList;
 K,R : Integer;
 LOptionsSection : String;
 Procedure AddField(const AName,AValue : String);
 Begin
  R := FOptions.RowCount;
  FOptions.RowCount := R+1;
  FOptions.Cells[0,R] := AName;
  FOptions.Cells[1,R] := AValue;
  FOriginalValues.Values[AName] := AValue;
 End;
Begin
 FOptions.FixedRows := 0;
 FOptions.RowCount := 1;
 FOriginalValues.Clear;
 FApplyButton.Enabled := False;
 FCurrentSection := '';
 If FComponents.Selected = Nil Then
  If (FComponents.ItemIndex >= 0) And (FComponents.ItemIndex < FComponents.Items.Count) Then
   FComponents.Items[FComponents.ItemIndex].Selected := True;
 If (FComponents.Selected=Nil) Or (FComponents.Selected.SubItems.Count=0) Or (FCurrentFile='') Then Exit;
 FCurrentSection := FComponents.Selected.SubItems[0];
 I := TIniFile.Create(FCurrentFile);
 Keys := TStringList.Create;
 Try
  AddField('Name',I.ReadString(FCurrentSection,'Name',''));
  AddField('NameClass',I.ReadString(FCurrentSection,'NameClass',''));
  AddField('Palette',I.ReadString(FCurrentSection,'Palette','Custom'));
  AddField('JsFileName',I.ReadString(FCurrentSection,'JsFileName',I.ReadString('Package','JsFileName','')));
  AddField('ClassType',I.ReadString(FCurrentSection,'ClassType',''));
  AddField('LabelClass',I.ReadString(FCurrentSection,'LabelClass',''));
  AddField('Hint',I.ReadString(FCurrentSection,'Hint',''));
  AddField('html_extension',I.ReadString(FCurrentSection,'html_extension',''));
  AddField('LibFilename',I.ReadString(FCurrentSection,'LibFilename',''));
  AddField('URL',I.ReadString(FCurrentSection,'URL',''));
  AddField('LocalPath',I.ReadString(FCurrentSection,'LocalPath',''));
  AddField('ClassIcon',I.ReadString(FCurrentSection,'ClassIcon',''));
  AddField('Order',IntToStr(I.ReadInteger(FCurrentSection,'Order',1000)));
  If I.ReadBool(FCurrentSection,'Installed',True) Then AddField('Installed','True')
  Else AddField('Installed','False');
  LOptionsSection := 'Options.'+Copy(FCurrentSection,Length('Component.')+1,MaxInt);
  I.ReadSection(LOptionsSection,Keys);
  For K := 0 To Keys.Count - 1 Do
   AddField('Option.'+Keys[K],I.ReadString(LOptionsSection,Keys[K],''));
 Finally
  Keys.Free;
  I.Free;
 End;
 If FOptions.RowCount > 1 Then
  FOptions.FixedRows := 1;
 FStatusLabel.Caption := IntToStr(FOptions.RowCount-1)+' field(s) loaded from package INI.';
End;

Procedure TComponentOptionsForm.UpdateApplyState;
Var
 R : Integer;
Begin
 FApplyButton.Enabled := False;
 For R := 1 To FOptions.RowCount - 1 Do
  If FOptions.Cells[1,R] <> FOriginalValues.Values[FOptions.Cells[0,R]] Then
  Begin
   FApplyButton.Enabled := True;
   Exit;
  End;
End;

Procedure TComponentOptionsForm.OptionSetEditText(Sender : TObject; ACol, ARow : Integer; const Value : String);
Begin
 If (ACol = 1) And (ARow > 0) Then
  UpdateApplyState;
End;

Procedure TComponentOptionsForm.SaveChangedValues;
Var
 I : TIniFile;
 R : Integer;
 LField,LValue,LOptionsSection,LKey : String;
Begin
 If (FCurrentFile='') Or (FCurrentSection='') Then Exit;
 I := TIniFile.Create(FCurrentFile);
 Try
  For R := 1 To FOptions.RowCount - 1 Do
  Begin
   LField := FOptions.Cells[0,R];
   LValue := FOptions.Cells[1,R];
   If LValue = FOriginalValues.Values[LField] Then Continue;
   If SameText(LField,'Order') Then
    I.WriteInteger(FCurrentSection,'Order',StrToIntDef(LValue,1000))
   Else If Pos('Option.',LField) = 1 Then
   Begin
    LKey := Copy(LField,Length('Option.')+1,MaxInt);
    LOptionsSection := 'Options.'+Copy(FCurrentSection,Length('Component.')+1,MaxInt);
    I.WriteString(LOptionsSection,LKey,LValue);
   End
   Else If SameText(LField,'Installed') Then
    I.WriteBool(FCurrentSection,'Installed',SameText(LValue,'True') Or SameText(LValue,'1') Or SameText(LValue,'Yes'))
   Else
    I.WriteString(FCurrentSection,LField,LValue);
   FOriginalValues.Values[LField] := LValue;
  End;
 Finally
  I.Free;
 End;
 FApplyButton.Enabled := False;
 FStatusLabel.Caption := 'Saved to '+ExtractFileName(FCurrentFile);
End;

Procedure TComponentOptionsForm.ApplyOptionClick(Sender : TObject);
Begin
 SaveChangedValues;
End;

Procedure ConfigureRESTDWHTMLComponents(
 const AEditorLibrariesPath : String);
Var
 F : TComponentOptionsForm;
Begin
 F:=TComponentOptionsForm.CreateOptions(RESTDWHTMLComponentsPath(AEditorLibrariesPath));
 Try
  F.ShowModal;
 Finally F.Free; End;
End;

Function ActiveProjectINIFileName : String;
Var
 LPath : String;
Begin
 LPath := '';
 If (RESTDWActiveProjectDir <> '') Then
  LPath :=
   RESTDWActiveProjectDir;
 If LPath = '' Then
  LPath := GetCurrentDir;
 Result :=
  IncludeTrailingPathDelimiter(LPath) +
  'RESTDataware.project.ini';
End;

Type
 TProjectOptionsForm = Class(TForm)
 Private
  FProducer : TRESTDWHTMLPageProducerAdapter;
  FEditorLibrariesPath : String;
  FTopics : TListView;
  FPage : TPanel;
  FGeneralPage : TPanel;
  FAdditionalPage : TPanel;
  FURL : TRadioButton;
  FLocal : TRadioButton;
  FURLRoot : TEdit;
  FLocalRoot : TEdit;
  FTempMode : TRESTDWHTMLLibraryMode;
  FTempURL : String;
  Procedure TopicClick(Sender : TObject);
  Procedure ShowGeneral;
  Procedure ShowAdditional;
  Procedure AboutClick(Sender : TObject);
  Procedure CaptureGeneralValues;
 Public
  Constructor CreateOptions(AProducer : TRESTDWHTMLPageProducerAdapter;
   const AEditorLibrariesPath : String);
  Procedure SaveOptions;
 End;

Constructor TProjectOptionsForm.CreateOptions(
 AProducer : TRESTDWHTMLPageProducerAdapter;
 const AEditorLibrariesPath : String);
Var
 B : TButton;
 I : TListItem;
 L : TLabel;
Begin
 Inherited CreateNew(Nil,1);
 FProducer := AProducer;
 FEditorLibrariesPath := AEditorLibrariesPath;
 FTempMode := FProducer.LibraryMode;
 FTempURL := FProducer.LibraryURL;
 With TIniFile.Create(ActiveProjectINIFileName) Do
 Try
  If SameText(
      ReadString('Libraries','Mode','Local'),
      'URL'
     ) Then
   FTempMode := lmURL
  Else
   FTempMode := lmLocal;
  FTempURL :=
   ReadString(
    'Libraries',
    'URL',
    FTempURL
   );
 Finally
  Free;
 End;
 Caption := 'REST Dataware - Project Options';
 Position := poScreenCenter;
 Width := 720;
 Height := 440;
 BorderStyle := bsDialog;
 FTopics := TListView.Create(Self);
 FTopics.Parent := Self;
 FTopics.Align := alLeft;
 FTopics.Width := 180;
 FTopics.ViewStyle := vsReport;
 FTopics.ReadOnly := True;
 FTopics.RowSelect := True;
 FTopics.Columns.Add.Caption := 'Options';
 FTopics.Columns[0].Width := 160;
 FTopics.OnClick := TopicClick;
 I := FTopics.Items.Add;
 I.Caption := 'General';
 I := FTopics.Items.Add;
 I.Caption := 'Additional';
 FPage := TPanel.Create(Self);
 FPage.Parent := Self;
 FPage.Align := alClient;
 FPage.BevelOuter := bvNone;
 { Pages are created once and only shown/hidden. The former implementation
   freed child controls when switching topics, leaving field references that
   could be reused after About and cause an access violation. }
 FGeneralPage := TPanel.Create(Self);
 FGeneralPage.Parent := FPage;
 FGeneralPage.Align := alClient;
 FGeneralPage.BevelOuter := bvNone;
 L := TLabel.Create(Self);
 L.Parent := FGeneralPage;
 L.Left := 24;
 L.Top := 24;
 L.Caption := 'Libraries';
 FURL := TRadioButton.Create(Self);
 FURL.Parent := FGeneralPage;
 FURL.Left := 24;
 FURL.Top := 60;
 FURL.Caption := 'Use URL / external library';
 FURL.Checked := FTempMode = lmURL;
 FURLRoot := TEdit.Create(Self);
 FURLRoot.Parent := FGeneralPage;
 FURLRoot.Left := 240;
 FURLRoot.Top := 56;
 FURLRoot.Width := 400;
 FURLRoot.Text := FTempURL;
 FLocal := TRadioButton.Create(Self);
 FLocal.Parent := FGeneralPage;
 FLocal.Left := 24;
 FLocal.Top := 100;
 FLocal.Caption := 'Use local library';
 FLocal.Checked := FTempMode = lmLocal;
 FLocalRoot := TEdit.Create(Self);
 FLocalRoot.Parent := FGeneralPage;
 FLocalRoot.Left := 240;
 FLocalRoot.Top := 96;
 FLocalRoot.Width := 400;
 FLocalRoot.Text := FProducer.LocalHTMLLibrariesPath;
 FLocalRoot.ReadOnly := True;
 FAdditionalPage := TPanel.Create(Self);
 FAdditionalPage.Parent := FPage;
 FAdditionalPage.Align := alClient;
 FAdditionalPage.BevelOuter := bvNone;
 L := TLabel.Create(Self);
 L.Parent := FAdditionalPage;
 L.Left := 24;
 L.Top := 24;
 L.Caption := 'Additional';
 B := TButton.Create(Self);
 B.Parent := FAdditionalPage;
 B.Left := 24;
 B.Top := 58;
 B.Width := 160;
 B.Caption := 'About...';
 B.OnClick := AboutClick;
 B := TButton.Create(Self);
 B.Parent := Self;
 B.Align := alBottom;
 B.Height := 32;
 B.Caption := 'OK';
 B.ModalResult := mrOk;
 B.Default := True;
 B := TButton.Create(Self);
 B.Parent := Self;
 B.Align := alBottom;
 B.Height := 32;
 B.Caption := 'Cancel';
 B.ModalResult := mrCancel;
 B.Cancel := True;
 FTopics.ItemIndex := 0;
 FTopics.Items[0].Selected := True;
 FTopics.Items[0].Focused := True;
 ShowGeneral;
End;

Procedure TProjectOptionsForm.CaptureGeneralValues;
Begin
 If FURL.Checked Then
  FTempMode := lmURL
 Else
  FTempMode := lmLocal;
 FTempURL := FURLRoot.Text;
End;

Procedure TProjectOptionsForm.ShowGeneral;
Begin
 FAdditionalPage.Visible := False;
 FGeneralPage.Visible := True;
 FGeneralPage.BringToFront;
End;

Procedure TProjectOptionsForm.ShowAdditional;
Begin
 CaptureGeneralValues;
 FGeneralPage.Visible := False;
 FAdditionalPage.Visible := True;
 FAdditionalPage.BringToFront;
End;

Procedure TProjectOptionsForm.TopicClick(
 Sender : TObject);
Begin
 If FTopics.Selected = Nil Then
  Exit;
 If SameText(
     FTopics.Selected.Caption,
     'General'
    ) Then
  ShowGeneral
 Else
  ShowAdditional;
End;

Procedure TProjectOptionsForm.AboutClick(
 Sender : TObject);
Begin
 ShowMessage(
  CRESTDWHTMLProject + sLineBreak +
  'Version: ' + CRESTDWHTMLVersion + sLineBreak +
  'Creator: ' + CRESTDWHTMLCreator + sLineBreak +
  'Tester: ' + CRESTDWHTMLTester + sLineBreak + sLineBreak +
  'HTML Project / PageProducer visual project.'
 );
End;

Procedure TProjectOptionsForm.SaveOptions;
Begin
 CaptureGeneralValues;
 FProducer.LibraryMode := FTempMode;
 FProducer.LibraryURL := Trim(FTempURL);
 If FTempMode = lmLocal Then
 Begin
  If DirectoryExists(FEditorLibrariesPath) Then
   RESTDWCopyDirTree(FEditorLibrariesPath,IncludeTrailingPathDelimiter(
     ExtractFilePath(ActiveProjectINIFileName)
    ) +
    'html' +
    PathDelim +
    'libs');
 End;
 With TIniFile.Create(ActiveProjectINIFileName) Do
 Try
  If FTempMode = lmURL Then
   WriteString('Libraries','Mode','URL')
  Else
   WriteString('Libraries','Mode','Local');
  WriteString(
   'Libraries',
   'URL',
   Trim(FTempURL)
  );
  WriteString(
   'Libraries',
   'EditorLocalPath',
   FEditorLibrariesPath
  );
  WriteString(
   'Libraries',
   'HTMLLocalPath',
   FProducer.LocalHTMLLibrariesPath
  );
 Finally
  Free;
 End;
End;

Procedure ConfigureRESTDWHTMLProject(AProducer : TObject; const AEditorLibrariesPath : String);
Var
 F : TProjectOptionsForm;
Begin
 If Not (AProducer Is TRESTDWHTMLPageProducerAdapter) Then Exit;
 F:=TProjectOptionsForm.CreateOptions(TRESTDWHTMLPageProducerAdapter(AProducer),AEditorLibrariesPath);
 Try
  If F.ShowModal=mrOk Then F.SaveOptions;
 Finally F.Free; End;
End;
End.
