object FReport: TFReport
  Left = 0
  Top = 0
  Caption = #1054#1090#1095#1077#1090
  ClientHeight = 524
  ClientWidth = 892
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 892
    Height = 29
    AutoSize = True
    Bands = <
      item
        Control = ToolBar1
        ImageIndex = -1
        Width = 886
      end>
    object ToolBar1: TToolBar
      Left = 9
      Top = 0
      Width = 879
      Height = 25
      Caption = 'ToolBar1'
      Images = FMain.Img
      TabOrder = 0
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = ARefresh
      end
      object ToolButton3: TToolButton
        Left = 23
        Top = 0
        Action = AExport
      end
      object ToolButton2: TToolButton
        Left = 46
        Top = 0
        Action = AClose
      end
      object BInterval: TButton
        Left = 69
        Top = 0
        Width = 125
        Height = 22
        Caption = #1042#1099#1073#1088#1072#1090#1100' '#1080#1085#1090#1077#1088#1074#1072#1083
        DropDownMenu = IntervalMenu
        Style = bsSplitButton
        TabOrder = 2
        OnClick = BIntervalClick
      end
      object Label1: TLabel
        Left = 194
        Top = 0
        Width = 46
        Height = 22
        Caption = '   '#1044#1072#1090#1072' '#1089' '
        Layout = tlCenter
      end
      object DStart: TDateTimePicker
        Left = 240
        Top = 0
        Width = 95
        Height = 22
        Date = 41543.922390972220000000
        Time = 41543.922390972220000000
        TabOrder = 0
        OnChange = DStartChange
      end
      object Label2: TLabel
        Left = 335
        Top = 0
        Width = 24
        Height = 22
        Caption = '   '#1087#1086' '
        Layout = tlCenter
      end
      object DEnd: TDateTimePicker
        Left = 359
        Top = 0
        Width = 114
        Height = 22
        Date = 41543.922390972220000000
        Time = 41543.922390972220000000
        ShowCheckbox = True
        Checked = False
        TabOrder = 1
        OnChange = DStartChange
      end
    end
  end
  object Vst: TVirtualStringTree
    Left = 0
    Top = 29
    Width = 892
    Height = 476
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 34
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 34
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    TabOrder = 0
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseExplorerTheme]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toRightClickSelect]
    OnBeforeItemErase = VstBeforeItemErase
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
        Width = 100
        WideText = #1057#1090#1086#1083
      end
      item
        Position = 2
        Width = 100
        WideText = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100
      end
      item
        Position = 3
        Width = 100
        WideText = #1057#1091#1084#1084#1072
      end
      item
        Position = 4
        Width = 100
        WideText = #1057#1082#1080#1076#1082#1072
      end
      item
        Position = 5
        Width = 130
        WideText = #1042#1083#1072#1076#1077#1083#1077#1094' '#1082#1072#1088#1090#1099
      end>
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 505
    Width = 892
    Height = 19
    Panels = <
      item
        Text = #1048#1090#1086#1075', '#1095
        Width = 150
      end
      item
        Text = #1048#1090#1086#1075', '#1088'.'
        Width = 150
      end
      item
        Width = 150
      end
      item
        Text = #1057#1090#1086#1083' 1, '#1088
        Width = 120
      end
      item
        Text = #1057#1090#1086#1083' 2, '#1088
        Width = 120
      end
      item
        Text = #1057#1090#1086#1083'3, '#1088
        Width = 120
      end
      item
        Text = #1057#1090#1086#1083' 4, '#1088
        Width = 120
      end
      item
        Width = 100
      end>
  end
  object ActionList: TActionList
    Images = FMain.Img
    Left = 16
    Top = 80
    object ARefresh: TAction
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      ImageIndex = 4
      ShortCut = 16466
      OnExecute = ARefreshExecute
    end
    object AClose: TAction
      Caption = #1047#1072#1082#1088#1099#1090#1100
      Hint = #1047#1072#1082#1088#1099#1090#1100
      ImageIndex = 3
      ShortCut = 32883
      OnExecute = ACloseExecute
    end
    object AExport: TAction
      Caption = 'AExport'
      ImageIndex = 9
      OnExecute = AExportExecute
    end
  end
  object IntervalMenu: TPopupMenu
    Left = 352
    Top = 72
    object N1Day: TMenuItem
      Caption = #1047#1072' '#1076#1077#1085#1100
      OnClick = N1DayClick
    end
    object N7Days: TMenuItem
      Caption = #1047#1072' '#1085#1077#1076#1077#1083#1102
      OnClick = N7DaysClick
    end
    object NLastMonth: TMenuItem
      Caption = #1055#1088#1086#1096#1083#1099#1081' '#1084#1077#1089#1103#1094
      OnClick = NLastMonthClick
    end
    object NCurMonth: TMenuItem
      Caption = #1058#1077#1082#1091#1097#1080#1081' '#1084#1077#1089#1103#1094
      OnClick = NCurMonthClick
    end
  end
  object SaveDialog: TSaveDialog
    Left = 192
    Top = 96
  end
end
