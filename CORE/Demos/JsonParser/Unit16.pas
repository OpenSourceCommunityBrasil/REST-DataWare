unit Unit16;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uRESTDWDataJSON, Vcl.StdCtrls, uDWConsts,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.ComCtrls, uDWJSONInterface;

Type
 PDWJsonParserItem = ^TDWJsonParserItem;
 TDWJsonParserItem = Class
  ElementName,
  JsonValue : String;
End;

type
  TForm16 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Button3: TButton;
    paTopo: TPanel;
    Image1: TImage;
    labSistema: TLabel;
    paPortugues: TPanel;
    Image3: TImage;
    paEspanhol: TPanel;
    Image4: TImage;
    paIngles: TPanel;
    Image2: TImage;
    TreeView1: TTreeView;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
   Function CreateItem(TreeView  : TTreeView;
                       treeNode  : TTreeNode;
                       Item      : TRESTDWJSONBaseObjectClass) : TTreeNode;
  public
    { Public declarations }
  end;

var
  Form16: TForm16;

implementation

{$R *.dfm}

procedure TForm16.Button1Click(Sender: TObject);
Var
 JSONObject    : TRESTDWJSONObject;
 vReal         : Real;
 vMemoryStream : TMemoryStream;
begin
 JSONObject := TRESTDWJSONObject.Create;
 vMemoryStream := TMemoryStream.Create;
 vReal      := 3.2;
 Try
  JSONObject.Add('string', 'aaa');
  JSONObject.Add('inteiro', 1);
  JSONObject.Add('Float', vReal);
  JSONObject.Add('DateTime', Now);
  JSONObject.Add('Boolean', False);
  vMemoryStream.LoadFromFile('C:\Temp\clientes.txt');
  JSONObject.Add('Stream', vMemoryStream);
  Memo1.lines.Text := JSONObject.ToJSON;
 Finally
  FreeAndNil(JSONObject);
  FreeAndNil(vMemoryStream);
 End;
end;

procedure TForm16.Button2Click(Sender: TObject);
Var
 JSONArray     : TRESTDWJSONArray;
 JSONObject    : TRESTDWJSONObject;
 vReal         : Real;
 vMemoryStream : TMemoryStream;
begin
 JSONArray     := TRESTDWJSONArray.Create;
 vMemoryStream := TMemoryStream.Create;
 vReal      := 3.2;
 Try
  JSONObject    := TRESTDWJSONObject.Create;
  JSONObject.Add('string', 'aaa');
  JSONObject.Add('inteiro', 1);
  JSONObject.Add('Float', vReal);
  JSONObject.Add('DateTime', Now);
  JSONObject.Add('Boolean', False);
  vMemoryStream.LoadFromFile('C:\Temp\clientes.txt');
  JSONObject.Add('Stream', vMemoryStream);
  JSONArray.Add(JSONObject);
  JSONObject    := TRESTDWJSONObject.Create;
  JSONObject.Add('string', 'bbb');
  JSONObject.Add('inteiro', 2);
  JSONObject.Add('Float', vReal);
  JSONObject.Add('DateTime', Now);
  JSONObject.Add('Boolean', False);
  vMemoryStream.Clear;
  JSONObject.Add('Stream', vMemoryStream);
  JSONArray.Add(JSONObject);
  Memo1.lines.Text := JSONArray.ToJSON;
 Finally
  FreeAndNil(JSONArray);
  FreeAndNil(vMemoryStream);
 End;
end;

procedure TForm16.Button3Click(Sender: TObject);
Var
 JSONArray,
 JSONArray2    : TRESTDWJSONArray;
 JSONValue     : TRESTDWJSONValue;
 JSONObjectA,
 JSONObject    : TRESTDWJSONObject;
 vReal         : Real;
 vMemoryStream : TMemoryStream;
begin
 JSONObjectA   := TRESTDWJSONObject.Create;
 vMemoryStream := TMemoryStream.Create;
 vReal      := 3.2;
 Try
  JSONArray     := TRESTDWJSONArray.Create;
  JSONObject    := TRESTDWJSONObject.Create;
  JSONObject.Add('string', 'aaa');
  JSONObject.Add('inteiro', 1);
  JSONObject.Add('Float', vReal);
  JSONObject.Add('DateTime', Now);
  JSONObject.Add('Boolean', False);
  vMemoryStream.LoadFromFile('C:\Temp\clientes.txt');
  JSONObject.Add('Stream', vMemoryStream);
  JSONArray.Add(JSONObject);
  JSONObject    := TRESTDWJSONObject.Create;
  JSONObject.Add('string', 'bbb');
  JSONObject.Add('inteiro', 2);
  JSONObject.Add('Float', vReal);
  JSONObject.Add('DateTime', Now);
  JSONObject.Add('Boolean', False);
  vMemoryStream.Clear;
  JSONObject.Add('Stream', vMemoryStream);
  JSONArray.Add(JSONObject);
//  JSONArray2    := TRESTDWJSONArray.Create;
//  JSONValue     := TRESTDWJSONValue.Create;
//  JSONValue.Add(1);
//  JSONValue.Add('aaaa');
//  JSONValue.Add(Now);
//  JSONArray2.Add(JSONValue);
  JSONObjectA.Add('meuarray', JSONArray);
//  JSONObjectA.Add(JSONArray2);
  Memo1.lines.Text := JSONObjectA.ToJSON;
 Finally
  FreeAndNil(JSONObjectA);
  FreeAndNil(vMemoryStream);
 End;
end;

Function TForm16.CreateItem(TreeView  : TTreeView;
                            treeNode  : TTreeNode;
                            Item      : TRESTDWJSONBaseObjectClass) : TTreeNode;
Var
 I, A       : Integer;
 vJsonValue : PDWJsonParserItem;
Begin
 Result        := Nil;
 If Item <> Nil Then
  Begin
   If (TRESTDWJSONBase(Item).ObjectType = jtObject) Then
    Begin
     If TRESTDWJSONBase(Item).Count > 0 Then
      Begin
       If TRESTDWJSONBase(Item).ElementName <> '' Then
        Result := TreeView.Items.AddChild(treeNode, TRESTDWJSONBase(Item).ElementName + ' - {}')
       Else
        Result := TreeView.Items.AddChild(treeNode, '{}');
       New(vJsonValue);
       vJsonValue^             := TDWJsonParserItem.Create;
       vJsonValue^.ElementName := TRESTDWJSONBase(Item).ElementName;
       vJsonValue^.JsonValue   := TRESTDWJSONBase(Item).ToJSON;
       Result.Data             := vJsonValue;
       For A := 0 To TRESTDWJSONBase(Item).Count -1 Do
        Begin
         If (TRESTDWJSONBase(TRESTDWJSONBase(Item).Elements[A]).ObjectType = jtObject) Or
            (TRESTDWJSONBase(TRESTDWJSONBase(Item).Elements[A]).ObjectType = jtArray)  Then
          CreateItem(TreeView, Result, TRESTDWJSONBase(Item).Elements[A])
         Else
          Begin
           If TRESTDWJSONBase(Item).Elements[A].ElementName <> '' Then
            TreeView.Items.AddChild(Result, Format('%s = %s', [TRESTDWJSONBase(Item).Elements[A].ElementName, unescape_chars(TRESTDWJSONBase(Item).Elements[A].Value)]))
           Else
            TreeView.Items.AddChild(Result, unescape_chars(TRESTDWJSONBase(Item).Elements[A].Value));
          End;
        End;
      End;
    End
   Else If (TRESTDWJSONBase(Item).ObjectType = jtArray) Then
    Begin
     If TRESTDWJSONBase(Item).Count > 0 Then
      Begin
       If TRESTDWJSONBase(Item).ElementName <> '' Then
        Result := TreeView.Items.AddChild(treeNode, TRESTDWJSONBase(Item).ElementName + ' - []')
       Else
        Result := TreeView.Items.AddChild(treeNode, '[]');
       New(vJsonValue);
       vJsonValue^             := TDWJsonParserItem.Create;
       vJsonValue^.ElementName := TRESTDWJSONBase(Item).ElementName;
       vJsonValue^.JsonValue   := TRESTDWJSONBase(Item).ToJSON;
       Result.Data             := vJsonValue;
      End;
     For A := 0 To TRESTDWJSONArray(Item).Count -1 do
      Begin
       If (TRESTDWJSONBase(TRESTDWJSONArray(Item).Elements[A]).ObjectType = jtObject) Or
          (TRESTDWJSONBase(TRESTDWJSONArray(Item).Elements[A]).ObjectType = jtArray)  Then
        CreateItem(TreeView, Result, TRESTDWJSONBase(Item).Elements[A])
       Else
        Begin
         If TRESTDWJSONBase(Item).Elements[A].ElementName <> '' Then
          TreeView.Items.AddChild(Result, Format('%s = %s', [TRESTDWJSONBase(Item).Elements[A].ElementName,
                                                             unescape_chars(TRESTDWJSONBase(Item).Elements[A].Value)]))
         Else
          TreeView.Items.AddChild(Result, unescape_chars(TRESTDWJSONBase(Item).Elements[A].Value));
        End;
      End;
    End;
  End;
End;

procedure TForm16.Button4Click(Sender: TObject);
Var
 JSONBase : TRESTDWJSONBase;
begin
 TreeView1.Items.Clear;
 JSONBase := TRESTDWJSONBase.Create(Memo1.Text);
 Try
  CreateItem(TreeView1, Nil, TRESTDWJSONBaseObjectClass(JSONBase));
 Finally
  If Assigned(JSONBase) Then
   FreeAndNil(JSONBase);
 End;
end;

end.
