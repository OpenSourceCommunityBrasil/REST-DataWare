unit uDWReqParamsEditor;

interface

uses
 {$IFDEF FPC}lcl,{$ELSE}Windows,{$ENDIF}Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, Dialogs, Buttons;

type
  TfParamsEditor = class(TForm)
    eParamName: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    mValue: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
   it : TlistItem;
  public
    { Public declarations }
   Property Listitem : TlistItem Read it Write it;
  end;

var
  fParamsEditor: TfParamsEditor;

implementation

uses uDWRequestDBG;
{$R *.dfm}

procedure TfParamsEditor.FormShow(Sender: TObject);
begin
 eParamName.Text   := it.Caption;
 mValue.Lines.Text := Trim(it.SubItems.Text);
end;

procedure TfParamsEditor.BitBtn1Click(Sender: TObject);
begin
 it.Caption       := eParamName.Text;
 it.SubItems.Text := Trim(mValue.Lines.Text);
 TDWRequestParams(it.Data^).Param := it.Caption;
 TDWRequestParams(it.Data^).Value := it.SubItems.Text;
 ModalResult := mrOk;
end;

procedure TfParamsEditor.BitBtn2Click(Sender: TObject);
begin
 ModalResult := mrCancel;
end;

end.
