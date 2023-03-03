unit lclfunctions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, ExtCtrls, CheckLst;

type

  { TLCLFunctions }

  TLCLFunctions = class
  private
    procedure SetControlState(Args: array of TComponent; EnabledState: boolean);
    procedure SetControlVisibility(Args: array of TComponent; VisibleState: boolean);
  public
    procedure DesativaControles(Args: array of TComponent);
    procedure AtivaControles(Args: array of TComponent);
    procedure EscondeControles(Args: array of TComponent);
    procedure MostraControles(Args: array of TComponent);
  end;

var
  LCLFunc: TLCLFunctions;

implementation

{ TLCLFunctions }

procedure TLCLFunctions.SetControlState(Args: array of TComponent;
  EnabledState: boolean);
var
  Component: TComponent;
begin
  for Component in Args do
    if Component is TLabel then
      TLabel(Component).Enabled := EnabledState
    else if Component is TCheckGroup then
      TCheckGroup(Component).Enabled := EnabledState
    else if Component is TCheckListBox then
      TCheckListBox(Component).Enabled := EnabledState
    else if Component is TShape then
      TShape(Component).Enabled := EnabledState;
end;

procedure TLCLFunctions.SetControlVisibility(Args: array of TComponent;
  VisibleState: boolean);
var
  Component: TComponent;
begin
  for Component in Args do
    if Component is TLabel then
      TLabel(Component).Visible := VisibleState
    else if Component is TCheckGroup then
      TCheckGroup(Component).Visible := VisibleState
    else if Component is TCheckListBox then
      TCheckListBox(Component).Visible := VisibleState
    else if Component is TShape then
      TShape(Component).Visible := VisibleState;
end;

procedure TLCLFunctions.DesativaControles(Args: array of TComponent);
begin
  SetControlState(Args, False);
end;

procedure TLCLFunctions.AtivaControles(Args: array of TComponent);
begin
  SetControlState(Args, True);
end;

procedure TLCLFunctions.EscondeControles(Args: array of TComponent);
begin
  SetControlVisibility(Args, False);
end;

procedure TLCLFunctions.MostraControles(Args: array of TComponent);
begin
  SetControlVisibility(Args, True);
end;

end.
