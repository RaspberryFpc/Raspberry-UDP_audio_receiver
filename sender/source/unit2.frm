object Form2: TForm2
  Left = 668
  Height = 220
  Top = 43
  Width = 504
  Caption = 'Sender Settings'
  ClientHeight = 220
  ClientWidth = 504
  Position = poDesktopCenter
  LCLVersion = '8.8'
  OnCreate = FormCreate
  OnShow = FormShow
  object EdTarget: TEdit
    Left = 302
    Height = 29
    Top = 48
    Width = 120
    Alignment = taCenter
    Font.Height = -13
    ParentFont = False
    TabOrder = 0
  end
  object EdPort: TEdit
    Left = 302
    Height = 29
    Top = 80
    Width = 120
    Alignment = taCenter
    Font.Height = -13
    ParentFont = False
    TabOrder = 1
  end
  object Label1: TLabel
    Left = 230
    Height = 23
    Top = 48
    Width = 61
    Caption = 'Target ip'
  end
  object Label2: TLabel
    Left = 246
    Height = 23
    Top = 80
    Width = 30
    Caption = 'Port'
  end
  object Label3: TLabel
    Left = 238
    Height = 23
    Top = 112
    Width = 48
    Caption = 'Pk.size'
  end
  object EdSize: TEdit
    Left = 302
    Height = 29
    Top = 112
    Width = 120
    Alignment = taCenter
    Font.Height = -13
    ParentFont = False
    TabOrder = 2
  end
  object Memo1: TMemo
    Left = 16
    Height = 169
    Top = 40
    Width = 200
    Font.Height = -13
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 3
    WordWrap = False
  end
  object BtSaveChanges: TButton
    Left = 296
    Height = 24
    Top = 184
    Width = 118
    Caption = 'save changes'
    TabOrder = 4
    OnClick = BtSaveChangesClick
  end
  object Button2: TButton
    Left = 360
    Height = 24
    Top = 152
    Width = 118
    Caption = 'load default'
    TabOrder = 5
    OnClick = Button2Click
  end
  object ComboBox1: TComboBox
    Left = 16
    Height = 33
    Top = 8
    Width = 476
    ItemHeight = 29
    TabOrder = 6
    OnChange = ComboBox1Change
  end
  object Button1: TButton
    Left = 232
    Height = 24
    Top = 152
    Width = 120
    Caption = 'remove device'
    TabOrder = 7
    OnClick = Button1Click
  end
end
