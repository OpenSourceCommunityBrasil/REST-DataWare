unit uRESTDWAboutForm;

{$I ..\..\Source\Includes\uRESTDW.inc}

interface

uses
  {$IFDEF FPC}
   {$IFNDEF LAMW}
    LCLIntf, LCLType, LMessages,
   {$ENDIF}
   SysUtils, Variants, Classes,
   {$IFNDEF NOGUI}Forms, Dialogs, Graphics, Controls, {$ENDIF}ExtCtrls, StdCtrls;
  {$ELSE}
   {$IF NOT Defined(HAS_FMX)}
    {$IF CompilerVersion <= 22}
     Forms, SysUtils, ExtCtrls, StdCtrls, Variants, Classes, Messages, Graphics, Controls;
    {$ELSE}
     SysUtils, Variants, Classes,
     Messages, vcl.Graphics, vcl.Controls, vcl.Forms,
     vcl.Dialogs, vcl.ExtCtrls, vcl.StdCtrls;
    {$IFEND}
   {$ELSE}
    {$IF CompilerVersion < 21}
     SysUtils, Variants, Classes, Controls, Graphics, Forms;
    {$ELSE}
     {$IF Defined(HAS_UTF8)}
     SysUtils, Variants, Classes
     {$IFNDEF LINUXFMX}
     , FMX.Objects, FMX.Graphics, FMX.Controls, FMX.StdCtrls,
     System.UITypes, FMX.ExtCtrls, {$IFNDEF RESTDWAndroidService}FMX.Forms{$ENDIF}
     {$ENDIF};
     {$ELSE}
     SysUtils, Variants, Classes, Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls,
     Vcl.ExtCtrls, Vcl.Forms, StdCtrls, Controls, ExtCtrls, Graphics,
  Vcl.Imaging.pngimage;
     {$IFEND}
    {$IFEND}
   {$IFEND}
  {$ENDIF}
 {$IFDEF FPC}
  {$IFNDEF NOGUI}
  type
    { Tfrm_About }
    Tfrm_About = class(TForm)
      Image1: TImage;
      Panel1: TPanel;
      lbl_msg: TLabel;
      Procedure FormClose(Sender: TObject; var CloseAction : TCloseAction);
    private
      { Private declarations }
    public
      { Public declarations }
    end;

  var
    frm_About: Tfrm_About;
  {$ENDIF}
 {$ELSE}
 {$IFNDEF LINUXFMX}
type
  { Tfrm_About }
  Tfrm_About = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    lbl_msg: TLabel;
    Procedure FormClose(Sender: TObject; var Action      : TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_About: Tfrm_About;
  {$ENDIF}
  {$ENDIF}

implementation
{$IFNDEF LINUXFMX}
{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{ Tfrm_About }

{$IFDEF FPC}
 {$IFNDEF NOGUI}
Procedure Tfrm_About.FormClose(Sender: TObject; var CloseAction : TCloseAction);
 {$ENDIF}
{$ELSE}
Procedure Tfrm_About.FormClose(Sender: TObject; var Action      : TCloseAction);
{$ENDIF}
begin
 {$IFDEF FPC}
 CloseAction := caFree;
 {$ELSE}
   {$IF Defined(HAS_FMX)}
    Action := TCloseAction.caFree;
   {$ELSE}
    Action := caFree;
   {$IFEND}
 {$ENDIF}
end;
 {$ENDIF}
end.
