unit UfrmValidaCampos;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, UfrmBase, uniBasicGrid, uniDBGrid, uniButton,
  uniBitBtn, uniPanel, Data.DB, uniGUIBaseClasses, uniStatusBar;

type
  TfrmValidaCampos = class(TfrmBase)
    dslog: TDataSource;
    UniPanel2: TUniPanel;
    btnok: TUniBitBtn;
    UniDBGrid1: TUniDBGrid;
    UniPanel1: TUniPanel;
    procedure btnokClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function frmValidaCampos: TfrmValidaCampos;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication;

function frmValidaCampos: TfrmValidaCampos;
begin
  Result := TfrmValidaCampos(UniMainModule.GetFormInstance(TfrmValidaCampos));
end;

procedure TfrmValidaCampos.btnokClick(Sender: TObject);
begin
  inherited;
  Close;
end;

end.
