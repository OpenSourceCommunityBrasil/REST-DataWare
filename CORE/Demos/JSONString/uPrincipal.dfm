object fJSONStringSample: TfJSONStringSample
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Load from JSON String'
  ClientHeight = 287
  ClientWidth = 566
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 8
    Top = 119
    Width = 550
    Height = 160
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 467
    Height = 105
    TabOrder = 1
  end
  object Executar: TButton
    Left = 483
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Executar'
    TabOrder = 2
    OnClick = ExecutarClick
  end
  object DWResponseTranslator1: TDWResponseTranslator
    ElementAutoReadRootIndex = True
    ElementRootBaseIndex = -1
    RequestOpen = rtGet
    RequestInsert = rtPost
    RequestEdit = rtPost
    RequestDelete = rtDelete
    FieldDefs = <>
    Left = 88
    Top = 80
  end
  object RESTDWClientSQL1: TRESTDWClientSQL
    FieldDefs = <>
    MasterCascadeDelete = True
    Datapacks = -1
    DataCache = False
    Params = <>
    CacheUpdateRecords = True
    AutoCommitData = False
    AutoRefreshAfterCommit = False
    DWResponseTranslator = DWResponseTranslator1
    Left = 128
    Top = 80
  end
  object DataSource1: TDataSource
    DataSet = RESTDWClientSQL1
    Left = 168
    Top = 80
  end
end
