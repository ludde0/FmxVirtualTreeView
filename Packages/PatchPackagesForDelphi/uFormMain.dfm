object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Patch packages for this Delphi'
  ClientHeight = 561
  ClientWidth = 824
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 824
    Height = 105
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      824
      105)
    object lblFolder: TLabel
      Left = 16
      Top = 19
      Width = 83
      Height = 15
      Caption = 'Packages folder'
    end
    object lblSuffix: TLabel
      Left = 16
      Top = 59
      Width = 55
      Height = 15
      Caption = 'New suffix'
    end
    object edFolder: TEdit
      Left = 120
      Top = 16
      Width = 569
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object btnBrowse: TButton
      Left = 703
      Top = 15
      Width = 105
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Browse...'
      TabOrder = 1
      OnClick = btnBrowseClick
    end
    object edSuffix: TEdit
      Left = 120
      Top = 56
      Width = 89
      Height = 23
      TabOrder = 2
    end
    object btnDetect: TButton
      Left = 223
      Top = 55
      Width = 145
      Height = 25
      Caption = 'Detect installed'
      TabOrder = 3
      OnClick = btnDetectClick
    end
    object chkBackup: TCheckBox
      Left = 390
      Top = 58
      Width = 195
      Height = 17
      Caption = 'Back up originals to _Backup'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object btnScan: TButton
      Left = 592
      Top = 55
      Width = 105
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Scan'
      TabOrder = 5
      OnClick = btnScanClick
    end
    object btnPatch: TButton
      Left = 703
      Top = 55
      Width = 105
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Patch'
      TabOrder = 6
      OnClick = btnPatchClick
    end
  end
  object memLog: TMemo
    Left = 0
    Top = 381
    Width = 824
    Height = 180
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object lvFiles: TListView
    Left = 0
    Top = 105
    Width = 824
    Height = 276
    Align = alClient
    Columns = <
      item
        Caption = 'File'
        Width = 260
      end
      item
        Caption = 'Current suffix'
        Width = 110
      end
      item
        Caption = 'Status'
        Width = 430
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    ExplicitTop = 99
  end
end
