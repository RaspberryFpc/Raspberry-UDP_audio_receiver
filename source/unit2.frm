object Form2: TForm2
  Left = 455
  Height = 306
  Top = 43
  Width = 422
  Caption = 'UDP player settings'
  ClientHeight = 306
  ClientWidth = 422
  DesignTimePPI = 102
  LCLVersion = '8.7'
  OnClose = FormClose
  OnShow = FormShow
  object Edit1: TEdit
    Left = 168
    Height = 33
    Top = 40
    Width = 144
    Alignment = taCenter
    TabOrder = 0
    Text = '5010'
  end
  object Edit2: TEdit
    Left = 168
    Height = 33
    Top = 72
    Width = 144
    Alignment = taCenter
    TabOrder = 1
    Text = '100000'
  end
  object Edit3: TEdit
    Left = 168
    Height = 33
    Top = 104
    Width = 144
    Alignment = taCenter
    TabOrder = 2
    Text = '48000'
  end
  object Edit4: TEdit
    Left = 168
    Height = 33
    Top = 136
    Width = 144
    Alignment = taCenter
    AutoSelect = False
    TabOrder = 3
    Text = '28000'
  end
  object CBByteOrder: TCheckBox
    Left = 64
    Height = 28
    Top = 248
    Width = 257
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
    Height = 33
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
    Left = 64
    Height = 28
    Top = 272
    Width = 150
    Caption = 'Start minimized'
    TabOrder = 6
  end
  object Label6: TLabel
    Left = 144
    Height = 23
    Top = 184
    Width = 126
    Alignment = taCenter
    AutoSize = False
    Caption = 'Output device'
  end
  object ComboBox1: TComboBox
    Left = 8
    Height = 33
    Top = 208
    Width = 408
    ItemHeight = 29
    TabOrder = 7
    Text = 'hw:0,0'
  end
end
