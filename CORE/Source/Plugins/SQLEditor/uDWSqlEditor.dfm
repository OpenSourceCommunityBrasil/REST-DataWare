object FrmDWSqlEditor: TFrmDWSqlEditor
  Left = 0
  Top = 0
  BorderWidth = 5
  Caption = 'RESTDWClientSQL Editor'
  ClientHeight = 451
  ClientWidth = 575
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 217
    Width = 575
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 129
    ExplicitWidth = 306
  end
  object PnlSQL: TPanel
    Left = 0
    Top = 0
    Width = 575
    Height = 217
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object PnlButton: TPanel
      Left = 480
      Top = 0
      Width = 95
      Height = 217
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object BtnExecute: TButton
        Left = 8
        Top = 20
        Width = 80
        Height = 25
        Caption = 'Execute'
        TabOrder = 0
        OnClick = BtnExecuteClick
      end
    end
    object PageControl: TPageControl
      Left = 0
      Top = 0
      Width = 480
      Height = 217
      ActivePage = TabSheetSQL
      Align = alClient
      TabOrder = 1
      object TabSheetSQL: TTabSheet
        BorderWidth = 5
        Caption = 'SQL Command'
        object Memo: TMemo
          Left = 0
          Top = 0
          Width = 462
          Height = 179
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
    end
  end
  object PnlAction: TPanel
    Left = 0
    Top = 410
    Width = 575
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      575
      41)
    object BtnOk: TButton
      Left = 412
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object BtnCancelar: TButton
      Left = 493
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object PageControlResult: TPageControl
    Left = 0
    Top = 220
    Width = 575
    Height = 190
    ActivePage = TabSheetTable
    Align = alClient
    TabOrder = 2
    object TabSheetTable: TTabSheet
      BorderWidth = 5
      Caption = 'RecordSet'
      object DBGridRecord: TDBGrid
        Left = 0
        Top = 0
        Width = 557
        Height = 152
        Align = alClient
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
end
