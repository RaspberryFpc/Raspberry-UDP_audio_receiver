unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, inifiles,process;

type

  { TForm2 }

  TForm2 = class(TForm)
    CBByteOrder: TCheckBox;
    CBHide: TCheckBox;
    ComboBox1: TComboBox;
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
    Label6: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FillALSADevices;
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
  parOutputDevice:=combobox1.Text;
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
  ini.writestring('alsa', 'outputdevice', parOutputDevice);
  ini.writebool('visible', 'hide', parhide);
  ini.Free;
  closealsa;
  openalsa;
end;




function read_entry(const s: string): string;
var
  tmp, cardnum, devnum, devname: string;
  p1, p2: Integer;
begin
  Result := '';
  tmp := Trim(s);
  if tmp = '' then Exit;

  // 1. Karte-Nummer: Zahl vor erstem ':'
  p1 := Pos(':', tmp);
  if p1 = 0 then Exit;
  // letzte Ziffer vor ':' suchen
  p2 := p1-1;
  while (p2 > 0) and (tmp[p2] in ['0'..'9']) do Dec(p2);
  cardnum := Copy(tmp, p2+1, p1-p2-1);

  // Rest nach ':' weiterverarbeiten
  Delete(tmp, 1, p1);
  tmp := Trim(tmp);

  // 2. Gerätename: bis erstes ','
  p1 := Pos(',', tmp);
  if p1 = 0 then Exit;
  devname := Trim(Copy(tmp, 1, p1-1));
  Delete(tmp, 1, p1);
  tmp := Trim(tmp);

  // 3. Devicenumber: erste Zahl nach Komma
  p1 := 1;
  while (p1 <= Length(tmp)) and not (tmp[p1] in ['0'..'9']) do Inc(p1);
  if p1 > Length(tmp) then Exit;
  p2 := p1;
  while (p2 <= Length(tmp)) and (tmp[p2] in ['0'..'9']) do Inc(p2);
  devnum := Copy(tmp, p1, p2-p1);

  // Ergebnis zusammenstellen
  Result := 'hw:' + cardnum + ',' + devnum + '  ' + devname;
end;





procedure TForm2.FillALSADevices;
var AList: TStringList;
  OutputStr: string;
  i: Integer;
  Line: string;
  DisplayName, HWAddr,item: string;
  p:integer;

  begin ComboBox1.Items.Clear;
    AList := TStringList.Create;
    try
      if RunCommand('aplay', ['-l'], OutputStr) then
      begin AList.Text := OutputStr;
        for i := 1 to AList.Count - 1 do
        begin
          item:= read_entry(AList[i]);
          if item >'' then combobox1.Items.Add(item);
        end;
      end;
    finally
      AList.Free;
    end;
  end;





procedure TForm2.FormShow(Sender: TObject);
begin
  FillALSADevices;
  edit1.Text:= parport;
  edit2.Text:= parnetbuffer;
  edit3.Text:= parfrequenz;
  edit4.Text:= parAlsaLatency;
  edit5.Text:= paripadresse;
  combobox1.Text:= parOutputDevice;
  cbByteOrder.checked:= parswap;
  cbHide.Checked:= parhide;
end;





end.
