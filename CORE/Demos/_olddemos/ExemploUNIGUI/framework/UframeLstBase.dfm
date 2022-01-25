inherited frameLstBase: TframeLstBase
  Width = 879
  Height = 485
  OnCreate = UniFrameCreate
  Layout = 'vbox'
  ParentAlignmentControl = False
  AlignmentControl = uniAlignmentClient
  ExplicitWidth = 879
  ExplicitHeight = 485
  object UniToolBar1: TUniToolBar
    Left = 0
    Top = 0
    Width = 879
    Height = 43
    Hint = ''
    ButtonHeight = 40
    ButtonWidth = 40
    Images = UniMainModule.img_32
    ButtonAutoWidth = True
    LayoutConfig.Margin = '2 2 5 0'
    Anchors = [akLeft, akTop, akRight]
    Align = alTop
    TabOrder = 0
    ParentColor = False
    Color = clBtnFace
    object bt_incluir: TUniToolButton
      Left = 0
      Top = 0
      Hint = 'Incluir'
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 0
      Caption = 'bt_incluir'
      ScreenMask.Enabled = True
      ScreenMask.WaitData = True
      ScreenMask.Message = 'Processando Inclus'#227'o...'
      TabOrder = 1
      OnClick = bt_incluirClick
    end
    object bt_editar: TUniToolButton
      Left = 40
      Top = 0
      Hint = 'Editar'
      Visible = False
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 3
      Caption = 'bt_editar'
      ScreenMask.Enabled = True
      ScreenMask.WaitData = True
      ScreenMask.Message = 'Processando Edi'#231#227'o...'
      TabOrder = 2
      OnClick = bt_editarClick
    end
    object bt_excluir: TUniToolButton
      Left = 80
      Top = 0
      Hint = 'Excluir'
      Visible = False
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 6
      Caption = 'bt_excluir'
      ScreenMask.Enabled = True
      ScreenMask.WaitData = True
      ScreenMask.Message = 'Processando Exclus'#227'o...'
      TabOrder = 3
      OnClick = bt_excluirClick
    end
    object bt_salvar: TUniToolButton
      Left = 120
      Top = 0
      Hint = 'Salvar'
      Visible = False
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 5
      Caption = 'bt_salvar'
      ScreenMask.Enabled = True
      ScreenMask.WaitData = True
      ScreenMask.Message = 'Salvando...'
      TabOrder = 4
      OnClick = bt_salvarClick
    end
    object bt_cancelar: TUniToolButton
      Left = 160
      Top = 0
      Hint = 'Cancelar'
      Visible = False
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 8
      Caption = 'bt_cancelar'
      ScreenMask.Enabled = True
      ScreenMask.WaitData = True
      ScreenMask.Message = 'Processando Cancelamento...'
      TabOrder = 5
      OnClick = bt_cancelarClick
    end
    object bt_imprimir: TUniToolButton
      Left = 200
      Top = 0
      Hint = ''
      ParentRTL = False
      Visible = False
      ImageIndex = 9
      Caption = 'bt_imprimir'
      TabOrder = 6
      OnClick = bt_imprimirClick
    end
    object bt_pesquisar: TUniToolButton
      Left = 240
      Top = 0
      Hint = 'Pesquisa'
      ShowHint = True
      ParentShowHint = False
      ImageIndex = 2
      Caption = ''
      TabOrder = 7
      OnClick = bt_pesquisarClick
    end
    object bt_fechar: TUniToolButton
      Left = 280
      Top = 0
      Hint = ''
      ImageIndex = 4
      Caption = 'bt_fechar'
      TabOrder = 8
      OnClick = bt_fecharClick
    end
  end
  object pgCadastro: TUniPageControl
    Left = 0
    Top = 43
    Width = 879
    Height = 442
    Hint = ''
    ActivePage = Tab_Cadastro
    TabBarVisible = False
    Align = alClient
    Anchors = [akLeft, akTop, akRight, akBottom]
    LayoutConfig.Height = '100%'
    LayoutConfig.Width = '100%'
    TabOrder = 1
    object Tab_Consulta: TUniTabSheet
      Hint = ''
      Caption = 'Consulta'
      Layout = 'vbox'
      LayoutConfig.Height = '100%'
      LayoutConfig.Width = '100%'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 256
      ExplicitHeight = 128
      object pnlbotoes: TUniPanel
        Left = 0
        Top = 0
        Width = 871
        Height = 30
        Hint = ''
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        BorderStyle = ubsNone
        Caption = ''
        object lbltitulo: TUniLabel
          Left = 0
          Top = 0
          Width = 35
          Height = 16
          Hint = ''
          Caption = 'Titulo'
          Align = alLeft
          Anchors = [akLeft, akTop, akBottom]
          ParentFont = False
          Font.Height = -13
          Font.Style = [fsBold]
          TabOrder = 1
          LayoutConfig.Margin = '5'
        end
      end
      object pnlfiltros: TUniPanel
        Left = 0
        Top = 30
        Width = 871
        Height = 43
        Hint = ''
        Visible = False
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        BorderStyle = ubsNone
        Caption = ''
      end
      object GridList: TUniDBGrid
        Left = 0
        Top = 73
        Width = 871
        Height = 341
        Hint = ''
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgTabs, dgCancelOnExit]
        ReadOnly = True
        WebOptions.Paged = False
        LoadMask.Message = 'Loading data...'
        LayoutConfig.Width = '100%'
        LayoutConfig.Region = '100%'
        Align = alClient
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 2
        TabStop = False
      end
    end
    object Tab_Cadastro: TUniTabSheet
      Hint = ''
      AlignmentControl = uniAlignmentClient
      ParentAlignmentControl = False
      Caption = 'Cadastro'
      Layout = 'vbox'
      LayoutConfig.Height = '100%'
      LayoutConfig.Width = '100%'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 256
      ExplicitHeight = 128
      object UniPanel1: TUniPanel
        Left = 0
        Top = 0
        Width = 871
        Height = 30
        Hint = ''
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        BorderStyle = ubsNone
        Caption = ''
        object lbltitulocadastro: TUniLabel
          Left = 0
          Top = 0
          Width = 35
          Height = 16
          Hint = ''
          Caption = 'Titulo'
          Align = alLeft
          Anchors = [akLeft, akTop, akBottom]
          ParentFont = False
          Font.Height = -13
          Font.Style = [fsBold]
          TabOrder = 1
          LayoutConfig.Margin = '5'
        end
      end
    end
  end
end
