inherited frmConsultaGenerica: TfrmConsultaGenerica
  ClientHeight = 415
  ClientWidth = 820
  Caption = 'Consulta Gerencia'
  OnShow = UniFormShow
  OnClose = UniFormClose
  ExplicitWidth = 836
  ExplicitHeight = 454
  PixelsPerInch = 96
  TextHeight = 13
  inherited UniStatusBar1: TUniStatusBar
    Top = 396
    Width = 820
    Panels = <
      item
        Text = 'Itens Encontrados ->'
        Width = 200
      end
      item
        Width = 200
      end>
    ExplicitLeft = 0
    ExplicitTop = 396
    ExplicitWidth = 820
  end
  object UniGroupBox1: TUniGroupBox
    Left = 0
    Top = 0
    Width = 820
    Height = 94
    Hint = ''
    Caption = 'Dados para Consulta'
    Align = alTop
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    object lblTitulo: TUniLabel
      Left = 15
      Top = 19
      Width = 153
      Height = 23
      Hint = ''
      Caption = 'TITULO JANELA'
      ParentFont = False
      Font.Color = clRed
      Font.Height = -19
      Font.Style = [fsBold]
      TabOrder = 1
    end
    object UniLabel1: TUniLabel
      Left = 8
      Top = 46
      Width = 33
      Height = 13
      Hint = ''
      Caption = 'Codigo'
      TabOrder = 2
    end
    object edtCodigo: TUniEdit
      Left = 7
      Top = 62
      Width = 130
      Hint = ''
      Text = ''
      TabOrder = 3
      OnKeyPress = edtCodigoKeyPress
    end
    object edtNome: TUniEdit
      Left = 143
      Top = 62
      Width = 402
      Hint = ''
      Text = ''
      TabOrder = 4
      OnKeyDown = edtNomeKeyDown
    end
    object UniLabel2: TUniLabel
      Left = 144
      Top = 46
      Width = 46
      Height = 13
      Hint = ''
      Caption = 'Descri'#231#227'o'
      TabOrder = 5
    end
    object btnFiltrar: TUniBitBtn
      Left = 648
      Top = 59
      Width = 75
      Height = 25
      Hint = ''
      Caption = 'Filtrar'
      TabOrder = 6
      OnClick = actFiltrarExecute
    end
    object btnSair: TUniBitBtn
      Left = 728
      Top = 59
      Width = 75
      Height = 25
      Hint = ''
      Caption = 'Sair'
      TabOrder = 7
      OnClick = actFecharExecute
    end
  end
  object dbgbase: TUniDBGrid
    Left = 0
    Top = 94
    Width = 820
    Height = 302
    Hint = ''
    DataSource = dsPesqBase
    ReadOnly = True
    WebOptions.Paged = False
    WebOptions.KeyNavigation = knDisabled
    LoadMask.Message = 'Loading data...'
    Align = alClient
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    OnKeyDown = dbgbaseKeyDown
    OnDblClick = dbgbaseDblClick
    Columns = <
      item
        Title.Caption = 'Codigo'
        Width = 64
      end
      item
        Title.Caption = 'Descri'#231#227'o'
        Width = 691
      end>
  end
  object dsPesqBase: TDataSource
    DataSet = adqrypesquisa
    Left = 272
    Top = 192
  end
  object actlstPesquisar: TActionList
    Left = 408
    Top = 192
    object actFiltrar: TAction
      Caption = 'Filtrar'
      ImageIndex = 1
      OnExecute = actFiltrarExecute
    end
    object actFechar: TAction
      Caption = 'Fechar'
      ImageIndex = 0
      OnExecute = actFecharExecute
    end
  end
  object adqrypesquisa: TRESTDWClientSQL
    FieldDefs = <>
    IndexDefs = <>
    MasterFields = ''
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCountUpdatedRecords, uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    MasterCascadeDelete = True
    Inactive = False
    DataCache = False
    Params = <>
    DataBase = UniMainModule.RESTConexao
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    InBlockEvents = False
    Left = 192
    Top = 192
  end
end
