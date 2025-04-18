object Form1: TForm1
  Left = 242
  Height = 212
  Top = 158
  Width = 305
  Caption = 'Form1'
  ClientHeight = 212
  ClientWidth = 305
  LCLVersion = '8.6'
  OnClose = FormClose
  OnCreate = FormCreate
  object Label1: TLabel
    Left = 8
    Height = 22
    Top = 176
    Width = 47
    Caption = 'Label1'
  end
  object Memo1: TMemo
    Left = 8
    Height = 160
    Top = 8
    Width = 287
    Lines.Strings = (
      'Memo1'
    )
    TabOrder = 0
  end
  object Button1: TButton
    Left = 220
    Height = 25
    Top = 176
    Width = 75
    Caption = 'Beenden'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 248
    Top = 8
  end
end
