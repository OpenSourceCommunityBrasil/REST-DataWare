inherited frmBaseItem: TfrmBaseItem
  ClientHeight = 467
  ClientWidth = 809
  Caption = 'frmBaseItem'
  OnShow = UniFormShow
  OnCreate = UniFormCreate
  ExplicitWidth = 825
  ExplicitHeight = 506
  PixelsPerInch = 96
  TextHeight = 13
  inherited UniStatusBar1: TUniStatusBar
    Top = 448
    Width = 809
    ExplicitLeft = 0
    ExplicitTop = 448
    ExplicitWidth = 809
  end
  object UniPanel1: TUniPanel
    Left = 0
    Top = 400
    Width = 809
    Height = 48
    Hint = ''
    Align = alBottom
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 1
    BorderStyle = ubsNone
    Caption = ''
    object UniBitBtn1: TUniBitBtn
      Left = 641
      Top = 4
      Width = 75
      Height = 39
      Hint = ''
      Caption = 'Salvar'
      TabOrder = 1
      OnClick = UniBitBtn1Click
    end
    object UniBitBtn2: TUniBitBtn
      Left = 729
      Top = 4
      Width = 75
      Height = 39
      Hint = ''
      Caption = 'Cancelar'
      TabOrder = 2
      OnClick = UniBitBtn2Click
    end
  end
  object UniPanel2: TUniPanel
    Left = 0
    Top = 0
    Width = 809
    Height = 20
    Hint = ''
    Align = alTop
    Anchors = [akLeft, akTop, akRight]
    ParentFont = False
    Font.Height = -13
    Font.Style = [fsBold]
    TabOrder = 2
    Caption = ''
    object lbItem: TUniLabel
      Left = 1
      Top = 1
      Width = 36
      Height = 16
      Hint = ''
      Caption = 'lbItem'
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      ParentFont = False
      Font.Height = -13
      TabOrder = 1
    end
  end
end
