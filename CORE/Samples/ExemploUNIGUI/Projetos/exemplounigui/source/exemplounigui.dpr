program exemplounigui;

uses
  Forms,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  Main in 'Main.pas' {MainForm: TUniForm},
  UfrmBase in '..\..\..\framework\UfrmBase.pas' {frmBase: TUniForm},
  UfrmLstBase in '..\..\..\framework\UfrmLstBase.pas' {frmLstBase: TUniForm},
  UFuncoesDB in '..\..\..\framework\UFuncoesDB.pas',
  UFuncoesSysUtils in '..\..\..\framework\UFuncoesSysUtils.pas',
  Ukernel_Customizacao in '..\..\..\framework\Ukernel_Customizacao.pas',
  UKernel_String in '..\..\..\framework\UKernel_String.pas',
  UKernel_SysUtils in '..\..\..\framework\UKernel_SysUtils.pas',
  UMensagens in '..\..\..\framework\UMensagens.pas',
  UFrameBase in '..\..\..\framework\UFrameBase.pas' {frameBase: TUniFrame},
  UframeLstBase in '..\..\..\framework\UframeLstBase.pas' {frameLstBase: TUniFrame},
  UDmBase in '..\..\..\framework\UDmBase.pas' {DmBase: TDataModule},
  UDmLstBase in '..\..\..\framework\UDmLstBase.pas' {DmLstBase: TDataModule},
  UfrmConsultaGenerica in '..\..\..\framework\UfrmConsultaGenerica.pas' {frmConsultaGenerica: TUniForm},
  USQL in 'units\USQL.pas',
  USQL_Constantes in 'units\USQL_Constantes.pas',
  UfrmValidaCampos in '..\..\..\framework\UfrmValidaCampos.pas' {frmValidaCampos: TUniForm},
  UDmLstTransportadora in 'frames\UDmLstTransportadora.pas' {DmLstTransportadora: TDataModule},
  UFrameLstTransportadora in 'frames\UFrameLstTransportadora.pas' {FrameLstTransportadora: TUniFrame},
  UFrameInicial in 'frames\UFrameInicial.pas' {frameInicial: TUniFrame};

{$R *.res}

begin
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.
