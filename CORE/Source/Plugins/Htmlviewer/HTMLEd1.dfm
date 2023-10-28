object Form1: TForm1
  Left = 496
  Top = 218
  Caption = 'HTML Editor'
  ClientHeight = 416
  ClientWidth = 806
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 507
    Top = 0
    Width = 5
    Height = 397
    Align = alRight
    ExplicitLeft = 513
    ExplicitTop = -6
  end
  object Panel3: TPanel
    Left = 0
    Top = 397
    Width = 806
    Height = 19
    Align = alBottom
    Alignment = taLeftJustify
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 0
  end
  object Viewer: THtmlViewer
    Left = 512
    Top = 0
    Width = 294
    Height = 397
    BorderStyle = htFocused
    DefBackground = clWindow
    DefFontName = 'Times New Roman'
    DefPreFontName = 'Courier New'
    HistoryMaxCount = 0
    HtOptions = [htShowDummyCaret]
    NoSelect = False
    PrintMarginBottom = 2.000000000000000000
    PrintMarginLeft = 2.000000000000000000
    PrintMarginRight = 2.000000000000000000
    PrintMarginTop = 2.000000000000000000
    PrintScale = 1.000000000000000000
    OnHotSpotClick = ViewerHotSpotClick
    OnHotSpotCovered = ViewerHotSpotCovered
    Align = alRight
    TabOrder = 1
    OnMouseUp = ViewerMouseUp
    Touch.InteractiveGestures = [igPan]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia]
  end
  object pEditor: TPanel
    Left = 0
    Top = 0
    Width = 507
    Height = 397
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object RichEdit: TRichEdit
      Left = 0
      Top = 26
      Width = 507
      Height = 371
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      PlainText = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
      Zoom = 100
      OnChange = RichEdChange
      OnSelectionChange = RichEditSelectionChange
    end
    object bButtons: TPanel
      Left = 0
      Top = 0
      Width = 507
      Height = 26
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object Button1: TButton
        Tag = 3
        Left = 48
        Top = 1
        Width = 25
        Height = 25
        Caption = 'B'
        TabOrder = 0
        OnClick = ButtonClick
      end
      object Button2: TButton
        Tag = 1
        Left = 72
        Top = 1
        Width = 25
        Height = 25
        Caption = 'I'
        TabOrder = 1
        OnClick = ButtonClick
      end
      object Button3: TButton
        Tag = 2
        Left = 96
        Top = 1
        Width = 25
        Height = 25
        Caption = 'U'
        TabOrder = 2
        OnClick = ButtonClick
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 400
    object File1: TMenuItem
      Caption = '&File'
      object New1: TMenuItem
        Caption = '&New'
        OnClick = New1Click
      end
      object NewHTML: TMenuItem
        Caption = 'New &HTML'
        OnClick = New1Click
      end
      object Open1: TMenuItem
        Caption = '&Open'
        ShortCut = 114
        OnClick = Open1Click
      end
      object Save1: TMenuItem
        Caption = '&Save'
        ShortCut = 113
        OnClick = Save1Click
      end
      object Saveas1: TMenuItem
        Caption = 'Save to File'
        OnClick = Saveas1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object ExitItem: TMenuItem
        Caption = 'E&xit'
        OnClick = ExitItemClick
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      object Copy1: TMenuItem
        Caption = '&Copy'
        ShortCut = 16429
        OnClick = EditCopy
      end
      object Cut1: TMenuItem
        Caption = 'Cu&t'
        ShortCut = 8238
        OnClick = EditCut
      end
      object Paste1: TMenuItem
        Caption = '&Paste'
        ShortCut = 8237
        OnClick = EditPaste
      end
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'htm'
    Filter = 'HTML Files|*.htm; *.html|All Files|*.*'
    Left = 440
  end
  object SaveDialog1: TSaveDialog
    Left = 472
  end
end
