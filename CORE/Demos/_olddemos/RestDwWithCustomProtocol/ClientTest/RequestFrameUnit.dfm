object RequestFrame: TRequestFrame
  Left = 0
  Top = 0
  Width = 953
  Height = 579
  TabOrder = 0
  object ResponseDBGrid: TDBGrid
    Left = 0
    Top = 201
    Width = 953
    Height = 378
    Align = alClient
    DataSource = ResponseDataSource
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 953
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object DMLTypeRadioGroup: TRadioGroup
      Left = 9
      Top = 9
      Width = 144
      Height = 40
      Caption = 'DMLType'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'Select'
        'Command')
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 57
    Width = 953
    Height = 144
    Align = alTop
    Caption = 'Panel2'
    TabOrder = 2
    object SqlMemo: TMemo
      Left = 1
      Top = 1
      Width = 407
      Height = 142
      Align = alClient
      Font.Charset = OEM_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Terminal'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      ExplicitWidth = 456
    end
    object ParamsDBGrid: TDBGrid
      Left = 408
      Top = 1
      Width = 544
      Height = 142
      Align = alRight
      DataSource = ParamsDataSource
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
  end
  object ResponseDataSource: TDataSource
    DataSet = ResponseDataSet
    Left = 56
    Top = 248
  end
  object ParamsDataSource: TDataSource
    DataSet = ParamsDataSet
    Left = 592
    Top = 80
  end
  object ResponseDataSet: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 56
    Top = 296
  end
  object ParamsDataSet: TFDMemTable
    Active = True
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 592
    Top = 136
    object ParamsDataSetPARAM_NAME: TStringField
      DisplayLabel = 'Param name'
      DisplayWidth = 19
      FieldName = 'PARAM_NAME'
      Required = True
      Size = 30
    end
    object ParamsDataSetPARAM_TYPE: TIntegerField
      DisplayLabel = 'Param type'
      FieldName = 'PARAM_TYPE'
      Required = True
      Visible = False
    end
    object ParamsDataSetPARA_TYPE_DESCRIPTION: TStringField
      DisplayLabel = 'Param type'
      DisplayWidth = 12
      FieldKind = fkLookup
      FieldName = 'PARA_TYPE_DESCRIPTION'
      LookupDataSet = ParamTypeDataset
      LookupKeyFields = 'CODE'
      LookupResultField = 'DESCRIPTION'
      KeyFields = 'PARAM_TYPE'
      Size = 10
      Lookup = True
    end
    object ParamsDataSetPARAM_VALUE: TStringField
      DisplayLabel = 'Param value'
      DisplayWidth = 53
      FieldName = 'PARAM_VALUE'
      Size = 60
    end
  end
  object ParamTypeDataset: TFDMemTable
    Active = True
    IndexFieldNames = 'CODE'
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 784
    Top = 144
    object ParamTypeDatasetCODE: TIntegerField
      FieldName = 'CODE'
    end
    object ParamTypeDatasetDESCRIPTION: TStringField
      FieldName = 'DESCRIPTION'
      Size = 10
    end
  end
  object ParamTypeDataSource: TDataSource
    DataSet = ParamTypeDataset
    Left = 784
    Top = 88
  end
end
