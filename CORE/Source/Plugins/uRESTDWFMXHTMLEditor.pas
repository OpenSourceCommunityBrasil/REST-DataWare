unit uRESTDWFMXHTMLEditor;

{$I uRESTDW.inc}

interface

uses
  Classes, SysUtils;

type
  TRESTDWFMXHTMLEditor = class(TComponent)
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

constructor TRESTDWFMXHTMLEditor.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FHTML := TStringList.Create;
  FEditorTitle := '';
end;

destructor TRESTDWFMXHTMLEditor.Destroy;
begin
  FHTML.Free;
  inherited Destroy;
end;

procedure TRESTDWFMXHTMLEditor.SetHTML(Value : TStrings);
begin
  FHTML.Assign(Value);
end;

end.
