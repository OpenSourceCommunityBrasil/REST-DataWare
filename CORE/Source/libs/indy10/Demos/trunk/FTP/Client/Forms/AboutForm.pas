unit AboutForm;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, OleCtrls, SHDocVw;

const
  SPECIAL_THANKS_PAGE = 'Docs\SpecialThanks.htm';
  LICENSE_PAGE = 'Docs\License.htm';
{$I IdVers.inc}

type
  TfrmAbout = class(TForm)
    Image1: TImage;
    OKButton: TButton;
    pcAbout: TPageControl;
    tsGeneral: TTabSheet;
    tsSpecialThanks: TTabSheet;
    Panel1: TPanel;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    reComments: TRichEdit;
    Panel2: TPanel;
    tsLicense: TTabSheet;
    wbSpecialThanks: TWebBrowser;
    Panel3: TPanel;
    wbLicense: TWebBrowser;
    tsIndyAbout: TTabSheet;
    Panel4: TPanel;
    lblIndyName: TLabel;
    lblIndyVer: TLabel;
    lblIndyCopyright: TLabel;
    TabSheet1: TTabSheet;
    Panel5: TPanel;
    wbHelp: TWebBrowser;
    procedure Image1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses
  MainForm,
  ShellAPI;

{$R *.dfm}

procedure TfrmAbout.Image1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'OPEN', 'http://www.projectindy.org/', '', '', SW_SHOWNORMAL);
end;

procedure TfrmAbout.FormResize(Sender: TObject);
begin
  OKButton.Left := (Width div 2) - (OkButton.Width div 2);
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  AppPath : String;
begin
  reComments.Lines.Text := 'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS'+
                           ' OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF '+
                           'MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  '+
                           'IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY '+
                           'CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, '+
                           'TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE '+
                           'SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';
  AppPath := ExtractFilePath(ParamStr(0));
  wbSpecialThanks.Navigate(AppPath + SPECIAL_THANKS_PAGE);
  wbLicense.Navigate(AppPath + LICENSE_PAGE);
  wbHelp.Navigate(frmMain.HelpFile);
  lblIndyVer.Caption := gsIdProductName+' Version: '+gsIdVersion;
  lblIndyName.Caption:= 'Components Name: '+gsIdProductName;
end;

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  pcAbout.ActivePageIndex := 0;
end;

end.

