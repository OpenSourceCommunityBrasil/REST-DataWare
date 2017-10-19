object frmConfigureApplication: TfrmConfigureApplication
  Left = 196
  Top = 179
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'frmConfigureApplication'
  ClientHeight = 171
  ClientWidth = 233
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 130
    Width = 233
    Height = 41
    Align = alBottom
    Caption = 'Panel1'
    TabOrder = 0
    object btnCancel: TButton
      Left = 149
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object btnOk: TButton
      Left = 69
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 1
    end
  end
  object pcMain: TPageControl
    Left = 0
    Top = 0
    Width = 233
    Height = 130
    ActivePage = tsLogColors
    Align = alClient
    TabOrder = 1
    object tsLogColors: TTabSheet
      Caption = 'Log Colors'
      object Label1: TLabel
        Left = 8
        Top = 0
        Width = 41
        Height = 13
        Caption = 'Element:'
      end
      object Label2: TLabel
        Left = 0
        Top = 40
        Width = 27
        Height = 13
        Caption = 'Color:'
      end
      object cbElements: TComboBox
        Left = 16
        Top = 16
        Width = 201
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbElementsChange
      end
      object cgColors: TColorGrid
        Left = 16
        Top = 56
        Width = 200
        Height = 40
        GridOrdering = go8x2
        BackgroundEnabled = False
        TabOrder = 1
        OnChange = cgColorsChange
      end
    end
  end
end
