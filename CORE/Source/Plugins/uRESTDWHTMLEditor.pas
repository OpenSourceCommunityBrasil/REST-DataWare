unit uRESTDWHTMLEditor;
{$I uRESTDW.inc}
interface
uses
  Classes,
  SysUtils;
type
  TRESTDWHTMLEditor = class(TComponent)
  private
    FHTML : TStrings;
    FEditorTitle : String;
    procedure SetHTML(Value : TStrings);
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  published
    property HTML : TStrings read FHTML write SetHTML;
    property EditorTitle : String read FEditorTitle write FEditorTitle;
  end;
implementation
constructor TRESTDWHTMLEditor.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FHTML := TStringList.Create;
  FEditorTitle := '';
end;
destructor TRESTDWHTMLEditor.Destroy;
begin
  FHTML.Free;
  inherited Destroy;
end;
procedure TRESTDWHTMLEditor.SetHTML(Value : TStrings);
begin
  FHTML.Assign(Value);
end;
end.
