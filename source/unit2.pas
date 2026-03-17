unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, process,
  StrUtils, LCLIntf, LCLType, CheckLst, ComCtrls,ExtCtrls, Spin,alsa_volume;

type
  { TForm2 }
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CBByteOrder: TCheckBox;
    CBHide: TCheckBox;
    CheckListBox1: TCheckListBox;
    Edit1: TEdit;
    Ed_port: TEdit;
    Ed_freq: TEdit;
    Ed_lat: TEdit;
    Ed_ip: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    SpinEdit_Volume: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FillALSADevices;
    procedure Activate_Parameter;
    procedure SaveParameter;
    function audiodevicevalid(device: string): boolean;
    procedure parameterToGui(audioindex: integer);
    procedure readdevices;
    procedure SpinEdit_VolumeChange(Sender: TObject);

  private
  public
  end;

var

  Form2: TForm2;

implementation

uses unit1;
  {$R *.frm}

const
  unavail = 'unavailable; ';


var
  configlist: TStringList;
  audioname, audiodevice: string;




procedure TForm2.Activate_Parameter;
var
  card:string;
begin
  CloseAlsa;
  //if pos(unavail, combobox1.Text) = 1 then exit;        /////////////////////////////////////////////////////////////
  // Werte direkt aus Controls holen
  par_port := Ed_port.Text;
  par_ip := Ed_ip.Text;
  par_byteorder := CBByteOrder.Checked;
  par_hide := CBHide.Checked;
  par_name := audioname;
  par_device := audiodevice;
  par_freq := Ed_freq.Text;
  par_latency := Ed_lat.Text;
  par_volume := inttostr(spinedit_volume.Value);
  if OpenAlsa then
          begin
          card:=copy(par_device,1,pos(',',par_device)-1);
          delete(card,1,3);
          SetVolume(strtoint(card), spinedit_volume.Value); // entspricht hw:2,0

          end;
end;



procedure TForm2.SaveParameter;
var
  x, index: integer;
  s: string;
begin
  //  index suchen
  index := 0;
  for x := 1 to configlist.Count - 1 do
    if pos(edit1.Text, configlist[x]) > 0 then
    begin
      index := x;
      s := par_name + ';' + par_device + ';' + par_ip + ';' + par_port + ';' + par_freq + ';' + par_latency + ';';

      if par_byteorder then
        s := s + '1;'
      else
        s := s + '0;';
      if par_hide then
        s := s + '1;'
      else
        s := s + '0;';

      s:=s+par_volume+';';

      configlist[0] := s;
      configlist[index] := s;
      break;
    end;
  configlist.SaveToFile(configfilename);
end;


procedure TForm2.CheckListBox1ClickCheck(Sender: TObject);
var
  x, i: integer;
  index: integer;
begin
  for i := 0 to CheckListBox1.Count - 1 do
    if i <> CheckListBox1.ItemIndex then
      CheckListBox1.Checked[i] := False; // alle anderen Häkchen entfernen
  edit1.Text := CheckListBox1.Items[checklistbox1.ItemIndex];

  if Pos('unavailable', edit1.Text) > 0 then
  begin
    closealsa;
    exit;
  end;

  for x := 1 to configlist.Count - 1 do
    if pos(edit1.Text, configlist[x]) > 0 then
    begin
      index := x;
      configlist[0] := configlist[index];
      configlist.SaveToFile(configfilename);
      ParameterToGui(0);
      Activate_Parameter;
    end;
end;



procedure TForm2.Button2Click(Sender: TObject);
begin
  Activate_Parameter;
end;



procedure TForm2.Button3Click(Sender: TObject);
var
  sel: integer;
  s: string;
begin

  sel := checklistbox1.ItemIndex;
  if sel >= 0 then
  begin
    s := checklistbox1.Items[sel];
    if MessageDlg('Delete Device', 'Do you really want to delete "' + s + '"?' + LineEnding + 'If the device still exists, it will be recreated with default values on next start.',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      closealsa;
      configlist.Delete(sel + 1);
      configlist[0] := '';
      configlist.SaveToFile(configfilename);
      checklistbox1.DeleteSelected;
    end;
  end;

end;



procedure TForm2.Button1Click(Sender: TObject);
begin
  SaveParameter;
end;

procedure TForm2.parameterToGui(audioindex: integer);
var
  s: ansistring;
  x: integer;
  parts: TStringArray;
begin
  s := configlist[audioindex];
  parts := SplitString(s, ';');

  for x := 0 to High(parts) do
  begin
    s := parts[x];
    if s > '' then
    case x of
      0: audioname := parts[x];
      1: audiodevice := parts[x];
      2: Ed_ip.Text := parts[x];
      3: Ed_port.Text := parts[x];
      4: Ed_freq.Text := parts[x];
      5: Ed_lat.Text := parts[x];
      6: CBByteOrder.Checked := parts[x] = '1';
      7: CBHide.Checked := parts[x] = '1';
      8: spinedit_volume.Value:= strtoint(parts[x]);
    end;
  end;
end;



function tform2.audiodevicevalid(device: string): boolean;
var
  n: integer;
  pcm: PPsnd_pcm_t;
begin
  n := snd_pcm_open(@pcm, PChar(device), SND_PCM_STREAM_PLAYBACK, 0);
  if n <> 0 then
  begin
    Result := False;
  end
  else
  begin
    snd_pcm_drain(pcm);              // drain any remaining samples
    snd_pcm_close(pcm);
    pcm := nil;
    Result := True;
  end;
end;



function read_entry(const s: string): string;
var
  tmp, cardnum, devnum, devname: string;
  p1, p2: integer;
begin
  Result := '';
  tmp := Trim(s);
  if tmp = '' then Exit;

  // 1. Karte-Nummer: Zahl vor erstem ':'
  p1 := Pos(':', tmp);
  if p1 = 0 then Exit;
  // letzte Ziffer vor ':' suchen
  p2 := p1 - 1;
  while (p2 > 0) and (tmp[p2] in ['0'..'9']) do Dec(p2);
  cardnum := Copy(tmp, p2 + 1, p1 - p2 - 1);

  // Rest nach ':' weiterverarbeiten
  Delete(tmp, 1, p1);
  tmp := Trim(tmp);

  // 2. Gerätename: bis erstes ','
  p1 := Pos(',', tmp);
  if p1 = 0 then Exit;
  devname := Trim(Copy(tmp, 1, p1 - 1));
  Delete(tmp, 1, p1);
  tmp := Trim(tmp);

  // 3. Devicenumber: erste Zahl nach Komma
  p1 := 1;
  while (p1 <= Length(tmp)) and not (tmp[p1] in ['0'..'9']) do Inc(p1);
  if p1 > Length(tmp) then Exit;
  p2 := p1;
  while (p2 <= Length(tmp)) and (tmp[p2] in ['0'..'9']) do Inc(p2);
  devnum := Copy(tmp, p1, p2 - p1);

  // Ergebnis zusammenstellen
  Result := devname + ';hw:' + cardnum + ',' + devnum + ';';
end;



procedure TForm2.FillALSADevices;
var
  AList: TStringList;
  OutputStr, s: string;
  i, x, p, p2: integer;
  item, parameter, audioname, hwname: string;
  parts: tstringarray;
const
  defaultparameter = '0.0.0.0;5010;48000;28000;0;0;100;';
begin
  AList := TStringList.Create;

  try
    if RunCommand('aplay', ['-l'], OutputStr) then
    begin
      AList.Text := OutputStr;
      for i := 1 to AList.Count - 1 do
      begin
        item := read_entry(AList[i]);  //alle devices holen
        if item > '' then
        begin
          p := pos(';', item);
          audioname := copy(item, 1, p);  // inclusive ende semicolon
          Delete(item, 1, p);
          p := pos(';', item);
          hwname := copy(item, 1, p); // inclusive ende semicolon

          // parameter aus configliste
          parameter := '';
          for x := 1 to configlist.Count - 1 do
          begin
            if pos(audioname, configlist[x]) = 1 then
            begin
              parameter := configlist[x];
              p := pos(';', parameter);
              Delete(parameter, 1, p);
              p := pos(';', parameter);
              Delete(parameter, 1, p);
              configlist[x] := audioname + hwname + parameter;
              break;
            end;
          end;
          if parameter = '' then configlist.Add(audioname + hwname + defaultparameter);

        end;
      end;
    end;
  finally
    AList.Free;
  end;



  // lastdevice updaten

  item := edit1.Text;
  p := pos(';', item);
  audioname := copy(item, 1, p);  // inclusive ende semicolon
  Delete(item, 1, p);
  p := pos(';', item);
  hwname := copy(item, 1, p); // inclusive ende semicolon

  // parameter aus configliste
  parameter := '';
  for x := 0 to configlist.Count - 1 do
  begin
    if pos(audioname, configlist[x]) = 1 then
    begin
      parameter := configlist[x];
      p := pos(';', parameter);
      Delete(parameter, 1, p);
      p := pos(';', parameter);
      Delete(parameter, 1, p);
      edit1.Text := audioname + hwname + parameter;
      break;
    end;
  end;

  if parameter = '' then edit1.Text := '';




  //  in  checklistbox eintragen   haken setzen
  checklistbox1.Items.Clear;
  for x := 1 to configlist.Count - 1 do
  begin
    s := configlist[x];
    p := pos(';', s, 2);
    audioname := copy(s, 1, p);
    p2 := pos(';', s, p + 1);
    hwname := copy(s, p + 1, p2 - p - 1);
    if audiodevicevalid(hwname) then
      checklistbox1.Items.Add(audioname + hwname)
    else
      checklistbox1.Items.Add(audioname + hwname + ' - unavailable');

    if pos(audioname + hwname, edit1.Text) > 0 then checklistbox1.Checked[x] := True;
  end;



  s := configlist[0];
  parts := SplitString(s, ';');
  for x := 0 to High(parts) do
  begin
    s := parts[x];
    case x of
      0: audioname := parts[x];
      1: audiodevice := parts[x];
    end;
  end;

  edit1.Text := audioname + ';' + audiodevice;

  ParameterToGui(0);
  configlist.SaveToFile(configfilename);

  //  update edit1

  p := pos(';', edit1.Text);
  audioname := copy(edit1.Text, 1, p);

  edit1.Text := '';

  for x := 0 to checklistbox1.Count - 1 do
    if pos(audioname, checklistbox1.items[x]) = 1 then
    begin
      edit1.Text := checklistbox1.items[x];
      checklistbox1.Checked[x] := True;
      break;
    end;

  // wenn nicht vorhanden dann erste verfügbare
  if edit1.Text = '' then
  begin
    for x := 0 to checklistbox1.Count - 1 do
      if pos('unavailable', checklistbox1.items[x]) = 0 then
      begin
        edit1.Text := checklistbox1.items[x];
        checklistbox1.Checked[x] := True;
        break;
      end;
  end;
  // immer noch nicht dann erster eintrag
  if edit1.Text = '' then
  begin
    edit1.Text := checklistbox1.items[0];
    checklistbox1.Checked[0] := True;
  end;
  //  update combobox text
  Activate_Parameter;
end;

 procedure Tform2.readdevices;
 begin
    ConfigFileName := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) + '.config/udp_player/udp_player.conf';

  if not fileexists(configfilename) then forcedirectories(extractfilepath(configfilename));
  if assigned(configlist) then configlist.Free;
  configlist := TStringList.Create;
  if fileexists(configfilename) then
    configlist.LoadFromFile(configfilename);

  if configlist.Count < 1 then configlist.Add('');

  FillALSADevices;
 end;

procedure TForm2.SpinEdit_VolumeChange(Sender: TObject);
var
  card:string;
begin
 if assigned(pcm) then
 begin
   card:=copy(par_device,1,pos(',',par_device)-1);
   delete(card,1,3);
   SetVolume(strtoint(card), spinedit_volume.Value); // entspricht hw:2,0
 end;
end;




procedure TForm2.FormCreate(Sender: TObject);
begin
  readdevices;

  receiverthread := Treceiverthread.Create(False);

  if CBHide.Checked then
    form1.WindowState := wsMinimized
  else
    form1.WindowState := wsNormal;
end;



procedure TForm2.FormDestroy(Sender: TObject);
begin
  configlist.Free;
end;


end.
