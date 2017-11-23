inherited frmValidaCampos: TfrmValidaCampos
  ClientHeight = 408
  ClientWidth = 766
  Caption = 'Log - Campos Obrigat'#243'rios'
  ExplicitWidth = 782
  ExplicitHeight = 447
  PixelsPerInch = 96
  TextHeight = 13
  inherited UniStatusBar1: TUniStatusBar
    Top = 389
    Width = 766
    ExplicitLeft = 0
    ExplicitTop = 389
    ExplicitWidth = 766
  end
  object UniPanel2: TUniPanel
    Left = 0
    Top = 355
    Width = 766
    Height = 34
    Hint = ''
    Align = alBottom
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 1
    BorderStyle = ubsNone
    Caption = ''
    DesignSize = (
      766
      34)
    object btnok: TUniBitBtn
      Left = 678
      Top = 2
      Width = 85
      Height = 30
      Hint = ''
      Caption = 'OK'
      Anchors = [akTop, akRight]
      TabOrder = 1
      OnClick = btnokClick
    end
  end
  object UniDBGrid1: TUniDBGrid
    Left = 0
    Top = 43
    Width = 766
    Height = 312
    Hint = ''
    DataSource = dslog
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgTabs, dgCancelOnExit]
    LoadMask.Message = 'Loading data...'
    Align = alClient
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    Columns = <
      item
        FieldName = 'campo'
        Title.Caption = 'Campo'
        Width = 133
      end
      item
        FieldName = 'valor'
        Title.Caption = 'Valor'
        Width = 157
      end
      item
        FieldName = 'mensagem'
        Title.Caption = 'Mensagem'
        Width = 433
      end>
  end
  object UniPanel1: TUniPanel
    Left = 0
    Top = 0
    Width = 766
    Height = 43
    Hint = ''
    Align = alTop
    Anchors = [akLeft, akTop, akRight]
    ParentFont = False
    Font.Height = -16
    Font.Style = [fsBold]
    TabOrder = 3
    BorderStyle = ubsNone
    Caption = 'Log - Campos Obrigat'#243'rios'
  end
  object dslog: TDataSource
    Left = 304
    Top = 120
  end
end
