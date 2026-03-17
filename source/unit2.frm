object Form2: TForm2
  Left = 455
  Height = 343
  Top = 43
  Width = 442
  Caption = 'UDP player settings'
  ClientHeight = 343
  ClientWidth = 442
  Position = poDesktopCenter
  LCLVersion = '8.8'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  object Ed_port: TEdit
    Left = 9
    Height = 25
    Top = 252
    Width = 104
    Alignment = taCenter
    AutoSize = False
    AutoSelect = False
    Font.Height = 16
    ParentFont = False
    TabOrder = 0
    Text = '0'
  end
  object Ed_freq: TEdit
    Left = 153
    Height = 25
    Top = 197
    Width = 136
    Alignment = taCenter
    AutoSize = False
    AutoSelect = False
    Font.Height = 16
    ParentFont = False
    TabOrder = 1
    Text = '48000'
  end
  object Ed_lat: TEdit
    Left = 296
    Height = 25
    Top = 197
    Width = 136
    Alignment = taCenter
    AutoSize = False
    AutoSelect = False
    Font.Height = 16
    ParentFont = False
    TabOrder = 2
    Text = '28000'
  end
  object CBByteOrder: TCheckBox
    Left = 216
    Height = 21
    Top = 240
    Width = 209
    Caption = 'Swap Byte Order (Endianness)'
    TabOrder = 3
  end
  object Label1: TLabel
    Left = 24
    Height = 22
    Top = 232
    Width = 85
    Alignment = taCenter
    AutoSize = False
    Caption = 'Port'
  end
  object Label3: TLabel
    Left = 161
    Height = 22
    Top = 173
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Frequency Hz'
  end
  object Label4: TLabel
    Left = 292
    Height = 22
    Top = 173
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Alsa Latency µs'
  end
  object Ed_ip: TEdit
    Left = 9
    Height = 25
    Top = 197
    Width = 135
    Alignment = taCenter
    AutoSize = False
    AutoSelect = False
    BidiMode = bdRightToLeftNoAlign
    Font.Height = 16
    ParentBidiMode = False
    ParentFont = False
    TabOrder = 4
    Text = '0.0.0.0'
  end
  object Label5: TLabel
    Left = 33
    Height = 22
    Top = 173
    Width = 85
    Alignment = taCenter
    AutoSize = False
    Caption = 'IP address'
  end
  object CBHide: TCheckBox
    Left = 216
    Height = 21
    Top = 255
    Width = 121
    Caption = 'Start minimized'
    TabOrder = 5
  end
  object Button1: TButton
    Left = 280
    Height = 25
    Top = 292
    Width = 153
    Caption = 'Save tested changes'
    TabOrder = 6
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 136
    Height = 25
    Top = 292
    Width = 128
    Caption = 'Test changes'
    TabOrder = 7
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Height = 25
    Top = 292
    Width = 112
    Caption = 'Delete'
    TabOrder = 8
    OnClick = Button3Click
  end
  object CheckListBox1: TCheckListBox
    Left = 9
    Height = 136
    Top = 32
    Width = 424
    ExtendedSelect = False
    ItemHeight = 0
    TabOrder = 9
    TopIndex = -1
    OnClickCheck = CheckListBox1ClickCheck
  end
  object Edit1: TEdit
    Left = 9
    Height = 25
    Top = 8
    Width = 424
    AutoSize = False
    AutoSelect = False
    Font.Height = 16
    ParentFont = False
    ReadOnly = True
    TabOrder = 10
  end
  object Label2: TLabel
    Left = 120
    Height = 22
    Top = 232
    Width = 85
    Alignment = taCenter
    AutoSize = False
    Caption = 'Volume %'
  end
  object SpinEdit_Volume: TSpinEdit
    Left = 128
    Height = 28
    Top = 250
    Width = 66
    Alignment = taRightJustify
    Font.Height = 16
    MaxValue = 100
    ParentFont = False
    TabOrder = 11
    Value = 100
    OnChange = SpinEdit_VolumeChange
  end
end
