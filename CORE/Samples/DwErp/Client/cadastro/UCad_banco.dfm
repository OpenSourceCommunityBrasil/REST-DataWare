inherited FrmCad_banco: TFrmCad_banco
  Caption = 'Cadastro de bancos'
  ClientHeight = 545
  ClientWidth = 728
  ExplicitWidth = 734
  ExplicitHeight = 574
  PixelsPerInch = 96
  TextHeight = 13
  inherited PnlCabecalho: TPanel
    Width = 728
    ExplicitWidth = 728
    inherited LblStatus: TJvLabel
      Height = 37
    end
    inherited JvToolBar1: TJvToolBar
      inherited ToolButton2: TToolButton
        ExplicitWidth = 64
      end
      inherited ToolButton3: TToolButton
        ExplicitWidth = 62
      end
      inherited ToolButton4: TToolButton
        ExplicitWidth = 58
      end
      inherited ToolButton5: TToolButton
        ExplicitWidth = 62
      end
      inherited ToolButton6: TToolButton
        ExplicitWidth = 58
      end
      inherited ToolButton8: TToolButton
        ExplicitWidth = 64
      end
    end
    inherited EdCodigo: TEdit
      Left = 607
      ExplicitLeft = 607
    end
  end
  object Panel1: TPanel [1]
    Left = 0
    Top = 41
    Width = 728
    Height = 64
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 5
      Top = 12
      Width = 55
      Height = 13
      Caption = 'Cod. Banco'
      FocusControl = DBEdit1
    end
    object Label5: TLabel
      Left = 72
      Top = 13
      Width = 50
      Height = 13
      Caption = 'Descri'#231#227'o:'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object DBEdit1: TDBEdit
      Left = 5
      Top = 28
      Width = 63
      Height = 21
      Color = clBtnFace
      DataField = 'CODIGO'
      DataSource = DSPrincipal
      ReadOnly = True
      TabOrder = 0
    end
    object DBEdit2: TDBEdit
      Left = 73
      Top = 28
      Width = 632
      Height = 21
      Color = clBtnFace
      DataField = 'DESCRICAO'
      DataSource = DSPrincipal
      ReadOnly = True
      TabOrder = 1
    end
  end
  object PageControl1: TPageControl [2]
    Left = 0
    Top = 110
    Width = 728
    Height = 435
    ActivePage = TabSheet1
    Align = alBottom
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Banco/Cedente'
      object Label10: TLabel
        Left = 236
        Top = 65
        Width = 81
        Height = 13
        Caption = 'C'#243'digo Cedente:'
        FocusControl = DBEdit49
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label11: TLabel
        Left = 2
        Top = 64
        Width = 42
        Height = 13
        Caption = 'Ag'#234'ncia:'
        FocusControl = DBEdit59
      end
      object Label25: TLabel
        Left = 267
        Top = 102
        Width = 90
        Height = 13
        Caption = 'Nome do Cedente:'
        FocusControl = DBEdit62
      end
      object Label18: TLabel
        Left = 73
        Top = 65
        Width = 17
        Height = 13
        Caption = 'Dg:'
      end
      object Label8: TLabel
        Left = 313
        Top = -1
        Width = 105
        Height = 13
        Caption = 'Orienta'#231#245'es do banco'
        FocusControl = DBMemo2
      end
      object Label19: TLabel
        Left = 5
        Top = -1
        Width = 69
        Height = 13
        Caption = 'Tipo Cobran'#231'a'
        FocusControl = DBMemo2
      end
      object Label21: TLabel
        Left = 3
        Top = 40
        Width = 189
        Height = 25
        Caption = 'Dados do Cedente'
        FocusControl = DBEdit59
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -21
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label22: TLabel
        Left = 6
        Top = 183
        Width = 32
        Height = 13
        Caption = 'Bairro:'
        FocusControl = DBEdit10
      end
      object Label23: TLabel
        Left = 605
        Top = 64
        Width = 97
        Height = 13
        Caption = 'Caracteristica titulo:'
        FocusControl = DBEdit10
      end
      object Label24: TLabel
        Left = 354
        Top = 183
        Width = 37
        Height = 13
        Caption = 'Cidade:'
        FocusControl = DBEdit11
      end
      object Label27: TLabel
        Left = 110
        Top = 64
        Width = 33
        Height = 13
        Caption = 'Conta:'
        FocusControl = DBEdit12
      end
      object Label28: TLabel
        Left = 197
        Top = 65
        Width = 17
        Height = 13
        Caption = 'Dg:'
      end
      object Label29: TLabel
        Left = 330
        Top = 65
        Width = 49
        Height = 13
        Caption = 'Convenio:'
        FocusControl = DBEdit14
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label30: TLabel
        Left = 427
        Top = 64
        Width = 85
        Height = 13
        Caption = 'Cod. Transmiss'#227'o'
        FocusControl = DBEdit15
      end
      object Label4: TLabel
        Left = 5
        Top = 142
        Width = 49
        Height = 13
        Caption = 'Endere'#231'o:'
        FocusControl = DBEdit16
      end
      object Label12: TLabel
        Left = 519
        Top = 64
        Width = 58
        Height = 13
        Caption = 'Modalidade:'
        FocusControl = DBEdit17
      end
      object Label20: TLabel
        Left = 470
        Top = 183
        Width = 17
        Height = 13
        Caption = 'UF:'
        FocusControl = DBEdit11
      end
      object Label31: TLabel
        Left = 3
        Top = 217
        Width = 65
        Height = 13
        Caption = 'Complemento'
        FocusControl = DBMemo1
      end
      object Label3: TLabel
        Left = 127
        Top = 325
        Width = 88
        Height = 13
        Caption = 'Formato da boleta'
      end
      object Label6: TLabel
        Left = 4
        Top = 325
        Width = 40
        Height = 13
        Caption = 'Layout :'
        FocusControl = DBEdit10
      end
      object Label7: TLabel
        Left = 3
        Top = 366
        Width = 75
        Height = 13
        Caption = 'Tipo Logomarca'
        FocusControl = DBEdit10
      end
      object Label9: TLabel
        Left = 136
        Top = 366
        Width = 97
        Height = 13
        Caption = 'Dias para protestar:'
        FocusControl = DBEdit3
      end
      object Label14: TLabel
        Left = 240
        Top = 366
        Width = 111
        Height = 13
        Caption = 'Local Para PAgamento:'
        FocusControl = DBEdit4
      end
      object Label15: TLabel
        Left = 3
        Top = 102
        Width = 60
        Height = 13
        Caption = 'Tpo Carteira'
        FocusControl = DBEdit10
      end
      object Label16: TLabel
        Left = 135
        Top = 102
        Width = 86
        Height = 13
        Caption = 'Respons. Emiss'#227'o'
        FocusControl = DBEdit10
      end
      object Label17: TLabel
        Left = 85
        Top = 103
        Width = 43
        Height = 13
        Caption = 'Carteira:'
        FocusControl = DBEdit5
      end
      object DBEdit49: TDBEdit
        Left = 236
        Top = 80
        Width = 88
        Height = 21
        DataField = 'B_CODIGO_CEDENTE'
        DataSource = DSPrincipal
        TabOrder = 6
      end
      object DBEdit59: TDBEdit
        Tag = 2
        Left = 2
        Top = 80
        Width = 68
        Height = 21
        DataField = 'B_AGENCIA'
        DataSource = DSPrincipal
        TabOrder = 2
      end
      object DBEdit62: TDBEdit
        Left = 267
        Top = 117
        Width = 449
        Height = 21
        CharCase = ecUpperCase
        DataField = 'B_NOME'
        DataSource = DSPrincipal
        TabOrder = 14
      end
      object DBMemo2: TDBMemo
        Tag = 4
        Left = 310
        Top = 14
        Width = 405
        Height = 48
        DataField = 'B_ORIENTACOESBANCO'
        DataSource = DSPrincipal
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object JvDBComboBox2: TJvDBComboBox
        Left = 3
        Top = 13
        Width = 301
        Height = 21
        DataField = 'BANCO_TIPOCOBRANCA'
        DataSource = DSPrincipal
        Items.Strings = (
          'Sem cobran'#231'a'
          'Cob. Banco Do Brasil'
          'Cob. Santander'
          'Cob. Caixa Economica'
          'Cob. Caixa Sicob'
          'Cob. Bradesco'
          'Cob. Itau'
          'Cob. Banco Mercantil'
          'Cob. Sicred'
          'Cob. Bancoob'
          'Cob. Banrisul'
          'Cob. Banestes'
          'Cob. HSBC'
          'Cob. Banco Do Nordeste'
          'Cob. BRB'
          'Cob. Bic Banco'
          'Cob. Bradesco SICOOB'
          'Cob. Banco Safra'
          'Cob. Safra Bradesco'
          'Cob. Banco CECRED')
        TabOrder = 0
        Values.Strings = (
          'cobNenhum'
          'cobBancoDoBrasil'
          'cobSantander'
          'cobCaixaEconomica'
          'cobCaixaSicob'
          'cobBradesco'
          'cobItau'
          'cobBancoMercantil'
          'cobSicred'
          'cobBancoob'
          'cobBanrisul'
          'cobBanestes'
          'cobHSBC'
          'cobBancoDoNordeste'
          'cobBRB'
          'cobBicBanco'
          'cobBradescoSICOOB'
          'cobBancoSafra'
          'cobSafraBradesco'
          'cobBancoCECRED')
        ListSettings.OutfilteredValueFont.Charset = DEFAULT_CHARSET
        ListSettings.OutfilteredValueFont.Color = clRed
        ListSettings.OutfilteredValueFont.Height = -11
        ListSettings.OutfilteredValueFont.Name = 'Tahoma'
        ListSettings.OutfilteredValueFont.Style = []
      end
      object DBEdit10: TDBEdit
        Left = 5
        Top = 197
        Width = 342
        Height = 21
        CharCase = ecUpperCase
        DataField = 'B_BAIRRO'
        DataSource = DSPrincipal
        TabOrder = 16
      end
      object JvDBComboBox3: TJvDBComboBox
        Left = 604
        Top = 80
        Width = 111
        Height = 21
        DataField = 'B_CARACTITULO'
        DataSource = DSPrincipal
        Items.Strings = (
          'Simples'
          'Vinculada'
          'Caucionada'
          'Descontada'
          'Vendor')
        TabOrder = 10
        Values.Strings = (
          'tcSimples'
          'tcVinculada'
          'tcCaucionada'
          'tcDescontada'
          'tcVendor')
        ListSettings.OutfilteredValueFont.Charset = DEFAULT_CHARSET
        ListSettings.OutfilteredValueFont.Color = clRed
        ListSettings.OutfilteredValueFont.Height = -11
        ListSettings.OutfilteredValueFont.Name = 'Tahoma'
        ListSettings.OutfilteredValueFont.Style = []
      end
      object DBEdit11: TDBEdit
        Left = 353
        Top = 197
        Width = 109
        Height = 21
        CharCase = ecUpperCase
        DataField = 'B_CIDADE'
        DataSource = DSPrincipal
        TabOrder = 17
      end
      object DBEdit12: TDBEdit
        Left = 110
        Top = 80
        Width = 87
        Height = 21
        DataField = 'B_CONTA'
        DataSource = DSPrincipal
        TabOrder = 4
      end
      object DBEdit14: TDBEdit
        Left = 330
        Top = 80
        Width = 91
        Height = 21
        DataField = 'B_CONVENIO'
        DataSource = DSPrincipal
        TabOrder = 7
      end
      object DBEdit15: TDBEdit
        Left = 427
        Top = 80
        Width = 85
        Height = 21
        DataField = 'B_CODTRANSMISSAO'
        DataSource = DSPrincipal
        TabOrder = 8
      end
      object DBEdit16: TDBEdit
        Left = 3
        Top = 156
        Width = 357
        Height = 21
        CharCase = ecUpperCase
        DataField = 'B_LOGRADOURO'
        DataSource = DSPrincipal
        TabOrder = 15
      end
      object DBEdit17: TDBEdit
        Left = 518
        Top = 80
        Width = 82
        Height = 21
        CharCase = ecUpperCase
        DataField = 'B_MODALIDAE'
        DataSource = DSPrincipal
        TabOrder = 9
      end
      object DBMemo1: TDBMemo
        Tag = 4
        Left = 3
        Top = 232
        Width = 712
        Height = 34
        DataField = 'B_COMPLEMENTO'
        DataSource = DSPrincipal
        ScrollBars = ssVertical
        TabOrder = 19
      end
      object DBEdit18: TDBEdit
        Left = 468
        Top = 197
        Width = 38
        Height = 21
        CharCase = ecUpperCase
        DataField = 'B_UF'
        DataSource = DSPrincipal
        TabOrder = 18
      end
      object GroupBox3: TGroupBox
        Left = 3
        Top = 268
        Width = 341
        Height = 57
        Caption = ' Nosso Numero '
        TabOrder = 20
        object Label32: TLabel
          Left = 5
          Top = 13
          Width = 33
          Height = 13
          Caption = 'In'#237'cio.:'
          FocusControl = DBEdit19
        end
        object Label33: TLabel
          Left = 117
          Top = 13
          Width = 82
          Height = 13
          Caption = #218'lt. Num. Usada:'
          FocusControl = DBEdit20
        end
        object Label34: TLabel
          Left = 224
          Top = 13
          Width = 26
          Height = 13
          Caption = 'Final:'
        end
        object DBEdit19: TDBEdit
          Left = 5
          Top = 28
          Width = 100
          Height = 21
          DataField = 'B_NUM_INICIO'
          DataSource = DSPrincipal
          TabOrder = 0
        end
        object DBEdit20: TDBEdit
          Left = 114
          Top = 28
          Width = 100
          Height = 21
          TabStop = False
          Color = clSkyBlue
          DataField = 'B_NUM_MEIO'
          DataSource = DSPrincipal
          ReadOnly = True
          TabOrder = 1
        end
        object DBEdit21: TDBEdit
          Left = 224
          Top = 28
          Width = 100
          Height = 21
          DataField = 'B_NUM_FIM'
          DataSource = DSPrincipal
          TabOrder = 2
        end
      end
      object GroupBox4: TGroupBox
        Left = 362
        Top = 268
        Width = 351
        Height = 58
        Caption = 'Tarifas Banc'#225'rias'
        TabOrder = 21
        object Label38: TLabel
          Left = 7
          Top = 13
          Width = 105
          Height = 13
          Caption = 'Taxa Devolu'#231#227'o (R$):'
          FocusControl = DBEdit22
        end
        object Label39: TLabel
          Left = 124
          Top = 13
          Width = 64
          Height = 13
          Caption = 'Mora Dia (%)'
          FocusControl = DBEdit23
        end
        object Label40: TLabel
          Left = 238
          Top = 13
          Width = 87
          Height = 13
          Caption = 'Multa Atrazo (%):'
        end
        object DBEdit22: TDBEdit
          Left = 5
          Top = 28
          Width = 105
          Height = 21
          DataField = 'TAXA_DEVOLUCAO'
          DataSource = DSPrincipal
          TabOrder = 0
        end
        object DBEdit23: TDBEdit
          Left = 124
          Top = 28
          Width = 105
          Height = 21
          DataField = 'MORA_DIA'
          DataSource = DSPrincipal
          TabOrder = 1
        end
        object DBEdit24: TDBEdit
          Left = 237
          Top = 28
          Width = 91
          Height = 21
          DataField = 'MULTA_ATRAZO'
          DataSource = DSPrincipal
          TabOrder = 2
        end
      end
      object JvDBComboEdit1: TJvDBComboEdit
        Left = 127
        Top = 342
        Width = 585
        Height = 21
        DataField = 'B_FASTREPORTFILE'
        DataSource = DSPrincipal
        ButtonWidth = 26
        ReadOnly = True
        TabOrder = 23
      end
      object JvDBComboBox1: TJvDBComboBox
        Left = 4
        Top = 342
        Width = 117
        Height = 21
        DataField = 'B_LAYOUT'
        DataSource = DSPrincipal
        Items.Strings = (
          'Padrao'
          'Carne'
          'Fatura'
          'Padrao Entrega'
          'Padrao Duplicata'
          'Carne Duplicata'
          'Fatura Duplicata'
          'Padrao Entrega Duplicata')
        TabOrder = 22
        Values.Strings = (
          'lPadrao'
          'lCarne'
          'lFatura'
          'lPadraoEntrega'
          'lPadraoDuplicata'
          'lCarneDuplicata'
          'lFaturaDuplicata'
          'lPadraoEntregaDuplicata'
          '')
        ListSettings.OutfilteredValueFont.Charset = DEFAULT_CHARSET
        ListSettings.OutfilteredValueFont.Color = clRed
        ListSettings.OutfilteredValueFont.Height = -11
        ListSettings.OutfilteredValueFont.Name = 'Tahoma'
        ListSettings.OutfilteredValueFont.Style = []
      end
      object JvDBComboBox4: TJvDBComboBox
        Left = 4
        Top = 382
        Width = 117
        Height = 21
        DataField = 'B_TPLOGO'
        DataSource = DSPrincipal
        Items.Strings = (
          'Colorido'
          'Preto e Branco')
        TabOrder = 24
        Values.Strings = (
          'C'
          'P')
        ListSettings.OutfilteredValueFont.Charset = DEFAULT_CHARSET
        ListSettings.OutfilteredValueFont.Color = clRed
        ListSettings.OutfilteredValueFont.Height = -11
        ListSettings.OutfilteredValueFont.Name = 'Tahoma'
        ListSettings.OutfilteredValueFont.Style = []
      end
      object DBEdit3: TDBEdit
        Left = 136
        Top = 382
        Width = 96
        Height = 21
        DataField = 'DIAS_PROTESTO'
        DataSource = DSPrincipal
        TabOrder = 25
      end
      object DBEdit4: TDBEdit
        Left = 239
        Top = 382
        Width = 474
        Height = 21
        CharCase = ecUpperCase
        DataField = 'BLOCALPAGTO'
        DataSource = DSPrincipal
        TabOrder = 26
      end
      object JvDBComboBox5: TJvDBComboBox
        Left = 3
        Top = 117
        Width = 75
        Height = 21
        DataField = 'B_TIPOCARTEIRA'
        DataSource = DSPrincipal
        Items.Strings = (
          'Simples'
          'Registrada')
        TabOrder = 11
        Values.Strings = (
          'tctSimples'
          'tctRegistrada')
        ListSettings.OutfilteredValueFont.Charset = DEFAULT_CHARSET
        ListSettings.OutfilteredValueFont.Color = clRed
        ListSettings.OutfilteredValueFont.Height = -11
        ListSettings.OutfilteredValueFont.Name = 'Tahoma'
        ListSettings.OutfilteredValueFont.Style = []
      end
      object JvDBComboBox6: TJvDBComboBox
        Left = 135
        Top = 117
        Width = 126
        Height = 21
        DataField = 'B_RESPONEMISSAO'
        DataSource = DSPrincipal
        Items.Strings = (
          'Emite'
          'Banco Emite'
          'Banco Reemite'
          'Banco Nao Reemite')
        TabOrder = 13
        Values.Strings = (
          'tbCliEmite'
          'tbBancoEmite'
          'tbBancoReemite'
          'tbBancoNaoReemite')
        ListSettings.OutfilteredValueFont.Charset = DEFAULT_CHARSET
        ListSettings.OutfilteredValueFont.Color = clRed
        ListSettings.OutfilteredValueFont.Height = -11
        ListSettings.OutfilteredValueFont.Name = 'Tahoma'
        ListSettings.OutfilteredValueFont.Style = []
      end
      object DBEdit5: TDBEdit
        Left = 84
        Top = 117
        Width = 46
        Height = 21
        CharCase = ecUpperCase
        DataField = 'B_CARTEIRA'
        DataSource = DSPrincipal
        MaxLength = 5
        TabOrder = 12
      end
      object JvDBComboBox7: TJvDBComboBox
        Left = 72
        Top = 80
        Width = 37
        Height = 21
        DataField = 'B_AGENCIA_DIG'
        DataSource = DSPrincipal
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9')
        TabOrder = 3
        Values.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9')
        ListSettings.OutfilteredValueFont.Charset = DEFAULT_CHARSET
        ListSettings.OutfilteredValueFont.Color = clRed
        ListSettings.OutfilteredValueFont.Height = -11
        ListSettings.OutfilteredValueFont.Name = 'Tahoma'
        ListSettings.OutfilteredValueFont.Style = []
      end
      object JvDBComboBox8: TJvDBComboBox
        Left = 199
        Top = 80
        Width = 37
        Height = 21
        DataField = 'B_CONTADIGITO'
        DataSource = DSPrincipal
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9')
        TabOrder = 5
        Values.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9')
        ListSettings.OutfilteredValueFont.Charset = DEFAULT_CHARSET
        ListSettings.OutfilteredValueFont.Color = clRed
        ListSettings.OutfilteredValueFont.Height = -11
        ListSettings.OutfilteredValueFont.Name = 'Tahoma'
        ListSettings.OutfilteredValueFont.Style = []
      end
    end
  end
  inherited DSPrincipal: TDataSource
    Left = 576
  end
  inherited ActionList1: TActionList
    Left = 628
  end
  inherited cdsprincipal: TRESTDWClientSQL
    FieldDefs = <
      item
        Name = 'IDSYS_POINT_CLIENTE'
        Attributes = [faRequired]
        DataType = ftString
        Size = 38
      end
      item
        Name = 'IDEMPRESA'
        Attributes = [faRequired]
        DataType = ftString
        Size = 38
      end
      item
        Name = 'IDBANCO'
        Attributes = [faRequired]
        DataType = ftInteger
      end
      item
        Name = 'DESCRICAO'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'INSTRUCOES'
        DataType = ftMemo
      end
      item
        Name = 'B_CODIGO_CEDENTE'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_CODIGO_CEDENTE_DIG'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'B_AGENCIA'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_AGENCIA_DIG'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'B_CARACTITULO'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'B_CARTEIRA'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_CONVENIO'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_CEDENTE'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_CPF'
        DataType = ftString
        Size = 14
      end
      item
        Name = 'B_CNPJ'
        DataType = ftString
        Size = 18
      end
      item
        Name = 'B_NUM_INICIO'
        DataType = ftInteger
      end
      item
        Name = 'B_NUM_MEIO'
        DataType = ftInteger
      end
      item
        Name = 'B_NUM_FIM'
        DataType = ftInteger
      end
      item
        Name = 'B_BAIRRO'
        DataType = ftString
        Size = 40
      end
      item
        Name = 'B_CEP'
        DataType = ftString
        Size = 10
      end
      item
        Name = 'B_CIDADE'
        DataType = ftString
        Size = 50
      end
      item
        Name = 'B_CODTRANSMISSAO'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'B_COMPLEMENTO'
        DataType = ftString
        Size = 250
      end
      item
        Name = 'B_CONTA'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'B_CONTADIGITO'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'B_LOGRADOURO'
        DataType = ftString
        Size = 250
      end
      item
        Name = 'B_MODALIDAE'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_NOME'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_NUMERORES'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'B_TELEFONE'
        DataType = ftString
        Size = 15
      end
      item
        Name = 'B_TIPOCARTEIRA'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_TIPOINSCRICAO'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_RESPONEMISSAO'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_UF'
        DataType = ftString
        Size = 2
      end
      item
        Name = 'B_ORIENTACOESBANCO'
        DataType = ftBlob
      end
      item
        Name = 'BLOCALPAGTO'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_FASTREPORTFILE'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_LAYOUT'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_FILTRO'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_CAMINHOLOGO'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'B_TPLOGO'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'BANCO_TIPOCOBRANCA'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'BANCO_DIGITO'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'BANCO_NOME'
        DataType = ftString
        Size = 100
      end
      item
        Name = 'BANCO_NUMERO'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'BANCO_TAMAXNOSSONUM'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'LICENCA'
        DataType = ftString
        Size = 250
      end
      item
        Name = 'CODIGO'
        DataType = ftString
        Size = 3
      end
      item
        Name = 'COD_CONFIGURACAO1'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'COD_CONFIGURACAO2'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'LAYOUT'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'SEQUENCIA'
        DataType = ftInteger
      end
      item
        Name = 'TIPOIMPRESSAO'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'DIAS_PROTESTO'
        DataType = ftInteger
      end
      item
        Name = 'LICENCA_DESCONTO'
        DataType = ftString
        Size = 250
      end
      item
        Name = 'TAXA_DEVOLUCAO'
        DataType = ftBCD
        Size = 4
      end
      item
        Name = 'MORA_DIA'
        DataType = ftBCD
        Size = 4
      end
      item
        Name = 'MULTA_ATRAZO'
        DataType = ftBCD
        Size = 4
      end
      item
        Name = 'JUROS_DESCONTO'
        DataType = ftBCD
        Size = 4
      end
      item
        Name = 'IOF_DESCONTO'
        DataType = ftBCD
        Size = 4
      end
      item
        Name = 'TAXA_DESCONTO'
        DataType = ftBCD
        Size = 4
      end>
    Params = <
      item
        DataType = ftString
        Name = 'PEMPRESA'
        ParamType = ptInput
      end
      item
        DataType = ftString
        Name = 'PSYS_POINT_CLIENTE'
        ParamType = ptInput
      end
      item
        DataType = ftString
        Name = 'PCODIGO'
        ParamType = ptInput
      end>
    DataBase = DM.Coneccao
    SQL.Strings = (
      'SELECT * FROM banco'
      'WHERE (IDEMPRESA = :PEMPRESA)'
      'and ( IDSYS_POINT_CLIENTE = :PSYS_POINT_CLIENTE  )'
      '  AND (IDBANCO = :PCODIGO)')
    UpdateTableName = 'banco'
    Left = 520
    object cdsprincipalIDSYS_POINT_CLIENTE: TStringField
      FieldName = 'IDSYS_POINT_CLIENTE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Size = 38
    end
    object cdsprincipalIDEMPRESA: TStringField
      FieldName = 'IDEMPRESA'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Size = 38
    end
    object cdsprincipalIDBANCO: TIntegerField
      FieldName = 'IDBANCO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object cdsprincipalDESCRICAO: TStringField
      FieldName = 'DESCRICAO'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalINSTRUCOES: TMemoField
      FieldName = 'INSTRUCOES'
      ProviderFlags = [pfInUpdate]
      BlobType = ftMemo
    end
    object cdsprincipalB_CODIGO_CEDENTE: TStringField
      FieldName = 'B_CODIGO_CEDENTE'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_CODIGO_CEDENTE_DIG: TStringField
      FieldName = 'B_CODIGO_CEDENTE_DIG'
      ProviderFlags = [pfInUpdate]
      Size = 1
    end
    object cdsprincipalB_AGENCIA: TStringField
      FieldName = 'B_AGENCIA'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_AGENCIA_DIG: TStringField
      FieldName = 'B_AGENCIA_DIG'
      ProviderFlags = [pfInUpdate]
      Size = 1
    end
    object cdsprincipalB_CARACTITULO: TStringField
      FieldName = 'B_CARACTITULO'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalB_CARTEIRA: TStringField
      FieldName = 'B_CARTEIRA'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_CONVENIO: TStringField
      FieldName = 'B_CONVENIO'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_CEDENTE: TStringField
      FieldName = 'B_CEDENTE'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_CPF: TStringField
      FieldName = 'B_CPF'
      ProviderFlags = [pfInUpdate]
      Size = 14
    end
    object cdsprincipalB_CNPJ: TStringField
      FieldName = 'B_CNPJ'
      ProviderFlags = [pfInUpdate]
      Size = 18
    end
    object cdsprincipalB_NUM_INICIO: TIntegerField
      FieldName = 'B_NUM_INICIO'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalB_NUM_MEIO: TIntegerField
      FieldName = 'B_NUM_MEIO'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalB_NUM_FIM: TIntegerField
      FieldName = 'B_NUM_FIM'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalB_BAIRRO: TStringField
      FieldName = 'B_BAIRRO'
      ProviderFlags = [pfInUpdate]
      Size = 40
    end
    object cdsprincipalB_CEP: TStringField
      FieldName = 'B_CEP'
      ProviderFlags = [pfInUpdate]
      Size = 10
    end
    object cdsprincipalB_CIDADE: TStringField
      FieldName = 'B_CIDADE'
      ProviderFlags = [pfInUpdate]
      Size = 50
    end
    object cdsprincipalB_CODTRANSMISSAO: TStringField
      FieldName = 'B_CODTRANSMISSAO'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalB_COMPLEMENTO: TStringField
      FieldName = 'B_COMPLEMENTO'
      ProviderFlags = [pfInUpdate]
      Size = 250
    end
    object cdsprincipalB_CONTA: TStringField
      FieldName = 'B_CONTA'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalB_CONTADIGITO: TStringField
      FieldName = 'B_CONTADIGITO'
      ProviderFlags = [pfInUpdate]
      Size = 1
    end
    object cdsprincipalB_LOGRADOURO: TStringField
      FieldName = 'B_LOGRADOURO'
      ProviderFlags = [pfInUpdate]
      Size = 250
    end
    object cdsprincipalB_MODALIDAE: TStringField
      FieldName = 'B_MODALIDAE'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_NOME: TStringField
      FieldName = 'B_NOME'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_NUMERORES: TStringField
      FieldName = 'B_NUMERORES'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalB_TELEFONE: TStringField
      FieldName = 'B_TELEFONE'
      ProviderFlags = [pfInUpdate]
      Size = 15
    end
    object cdsprincipalB_TIPOCARTEIRA: TStringField
      FieldName = 'B_TIPOCARTEIRA'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_TIPOINSCRICAO: TStringField
      FieldName = 'B_TIPOINSCRICAO'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_RESPONEMISSAO: TStringField
      FieldName = 'B_RESPONEMISSAO'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_UF: TStringField
      FieldName = 'B_UF'
      ProviderFlags = [pfInUpdate]
      Size = 2
    end
    object cdsprincipalB_ORIENTACOESBANCO: TBlobField
      FieldName = 'B_ORIENTACOESBANCO'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalBLOCALPAGTO: TStringField
      FieldName = 'BLOCALPAGTO'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_FASTREPORTFILE: TStringField
      FieldName = 'B_FASTREPORTFILE'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_LAYOUT: TStringField
      FieldName = 'B_LAYOUT'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_FILTRO: TStringField
      FieldName = 'B_FILTRO'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_CAMINHOLOGO: TStringField
      FieldName = 'B_CAMINHOLOGO'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalB_TPLOGO: TStringField
      FieldName = 'B_TPLOGO'
      ProviderFlags = [pfInUpdate]
      Size = 1
    end
    object cdsprincipalBANCO_TIPOCOBRANCA: TStringField
      FieldName = 'BANCO_TIPOCOBRANCA'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalBANCO_DIGITO: TStringField
      FieldName = 'BANCO_DIGITO'
      ProviderFlags = [pfInUpdate]
      Size = 1
    end
    object cdsprincipalBANCO_NOME: TStringField
      FieldName = 'BANCO_NOME'
      ProviderFlags = [pfInUpdate]
      Size = 100
    end
    object cdsprincipalBANCO_NUMERO: TStringField
      FieldName = 'BANCO_NUMERO'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalBANCO_TAMAXNOSSONUM: TStringField
      FieldName = 'BANCO_TAMAXNOSSONUM'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalLICENCA: TStringField
      FieldName = 'LICENCA'
      ProviderFlags = [pfInUpdate]
      Size = 250
    end
    object cdsprincipalCODIGO: TStringField
      FieldName = 'CODIGO'
      ProviderFlags = [pfInUpdate]
      Size = 3
    end
    object cdsprincipalCOD_CONFIGURACAO1: TStringField
      FieldName = 'COD_CONFIGURACAO1'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalCOD_CONFIGURACAO2: TStringField
      FieldName = 'COD_CONFIGURACAO2'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalLAYOUT: TStringField
      FieldName = 'LAYOUT'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalSEQUENCIA: TIntegerField
      FieldName = 'SEQUENCIA'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalTIPOIMPRESSAO: TStringField
      FieldName = 'TIPOIMPRESSAO'
      ProviderFlags = [pfInUpdate]
      Size = 30
    end
    object cdsprincipalDIAS_PROTESTO: TIntegerField
      FieldName = 'DIAS_PROTESTO'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalLICENCA_DESCONTO: TStringField
      FieldName = 'LICENCA_DESCONTO'
      ProviderFlags = [pfInUpdate]
      Size = 250
    end
    object cdsprincipalTAXA_DEVOLUCAO: TBCDField
      FieldName = 'TAXA_DEVOLUCAO'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalMORA_DIA: TBCDField
      FieldName = 'MORA_DIA'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalMULTA_ATRAZO: TBCDField
      FieldName = 'MULTA_ATRAZO'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalJUROS_DESCONTO: TBCDField
      FieldName = 'JUROS_DESCONTO'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalIOF_DESCONTO: TBCDField
      FieldName = 'IOF_DESCONTO'
      ProviderFlags = [pfInUpdate]
    end
    object cdsprincipalTAXA_DESCONTO: TBCDField
      FieldName = 'TAXA_DESCONTO'
      ProviderFlags = [pfInUpdate]
    end
  end
end
