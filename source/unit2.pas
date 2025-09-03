unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, inifiles;

type

  { TForm2 }

  TForm2 = class(TForm)
    CBByteOrder: TCheckBox;
    CBHide: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

uses unit1;
  {$R *.frm}


  { TForm2 }

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  configfilename: string;
  ini: tinifile;
begin
  paripadresse:=edit5.Text;
  parport:=edit1.Text;
  parnetbuffer:=edit2.Text;
  parfrequenz:=edit3.Text;
  parAlsaLatency:=edit4.Text;
  parswap:=cbByteOrder.checked;
  parhide:=cbHide.Checked;

  configfilename := application.ExeName + '.conf';
  ini := Tinifile.Create(configfilename);
  ini.writeString('network', 'ip', paripadresse);
  ini.writeString('network', 'port', parport);
  ini.writestring('network', 'buffersize', parnetbuffer);
  ini.writestring('audio', 'frequency', parfrequenz);
  ini.writebool('audio', 'swap byte', parswap);
  ini.writestring('alsa', 'latency', parAlsaLatency);
  ini.writebool('visible', 'hide', parhide);
  ini.Free;
  closealsa;
  openalsa;

end;

procedure TForm2.FormShow(Sender: TObject);
begin
  edit5.Text:= paripadresse;
  edit1.Text:= parport;
  edit2.Text:= parnetbuffer;
  edit3.Text:= parfrequenz;
  edit4.Text:= parAlsaLatency;
  cbByteOrder.checked:= parswap;
  cbHide.Checked:= parhide;

end;



end.
