unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, process;

type
  { TForm2 }
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CBByteOrder: TCheckBox;
    CBHide: TCheckBox;
    ComboBox1: TComboBox;
    Ed_port: TEdit;
    Ed_netbuffer: TEdit;
    Ed_freq: TEdit;
    Ed_lat: TEdit;
    Ed_ip: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FillALSADevices;
    procedure Activate_Parameter;
    function LoadParameter(au_name: string): boolean;
    function LoadParameterLastUsed: boolean;
    function LoadParameterFirstSet: boolean;
    procedure SaveParameter(au_name: string);
    procedure DeleteSelectedConfig;
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
  configfilename: string;

function keyresult(key, item: string): string;
var
  p: integer;
begin
  p := pos(key + '=', item);
  if p = 1 then
    Result := copy(item, length(key) + 2, 1000)
  else
    Result := '';
end;

procedure TForm2.Activate_Parameter;
begin
  CloseAlsa;
  if pos(unavail, combobox1.Text) = 1 then exit;
  // Werte direkt aus Controls holen
  par_port := Ed_port.Text;
  par_netbuffer := ED_netbuffer.Text;
  par_ip := Ed_ip.Text;
  par_byteorder := CBByteOrder.Checked;
  par_hide := CBHide.Checked;
  par_name := ComboBox1.Text;
  par_freq := Ed_freq.Text;
  par_latency := Ed_lat.Text;
  OpenAlsa;
end;

procedure TForm2.SaveParameter(au_name: string);
var
  x: integer;
begin
  for x := 0 to configlist.Count - 1 do
    if configlist[x].StartsWith('name=' + au_name) then
    begin
      configlist[0] := 'lastdevice=' + combobox1.Text;

      while configlist.Count < x + 9 do configlist.Add('');

      configlist[x + 2] := 'ip=' + Ed_ip.Text;
      configlist[x + 3] := 'port=' + Ed_port.Text;
      configlist[x + 4] := 'netbuffersize=' + Ed_netbuffer.Text;
      configlist[x + 5] := 'frequency=' + Ed_freq.Text;
      configlist[x + 6] := 'latency=' + Ed_lat.Text;

      if CBByteOrder.Checked then
        configlist[x + 7] := 'swapbyte=1'
      else
        configlist[x + 7] := 'swapbyte=0';

      if CBHide.Checked then
        configlist[x + 8] := 'hide=1'
      else
        configlist[x + 8] := 'hide=0';
      break;
    end;
end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TForm2.ComboBox1Change(Sender: TObject);
var
  sl:tstringlist;
begin
  if pos(unavail, combobox1.Text) = 1 then
                              combobox1.Text := par_name
  else
  begin
    closealsa;
    LoadParameter(ComboBox1.Text);
    Activate_Parameter;
    sl:=tstringlist.Create;
    sl.LoadFromFile(configfilename);
    if  sl.Count>0 then
      begin
        sl[0]:= 'lastdevice=' + combobox1.Text;
        sl.SaveToFile(configfilename);
      end;
end;
end;


procedure TForm2.Button2Click(Sender: TObject);
begin
  Activate_Parameter;
end;


procedure TForm2.DeleteSelectedConfig;
var
  idx, i, j: integer;
  au_name: string;
begin
  au_name := ComboBox1.Text;
  if au_name = '' then
  begin
    ShowMessage('No device selected.');
    Exit;
  end;

  if MessageDlg('Delete Device', 'Do you really want to delete "' + au_name + '"?' + LineEnding + 'If the device still exists, it will be recreated with default values on next start.', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    for i := 0 to configlist.Count - 1 do
    begin
      if configlist[i] = 'name=' + au_name then
      begin
        // suche nächste "name=" oder Dateiende
        j := i + 1;
        while (j < configlist.Count) and (not configlist[j].StartsWith('name=')) do
          Inc(j);

        // alle Zeilen von i bis j-1 löschen
        while j > i do
        begin
          configlist.Delete(i);
          Dec(j);
        end;

        Break;
      end;
    end;

    // aus der Combobox entfernen
    idx := ComboBox1.Items.IndexOf(au_name);
    if idx >= 0 then
      ComboBox1.Items.Delete(idx);

    // Datei sofort sichern
    configlist.SaveToFile(configfilename);
  end;
end;



procedure TForm2.Button3Click(Sender: TObject);
begin
  DeleteSelectedConfig;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  SaveParameter(ComboBox1.Text);
end;

function TForm2.LoadParameter(au_name: string): boolean;
var
  i, x: integer;
  s: string;
begin
  Result := False;
  for i := 0 to configlist.Count - 1 do
  begin
    if configlist[i] = 'name=' + au_name then
    begin
      for x := i + 1 to i + 7 do
      begin
        s := configlist[x];
        if keyresult('ip', s) > '' then Ed_ip.Text := keyresult('ip', s);
        if keyresult('port', s) > '' then Ed_port.Text := keyresult('port', s);
        if keyresult('netbuffersize', s) > '' then Ed_netbuffer.Text := keyresult('netbuffersize', s);
        if keyresult('frequency', s) > '' then Ed_freq.Text := keyresult('frequency', s);
        if keyresult('latency', s) > '' then Ed_lat.Text := keyresult('latency', s);
        if keyresult('swapbyte', s) > '' then CBByteOrder.Checked := keyresult('swapbyte', s) = '1';
        if keyresult('hide', s) > '' then CBHide.Checked := keyresult('hide', s) = '1';
      end;

      ComboBox1.Text := au_name;
      configlist[0] := 'lastdevice=' + au_name;
      Result := True;
      break;
    end;
  end;
end;

function TForm2.LoadParameterLastUsed: boolean;
var
  devicelastused: string;
  x: integer;
begin
  Result := False;
  for x := 0 to configlist.Count - 1 do
  begin
    devicelastused := keyresult('lastdevice', configlist[x]);
    if (devicelastused > '') and (pos(unavail, devicelastused) <> 1) then
    begin
      Result := LoadParameter(devicelastused);
      break;
    end;
  end;
end;



function TForm2.LoadParameterFirstSet: boolean;
var
  devicefirstset: string;
  x: integer;
begin
  Result := False;
  for x := 0 to configlist.Count - 1 do
  begin
    devicefirstset := keyresult('name', configlist[x]);
    if (devicefirstset > '') and ((pos(unavail, devicefirstset) <> 1)) then
    begin
      Result := LoadParameter(devicefirstset);
      break;
    end;
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
  Result := 'hw:' + cardnum + ',' + devnum + '  ' + devname;
end;

procedure TForm2.FillALSADevices;
var
  AList: TStringList;
  OutputStr: string;
  i, x, n, p: integer;
  item, device: string;
  pcm: PPsnd_pcm_t;
begin
  ComboBox1.Items.Clear;
  AList := TStringList.Create;
  try
    if RunCommand('aplay', ['-l'], OutputStr) then
    begin
      AList.Text := OutputStr;
      for i := 1 to AList.Count - 1 do
      begin
        item := read_entry(AList[i]);
        if item > '' then
        begin
          ComboBox1.Items.Add(trim(item));
          if pos('name=' + item, configlist.Text) = 0 then
          begin
            configlist.Add('');
            configlist.Add('name=' + item);
            configlist.Add('ip=0.0.0.0');
            configlist.Add('port=5010');
            configlist.Add('netbuffersize=10000');
            configlist.Add('frequency=48000');
            configlist.Add('latency=28000');
            configlist.Add('swapbyte=0');
            configlist.Add('hide=0');
          end;
        end;
      end;
    end;
  finally
    AList.Free;
  end;


  // check devices
  for x := combobox1.Items.Count - 1 downto 0 do
  begin
    p := pos(' ', combobox1.items[x]);
    if p = 0 then  device := combobox1.items[x]
    else
      device := trim(copy(combobox1.items[x], 1, p - 1));

    n := snd_pcm_open(@pcm, PChar(device), SND_PCM_STREAM_PLAYBACK, 0);
    if n <> 0 then
    begin
      combobox1.Items[x] := unavail + combobox1.Items[x];
    end
    else
    begin
      snd_pcm_drain(pcm);              // drain any remaining samples
      snd_pcm_close(pcm);
      pcm := nil;
    end;
  end;
end;


procedure TForm2.FormCreate(Sender: TObject);
begin
  configfilename := GetAppConfigFile(False);                 //oid application.ExeName + '.conf';
  configlist := TStringList.Create;
  if fileexists(configfilename) then
    configlist.LoadFromFile(configfilename)
  else
  begin
    configlist.Add('lastdevice=');         // kein lastdevice
    configlist.SaveToFile(configfilename);
  end;
  FillALSADevices;
  if not LoadParameterLastUsed then
    LoadParameterFirstSet;
  Activate_Parameter;

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
