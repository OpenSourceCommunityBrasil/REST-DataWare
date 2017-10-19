{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  23014: ConfigureApplicationForm.pas 
{
{   Rev 1.1    09/11/2003 3:20:48 PM  Jeremy Darling
{ Completed Log Color customization.
}
{
{   Rev 1.0    09/11/2003 12:49:18 PM  Jeremy Darling
{ Project Added to TC
}
unit ConfigureApplicationForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, ApplicationConfiguration, ColorGrd;

type
  TfrmConfigureApplication = class(TForm)
    pcMain: TPageControl;
    tsLogColors: TTabSheet;
    btnCancel: TButton;
    btnOk: TButton;
    cbElements: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    cgColors: TColorGrid;
    Panel1: TPanel;
    procedure cbElementsChange(Sender: TObject);
    procedure cgColorsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfigureApplication: TfrmConfigureApplication;

function ConfigureApplication(AppConfig : TApplicationConfig) : Boolean;

implementation

{$R *.DFM}

function ConfigureApplication(AppConfig : TApplicationConfig) : Boolean;
var
  i : Integer;
begin
  Result := false;
  with TfrmConfigureApplication.Create(Application) do
    begin
      try
        for i := 0 to AppConfig.LogColors.Count -1 do
          begin
            cbElements.Items.AddObject(AppConfig.LogColors[i], Pointer(AppConfig.LogColors.Colors[AppConfig.LogColors[i]]));
          end;
        cbElements.ItemIndex := 0;
        cbElementsChange(cbElements);
        case ShowModal of
          mrOk : begin
                   for i := 0 to AppConfig.LogColors.Count -1 do
                     begin
                       AppConfig.LogColors.Colors[AppConfig.LogColors[i]] := TColor(Pointer(cbElements.Items.Objects[i]));
                     end;
                   result := true;
                 end;
          mrCancel : begin
                       result := false;
                     end;
        end;
      finally
        Free;
      end;
    end;
end;

procedure TfrmConfigureApplication.cbElementsChange(Sender: TObject);
begin
  cgColors.ForegroundIndex := cgColors.ColorToIndex(TColor(Pointer(cbElements.Items.Objects[cbElements.ItemIndex])));
end;

procedure TfrmConfigureApplication.cgColorsChange(Sender: TObject);
begin
  if cbElements.ItemIndex > -1 then
    cbElements.Items.Objects[cbElements.ItemIndex] := pointer(cgColors.ForegroundColor);
end;

end.
