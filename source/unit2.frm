object Form2: TForm2
  Left = 455
  Height = 243
  Top = 43
  Width = 320
  Caption = 'UDP player settings'
  ClientHeight = 243
  ClientWidth = 320
  DesignTimePPI = 102
  LCLVersion = '8.7'
  OnClose = FormClose
  OnShow = FormShow
  object Edit1: TEdit
    Left = 168
    Height = 31
    Top = 40
    Width = 144
    Alignment = taCenter
    TabOrder = 0
    Text = '5010'
  end
  object Edit2: TEdit
    Left = 168
    Height = 31
    Top = 72
    Width = 144
    Alignment = taCenter
    TabOrder = 1
    Text = '100000'
  end
  object Edit3: TEdit
    Left = 168
    Height = 31
    Top = 104
    Width = 144
    Alignment = taCenter
    TabOrder = 2
    Text = '48000'
  end
  object Edit4: TEdit
    Left = 168
    Height = 31
    Top = 136
    Width = 144
    Alignment = taCenter
    AutoSelect = False
    TabOrder = 3
    Text = '28000'
  end
  object CBByteOrder: TCheckBox
    Left = 40
    Height = 29
    Top = 176
    Width = 251
    Caption = 'Swap Byte Order (Endianness)'
    TabOrder = 4
  end
  object Label1: TLabel
    Left = 16
    Height = 23
    Top = 40
    Width = 150
    Alignment = taCenter
    AutoSize = False
    Caption = 'Port'
  end
  object Label2: TLabel
    Left = 16
    Height = 23
    Top = 72
    Width = 150
    Alignment = taCenter
    AutoSize = False
    Caption = 'Size networkbuffer'
  end
  object Label3: TLabel
    Left = 16
    Height = 23
    Top = 104
    Width = 150
    Alignment = taCenter
    AutoSize = False
    Caption = 'Frequency Hz'
  end
  object Label4: TLabel
    Left = 16
    Height = 23
    Top = 140
    Width = 150
    Alignment = taCenter
    AutoSize = False
    Caption = 'Alsa Latency µs'
  end
  object Edit5: TEdit
    Left = 168
    Height = 31
    Top = 8
    Width = 144
    Alignment = taCenter
    AutoSelect = False
    TabOrder = 5
    Text = '0.0.0.0'
  end
  object Label5: TLabel
    Left = 16
    Height = 23
    Top = 12
    Width = 150
    Alignment = taCenter
    AutoSize = False
    Caption = 'IP address'
  end
  object CBHide: TCheckBox
    Left = 40
    Height = 29
    Top = 200
    Width = 144
    Caption = 'Start minimized'
    TabOrder = 6
  end
end
