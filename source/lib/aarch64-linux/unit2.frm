object Form2: TForm2
  Left = 455
  Height = 321
  Top = 43
  Width = 401
  Caption = 'UDP player settings'
  ClientHeight = 321
  ClientWidth = 401
  LCLVersion = '8.7'
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  object Ed_port: TEdit
    Left = 183
    Height = 33
    Top = 102
    Width = 136
    Alignment = taCenter
    TabOrder = 0
    Text = '0'
  end
  object Ed_netbuffer: TEdit
    Left = 183
    Height = 33
    Top = 132
    Width = 136
    Alignment = taCenter
    TabOrder = 1
    Text = '10000'
  end
  object Ed_freq: TEdit
    Left = 183
    Height = 33
    Top = 162
    Width = 136
    Alignment = taCenter
    TabOrder = 2
    Text = '48000'
  end
  object Ed_lat: TEdit
    Left = 183
    Height = 33
    Top = 192
    Width = 136
    Alignment = taCenter
    AutoSelect = False
    TabOrder = 3
    Text = '28000'
  end
  object CBByteOrder: TCheckBox
    Left = 8
    Height = 28
    Top = 232
    Width = 248
    Caption = 'Swap Byte Order (Endianness)'
    TabOrder = 4
  end
  object Label1: TLabel
    Left = 40
    Height = 22
    Top = 102
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Port'
  end
  object Label2: TLabel
    Left = 40
    Height = 22
    Top = 132
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Size networkbuffer'
  end
  object Label3: TLabel
    Left = 40
    Height = 22
    Top = 162
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Frequency Hz'
  end
  object Label4: TLabel
    Left = 40
    Height = 22
    Top = 196
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'Alsa Latency µs'
  end
  object Ed_ip: TEdit
    Left = 183
    Height = 33
    Top = 72
    Width = 136
    Alignment = taCenter
    AutoSelect = False
    TabOrder = 5
    Text = '0.0.0.0'
  end
  object Label5: TLabel
    Left = 40
    Height = 22
    Top = 75
    Width = 141
    Alignment = taCenter
    AutoSize = False
    Caption = 'IP address'
  end
  object CBHide: TCheckBox
    Left = 8
    Height = 28
    Top = 256
    Width = 142
    Caption = 'Start minimized'
    TabOrder = 6
  end
  object Label6: TLabel
    Left = 128
    Height = 22
    Top = 0
    Width = 119
    Alignment = taCenter
    AutoSize = False
    Caption = 'Output device'
  end
  object ComboBox1: TComboBox
    Left = 8
    Height = 33
    Top = 24
    Width = 384
    ItemHeight = 29
    Style = csSimple
    TabOrder = 7
    Text = 'hw:'
    OnChange = ComboBox1Change
  end
  object Button1: TButton
    Left = 272
    Height = 25
    Top = 288
    Width = 112
    Caption = 'Save changes'
    TabOrder = 8
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 144
    Height = 25
    Top = 288
    Width = 112
    Caption = 'Test changes'
    TabOrder = 9
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 16
    Height = 25
    Top = 288
    Width = 112
    Caption = 'Delete'
    TabOrder = 10
    OnClick = Button3Click
  end
end
