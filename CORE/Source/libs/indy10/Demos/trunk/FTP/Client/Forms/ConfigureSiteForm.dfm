object frmConfigureSite: TfrmConfigureSite
  Left = 321
  Top = 279
  Width = 230
  Height = 263
  BorderIcons = [biSystemMenu]
  Caption = 'frmConfigureSite'
  Color = clBtnFace
  Constraints.MaxHeight = 263
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 68
    Height = 13
    Caption = 'Display Name:'
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 41
    Height = 13
    Caption = 'Address:'
  end
  object Label3: TLabel
    Left = 8
    Top = 88
    Width = 56
    Height = 13
    Caption = 'User Name:'
  end
  object Label4: TLabel
    Left = 8
    Top = 128
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  object Label5: TLabel
    Left = 8
    Top = 168
    Width = 58
    Height = 13
    Caption = 'Root Folder:'
  end
  object cbMaskPassword: TCheckBox
    Left = 168
    Top = 128
    Width = 49
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Mask'
    Checked = True
    State = cbChecked
    TabOrder = 0
    OnClick = cbMaskPasswordClick
  end
  object edDisplayName: TEdit
    Left = 16
    Top = 24
    Width = 201
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Text = 'edDisplayName'
  end
  object edAddress: TEdit
    Left = 16
    Top = 64
    Width = 201
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    Text = 'edAddress'
  end
  object edUserName: TEdit
    Left = 16
    Top = 104
    Width = 201
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    Text = 'edUserName'
  end
  object edPassword: TEdit
    Left = 16
    Top = 144
    Width = 201
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    Text = 'edPassword'
  end
  object btnCancel: TButton
    Left = 144
    Top = 208
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object btnOk: TButton
    Left = 72
    Top = 208
    Width = 67
    Height = 25
    Caption = 'Save'
    ModalResult = 1
    TabOrder = 6
  end
  object edRootFolder: TEdit
    Left = 16
    Top = 184
    Width = 201
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
    Text = 'edRootFolder'
  end
  object btnDelete: TButton
    Left = 8
    Top = 208
    Width = 57
    Height = 25
    Caption = 'Delete'
    ModalResult = 7
    TabOrder = 8
  end
end
