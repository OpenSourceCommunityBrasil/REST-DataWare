object FrmDWUpdSqlEditor: TFrmDWUpdSqlEditor
  Left = 401
  Top = 133
  BorderWidth = 5
  Caption = 'RESTDWClientSQL Editor'
  ClientHeight = 707
  ClientWidth = 1053
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  TextHeight = 13
  object PnlSQL: TPanel
    Left = 0
    Top = 0
    Width = 1053
    Height = 666
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PageControl: TPageControl
      Left = 209
      Top = 0
      Width = 844
      Height = 666
      ActivePage = tsInsertSQL
      Align = alClient
      TabOrder = 0
      OnChange = PageControlChange
      object tsInsertSQL: TTabSheet
        BorderWidth = 5
        Caption = 'Insert'
        object mInsertSQL: TMemo
          Left = 0
          Top = 0
          Width = 826
          Height = 628
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnDragDrop = mInsertSQLDragDrop
          OnDragOver = mInsertSQLDragOver
        end
      end
      object tsModifySQL: TTabSheet
        Caption = 'Modify'
        ImageIndex = 1
        object mModifySQL: TMemo
          Left = 0
          Top = 0
          Width = 836
          Height = 638
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnDragDrop = mInsertSQLDragDrop
          OnDragOver = mInsertSQLDragOver
        end
      end
      object tsDeleteSQL: TTabSheet
        Caption = 'Delete'
        ImageIndex = 2
        object mDeleteSQL: TMemo
          Left = 0
          Top = 0
          Width = 836
          Height = 638
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnDragDrop = mInsertSQLDragDrop
          OnDragOver = mInsertSQLDragOver
        end
      end
      object tsLockSQL: TTabSheet
        Caption = 'Lock'
        ImageIndex = 3
        object mLockSQL: TMemo
          Left = 0
          Top = 0
          Width = 836
          Height = 638
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnDragDrop = mInsertSQLDragDrop
          OnDragOver = mInsertSQLDragOver
        end
      end
      object tsUnlockSQL: TTabSheet
        Caption = 'Unlock'
        ImageIndex = 4
        object mUnlockSQL: TMemo
          Left = 0
          Top = 0
          Width = 836
          Height = 638
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnDragDrop = mInsertSQLDragDrop
          OnDragOver = mInsertSQLDragOver
        end
      end
      object tsFetchRowSQL: TTabSheet
        Caption = 'FetchRow'
        ImageIndex = 5
        object mFetchRowSQL: TMemo
          Left = 0
          Top = 0
          Width = 836
          Height = 638
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnDragDrop = mInsertSQLDragDrop
          OnDragOver = mInsertSQLDragOver
        end
      end
    end
    object pSQLEditor: TPanel
      Left = 0
      Top = 0
      Width = 209
      Height = 666
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object labSql: TLabel
        Left = 0
        Top = 0
        Width = 209
        Height = 23
        Align = alTop
        AutoSize = False
        Caption = ' .: TABLES'
        Color = clGrayText
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object Label1: TLabel
        Left = 0
        Top = 257
        Width = 209
        Height = 23
        Align = alTop
        AutoSize = False
        Caption = ' .: KEYS'
        Color = clGrayText
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object Label2: TLabel
        Left = 0
        Top = 153
        Width = 209
        Height = 23
        Align = alTop
        AutoSize = False
        Caption = ' .: SQL TYPE'
        Color = clGrayText
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object Label3: TLabel
        Left = 0
        Top = 425
        Width = 209
        Height = 23
        Align = alTop
        AutoSize = False
        Caption = ' .: FIELDS'
        Color = clGrayText
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = False
        Layout = tlCenter
      end
      object lbTables: TListBox
        Left = 0
        Top = 23
        Width = 209
        Height = 130
        Align = alTop
        BorderStyle = bsNone
        DragMode = dmAutomatic
        ItemHeight = 13
        TabOrder = 0
        OnClick = lbTablesClick
        OnKeyUp = lbTablesKeyUp
      end
      object lbFields: TListBox
        Left = 0
        Top = 448
        Width = 209
        Height = 218
        Align = alClient
        BorderStyle = bsNone
        DragMode = dmAutomatic
        ItemHeight = 13
        MultiSelect = True
        TabOrder = 1
      end
      object pSQLTypes: TPanel
        Left = 0
        Top = 176
        Width = 209
        Height = 81
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object rbModifySQL: TRadioButton
          Left = 88
          Top = 8
          Width = 92
          Height = 17
          Caption = 'Modify'
          TabOrder = 0
          OnClick = rbModifySQLClick
        end
        object rbInsertSQL: TRadioButton
          Left = 8
          Top = 8
          Width = 73
          Height = 17
          Caption = 'Insert'
          Checked = True
          TabOrder = 1
          TabStop = True
          OnClick = rbInsertSQLClick
        end
        object rbLockSQL: TRadioButton
          Left = 88
          Top = 32
          Width = 92
          Height = 17
          Caption = 'Lock'
          TabOrder = 2
          OnClick = rbLockSQLClick
        end
        object rbDeleteSQL: TRadioButton
          Left = 8
          Top = 32
          Width = 73
          Height = 17
          Caption = 'Delete'
          TabOrder = 3
          OnClick = rbDeleteSQLClick
        end
        object rbUnLockSQL: TRadioButton
          Left = 8
          Top = 56
          Width = 73
          Height = 17
          Caption = 'Unlock'
          TabOrder = 4
          OnClick = rbUnLockSQLClick
        end
        object rbFetchRowSQL: TRadioButton
          Left = 88
          Top = 56
          Width = 92
          Height = 17
          Caption = 'FetchRow'
          TabOrder = 5
          OnClick = rbFetchRowSQLClick
        end
      end
      object lbKeyFields: TListBox
        Left = 0
        Top = 280
        Width = 209
        Height = 145
        Align = alTop
        BorderStyle = bsNone
        DragMode = dmAutomatic
        ItemHeight = 13
        MultiSelect = True
        TabOrder = 3
      end
    end
  end
  object PnlAction: TPanel
    Left = 0
    Top = 666
    Width = 1053
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      1053
      41)
    object BtnOk: TButton
      Left = 889
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = BtnOkClick
    end
    object BtnCancelar: TButton
      Left = 970
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = BtnCancelarClick
    end
  end
end
