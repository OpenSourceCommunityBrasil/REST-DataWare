object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'FileStream Class'
  ClientHeight = 301
  ClientWidth = 754
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 26
    Top = 106
    Width = 75
    Height = 25
    Caption = 'CreateFile'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 26
    Top = 151
    Width = 75
    Height = 25
    Caption = 'WriteLine'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 109
    Top = 108
    Width = 206
    Height = 21
    TabOrder = 2
    Text = 'c:\temp\temp.dat'
  end
  object Edit2: TEdit
    Left = 106
    Top = 153
    Width = 209
    Height = 21
    TabOrder = 3
    Text = 'Edit2'
  end
  object Button3: TButton
    Left = 26
    Top = 194
    Width = 75
    Height = 25
    Caption = 'ReadLine'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Edit3: TEdit
    Left = 106
    Top = 196
    Width = 209
    Height = 21
    TabOrder = 5
  end
  object Button4: TButton
    Left = 26
    Top = 230
    Width = 75
    Height = 25
    Caption = 'CloseFile'
    TabOrder = 6
    OnClick = Button4Click
  end
  object RadioGroup1: TRadioGroup
    Left = 26
    Top = 20
    Width = 185
    Height = 77
    Caption = 'StreamMode'
    ItemIndex = 0
    Items.Strings = (
      'FileStream'
      'MemoryStream')
    TabOrder = 7
    OnClick = RadioGroup1Click
  end
  object Button5: TButton
    Left = 336
    Top = 109
    Width = 75
    Height = 25
    Caption = 'CreateData'
    TabOrder = 8
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 336
    Top = 149
    Width = 75
    Height = 25
    Caption = 'ReadData'
    TabOrder = 9
    OnClick = Button6Click
  end
  object Memo1: TMemo
    Left = 424
    Top = 109
    Width = 321
    Height = 169
    TabOrder = 10
  end
end
