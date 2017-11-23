unit UfrmBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniStatusBar;

type
  TfrmBase = class(TUniForm)
    UniStatusBar1: TUniStatusBar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  uniGUIApplication;

{$R *.dfm}


end.
