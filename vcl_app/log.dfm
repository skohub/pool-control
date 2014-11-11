object FLog: TFLog
  Left = 0
  Top = 0
  Caption = #1046#1091#1088#1085#1072#1083' '#1089#1086#1073#1099#1090#1080#1081
  ClientHeight = 300
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 635
    Height = 29
    AutoSize = True
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        Width = 629
      end>
    object ToolBar1: TToolBar
      Left = 9
      Top = 0
      Width = 622
      Height = 25
      Caption = 'ToolBar1'
      Images = FMain.Img
      TabOrder = 0
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = ARefresh
      end
      object ToolButton2: TToolButton
        Left = 23
        Top = 0
        Action = ARefreshAll
      end
      object ToolButton3: TToolButton
        Left = 46
        Top = 0
        Action = AClearLog
      end
    end
  end
  object Vst: TVirtualStringTree
    Left = 0
    Top = 29
    Width = 635
    Height = 271
    Align = alClient
    Header.AutoSizeIndex = 1
    Header.DefaultHeight = 34
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 34
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    TabOrder = 1
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toUseExplorerTheme, toHideTreeLinesIfThemed]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toRightClickSelect]
    OnFreeNode = VstFreeNode
    OnGetText = VstGetText
    Columns = <
      item
        Position = 0
        Width = 150
        WideText = #1044#1072#1090#1072
      end
      item
        Position = 1
        Width = 481
        WideText = #1057#1090#1086#1083
      end>
  end
  object ActionList: TActionList
    Images = FMain.Img
    Left = 432
    Top = 152
    object ARefresh: TAction
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 4
      ShortCut = 16466
      OnExecute = ARefreshExecute
    end
    object ARefreshAll: TAction
      Caption = #1042#1089#1077' '#1079#1072#1087#1080#1089#1080
      Hint = #1042#1089#1077' '#1079#1072#1087#1080#1089#1080
      ImageIndex = 4
      OnExecute = ARefreshAllExecute
    end
    object AClearLog: TAction
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      Hint = #1054#1095#1080#1089#1090#1080#1090#1100
      ImageIndex = 8
      OnExecute = AClearLogExecute
    end
  end
end
