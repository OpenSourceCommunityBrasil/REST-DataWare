inherited FrameLstTransportadora: TFrameLstTransportadora
  OnDestroy = UniFrameDestroy
  inherited pgCadastro: TUniPageControl
    ActivePage = Tab_Consulta
    inherited Tab_Consulta: TUniTabSheet
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 871
      ExplicitHeight = 414
      inherited pnlfiltros: TUniPanel
        Height = 47
        Visible = True
        ExplicitHeight = 47
        object UniLabel34: TUniLabel
          Left = 6
          Top = 7
          Width = 27
          Height = 13
          Hint = ''
          Caption = 'Nome'
          TabOrder = 1
        end
        object dtNome: TUniEdit
          Left = 6
          Top = 21
          Width = 340
          Hint = ''
          Text = ''
          TabOrder = 2
        end
        object dtCPFCNPJ: TUniEdit
          Left = 352
          Top = 21
          Width = 121
          Hint = ''
          Text = ''
          TabOrder = 3
        end
        object UniLabel36: TUniLabel
          Left = 352
          Top = 7
          Width = 25
          Height = 13
          Hint = ''
          Caption = 'CNPJ'
          TabOrder = 4
        end
      end
      inherited GridList: TUniDBGrid
        Top = 77
        Height = 337
      end
    end
    inherited Tab_Cadastro: TUniTabSheet
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 871
      ExplicitHeight = 414
      object UniPanel2: TUniPanel
        Left = 0
        Top = 30
        Width = 871
        Height = 50
        Hint = ''
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        BorderStyle = ubsNone
        Caption = ''
        object unlbl1: TUniLabel
          Left = 3
          Top = 5
          Width = 33
          Height = 13
          Hint = ''
          Caption = 'C'#243'digo'
          TabOrder = 1
        end
        object ID: TUniDBEdit
          Left = 3
          Top = 22
          Width = 78
          Height = 22
          Hint = ''
          DataField = 'ID'
          TabOrder = 2
          TabStop = False
          ReadOnly = True
        end
        object NOME: TUniDBEdit
          Left = 86
          Top = 22
          Width = 305
          Height = 22
          Hint = ''
          DataField = 'NOME'
          TabOrder = 3
        end
        object UniLabel4: TUniLabel
          Left = 86
          Top = 5
          Width = 27
          Height = 13
          Hint = ''
          Caption = 'Nome'
          ParentFont = False
          Font.Color = clRed
          TabOrder = 4
        end
        object UniLabel6: TUniLabel
          Left = 397
          Top = 5
          Width = 25
          Height = 13
          Hint = ''
          Caption = 'CNPJ'
          ParentFont = False
          Font.Color = clRed
          TabOrder = 5
        end
        object CNPJ: TUniDBEdit
          Left = 397
          Top = 22
          Width = 174
          Height = 22
          Hint = ''
          DataField = 'CNPJ'
          TabOrder = 6
          InputMask.Mask = '99.999.999/9999-99'
          InputMask.UnmaskText = True
        end
        object IE: TUniDBEdit
          Left = 576
          Top = 22
          Width = 155
          Height = 22
          Hint = ''
          DataField = 'IE'
          TabOrder = 7
        end
        object UniLabel7: TUniLabel
          Left = 577
          Top = 5
          Width = 87
          Height = 13
          Hint = ''
          Caption = 'Inscri'#231#227'o Estadual'
          ParentFont = False
          Font.Color = clBlack
          TabOrder = 8
        end
      end
      object UniPanel3: TUniPanel
        Left = 0
        Top = 80
        Width = 871
        Height = 50
        Hint = ''
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        BorderStyle = ubsNone
        Caption = ''
        ExplicitTop = 85
        object UniLabel8: TUniLabel
          Left = 4
          Top = 6
          Width = 19
          Height = 13
          Hint = ''
          Caption = 'Cep'
          ParentFont = False
          Font.Color = clRed
          TabOrder = 1
        end
        object CEP: TUniDBEdit
          Left = 3
          Top = 22
          Width = 91
          Height = 22
          Hint = ''
          DataField = 'CEP'
          TabOrder = 2
          InputMask.Mask = '99999-999'
          InputMask.UnmaskText = True
        end
        object btnBuscaCEP: TUniButton
          Left = 98
          Top = 19
          Width = 75
          Height = 25
          Hint = ''
          Caption = 'Busca CEP'
          TabOrder = 3
          OnClick = btnBuscaCEPClick
        end
        object UniLabel9: TUniLabel
          Left = 178
          Top = 6
          Width = 33
          Height = 13
          Hint = ''
          Caption = 'Cidade'
          ParentFont = False
          Font.Color = clRed
          TabOrder = 4
        end
        object CIDADE: TUniDBEdit
          Left = 178
          Top = 22
          Width = 265
          Height = 22
          Hint = ''
          DataField = 'CIDADE'
          TabOrder = 5
        end
        object ESTADO: TUniDBComboBox
          Left = 449
          Top = 22
          Width = 55
          Hint = ''
          DataField = 'ESTADO'
          Style = csDropDownList
          Items.Strings = (
            'AC'
            'AL'
            'AP'
            'AM'
            'BA'
            'CE'
            'DF'
            'ES'
            'GO'
            'MA'
            'MT'
            'MS'
            'MG'
            'PA'
            'PB'
            'PR'
            'PE'
            'PI'
            'RJ'
            'RN'
            'RS'
            'RO'
            'RR'
            'SC'
            'SP'
            'SE'
            'TO')
          ItemIndex = 0
          TabOrder = 6
        end
        object UniLabel10: TUniLabel
          Left = 449
          Top = 6
          Width = 33
          Height = 13
          Hint = ''
          Caption = 'Estado'
          ParentFont = False
          Font.Color = clRed
          TabOrder = 7
        end
      end
      object UniPanel4: TUniPanel
        Left = 0
        Top = 130
        Width = 871
        Height = 50
        Hint = ''
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 3
        BorderStyle = ubsNone
        Caption = ''
        object UniLabel11: TUniLabel
          Left = 4
          Top = 5
          Width = 55
          Height = 13
          Hint = ''
          Caption = 'Logradouro'
          ParentFont = False
          Font.Color = clRed
          TabOrder = 1
        end
        object LOGRADOURO: TUniDBEdit
          Left = 3
          Top = 23
          Width = 339
          Height = 22
          Hint = ''
          DataField = 'LOGRADOURO'
          TabOrder = 2
        end
        object NUMERO: TUniDBEdit
          Left = 348
          Top = 23
          Width = 74
          Height = 22
          Hint = ''
          DataField = 'NUMERO'
          TabOrder = 3
        end
        object UniLabel12: TUniLabel
          Left = 348
          Top = 5
          Width = 37
          Height = 13
          Hint = ''
          Caption = 'Numero'
          ParentFont = False
          Font.Color = clRed
          TabOrder = 4
        end
        object COMPLEMENTO: TUniDBEdit
          Left = 428
          Top = 22
          Width = 308
          Height = 22
          Hint = ''
          DataField = 'COMPLEMENTO'
          TabOrder = 5
        end
        object UniLabel13: TUniLabel
          Left = 427
          Top = 5
          Width = 65
          Height = 13
          Hint = ''
          Caption = 'Complemento'
          ParentFont = False
          Font.Color = clBlack
          TabOrder = 6
        end
      end
      object UniPanel5: TUniPanel
        Left = 0
        Top = 180
        Width = 871
        Height = 50
        Hint = ''
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
        BorderStyle = ubsNone
        Caption = ''
        object UniLabel15: TUniLabel
          Left = 3
          Top = 6
          Width = 42
          Height = 13
          Hint = ''
          Caption = 'Telefone'
          ParentFont = False
          Font.Color = clBlack
          TabOrder = 1
        end
        object TELEFONE: TUniDBEdit
          Left = 3
          Top = 24
          Width = 86
          Height = 22
          Hint = ''
          DataField = 'TELEFONE'
          TabOrder = 2
          InputMask.Mask = '(99) 9999-9999'
          InputMask.UnmaskText = True
          InputMask.RemoveWhiteSpace = True
        end
        object CONTATO: TUniDBEdit
          Left = 95
          Top = 24
          Width = 387
          Height = 22
          Hint = ''
          DataField = 'CONTATO'
          TabOrder = 3
        end
        object UniLabel16: TUniLabel
          Left = 95
          Top = 6
          Width = 39
          Height = 13
          Hint = ''
          Caption = 'Contato'
          ParentFont = False
          Font.Color = clBlack
          TabOrder = 4
        end
      end
    end
  end
end
