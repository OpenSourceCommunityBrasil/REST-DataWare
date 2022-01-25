unit uMain;

interface

uses  Classes, SysUtils, Controls,    Data.DB, Vcl.Graphics,
  RaApplication, RaBase, RaControlsVCL ;
type
   TForm2 = class(TRaFormCompatible)
    RaDBGrid1: TRaDBGrid;
    RaPanel1: TRaPanel;
    RaDBGrid2: TRaDBGrid;
    RaPanel2: TRaPanel;
    RaImage1: TRaImage;
    RaLabel1: TRaLabel;
    RaLabel2: TRaLabel;
    RaLabel3: TRaLabel;
    RaDBEdit1: TRaDBEdit;
    RaDBEdit2: TRaDBEdit;
    RaDBComboBox1: TRaDBComboBox;
    RaButton1: TRaButton;
    RaButton2: TRaButton;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    Label1: TRaLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FI:Boolean;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses udm;

{$R *.dfm}
//  RaApplication.Application.RemoteIPAddress
//  RaApplication.Application.Timeout
//  RaApplication.Application.SessionValue
//  RaApplication.Application.SessionGeneration
//  RaApplication.Application.RemoteUserAgent
//  RaApplication.Application.GateQueryParams
procedure TForm2.FormCreate(Sender: TObject);
begin
   dm.RESTDWDataBase1.Active:=True;
  DM.RESTDWClientSQL1.Open;
end;

end.
