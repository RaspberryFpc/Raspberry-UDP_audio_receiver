object Form2: TForm2
  Left = 455
  Height = 229
  Top = 43
  Width = 301
  Caption = 'UDP player settings'
  ClientHeight = 229
  ClientWidth = 301
  LCLVersion = '8.6'
  OnClose = FormClose
  OnShow = FormShow
  object Edit1: TEdit
    Left = 158
    Height = 30
    Top = 38
    Width = 136
    Alignment = taCenter
    TabOrder = 0
    Text = '5010'
  end
  object Edit2: TEdit
    Left = 158
    Height = 30
    Top = 68
    Width = 136
    Alignment = taCenter
    TabOrder = 1
    Text = '100000'
  end
  object Edit3: TEdit
    Left = 158
    Height = 30
    Top = 98
    Width = 136
    Alignment = taCenter
    TabOrder = 2
    Text = '48000'
  end
  object Edit4: TEdit
    Left = 158
    Height = 30
    Top = 128
    Width = 136
    Alignment = taCenter
    AutoSelect = False
    TabOrder = 3
    Text = '28000'
  end
  object CBByteOrder: TCheckBox
    Left = 38
    Height = 28
    Top = 166
    Width = 238
    Caption = 'Swap Byte Order (Endianness)'
    TabOrder = 4
  end
  object Label1: TLabel
    Left = 15
    Height = 22
    Top = 38
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Port'
  end
  object Label2: TLabel
    Left = 15
    Height = 22
    Top = 68
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Size networkbuffer'
  end
  object Label3: TLabel
    Left = 15
    Height = 22
    Top = 98
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Frequency Hz'
  end
  object Label4: TLabel
    Left = 15
    Height = 22
    Top = 132
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Alsa Latency µs'
  end
  object Edit5: TEdit
    Left = 158
    Height = 30
    Top = 8
    Width = 136
    Alignment = taCenter
    AutoSelect = False
    TabOrder = 5
    Text = '0.0.0.0'
  end
  object Label5: TLabel
    Left = 15
    Height = 22
    Top = 11
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'IP address'
  end
  object CBHide: TCheckBox
    Left = 38
    Height = 28
    Top = 188
    Width = 58
    Caption = 'Hide'
    TabOrder = 6
  end
end
