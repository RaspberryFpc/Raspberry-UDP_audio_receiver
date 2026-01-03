unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, process,
  StrUtils, LCLIntf, LCLType, LMessages, CheckLst, ComCtrls, ComboEx,
  CustomDrawnControls, ExtCtrls;


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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FillALSADevices;
    procedure Activate_Parameter;
    procedure SaveParameter;
    function audiodevicevalid(device:string):boolean;
    procedure parameterToGui(audioindex:integer);
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
  audioname,audiodevice:string;




procedure TForm2.Activate_Parameter;
begin
  CloseAlsa;
  //if pos(unavail, combobox1.Text) = 1 then exit;        /////////////////////////////////////////////////////////////
  // Werte direkt aus Controls holen
  par_port := Ed_port.Text;
  par_ip := Ed_ip.Text;
  par_byteorder := CBByteOrder.Checked;
  par_hide := CBHide.Checked;
  par_name := audioname;
  par_device:=audiodevice;
  par_freq := Ed_freq.Text;
  par_latency := Ed_lat.Text;
  OpenAlsa;
end;



procedure TForm2.SaveParameter;
var
  x,index: integer;
  s:string;
begin
  //  index suchen
   index:=0;
   for x:= 1 to  configlist.Count-1 do
       if pos(edit1.Text,configlist[x])>0 then
           begin
              index:=x;
              s:= par_name+';'+
                  par_device+';'+
                  par_ip+';'+
                  par_port+';'+
                  par_freq+';'+
                  par_latency+';';

                  if par_byteorder then
                         s:=s+'1;'
                         else
                          s:=s+'0;';
                  if par_hide then
                        s:=s+'1;'
                        else
                         s:=s+'0;';

                  configlist[0] := s;
                  configlist[index] := s;
                  break;
           end;
  configlist.SaveToFile(configfilename);
end;


procedure TForm2.CheckListBox1ClickCheck(Sender: TObject);
var
  x,i:integer;
  index:integer;
begin
    for i := 0 to CheckListBox1.Count - 1 do
    if i <> CheckListBox1.ItemIndex then
      CheckListBox1.Checked[i] := False; // alle anderen Häkchen entfernen
    edit1.Text:=CheckListBox1.Items[checklistbox1.ItemIndex];

     if Pos('unavailable', edit1.Text) > 0 then
          begin
             closealsa;
             exit;
          end;

  for x:= 1 to  configlist.Count-1 do
       if pos(edit1.Text,configlist[x])>0 then
           begin
              index:=x;
              configlist[0] :=  configlist[index];
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
   x,p: integer;
   s: string;
  begin
     s:= edit1.Text;
     p:=pos(' - unavailable',s);
     if p > 0 then
        delete(s,p,1000);
     for x:= 1 to  configlist.Count-1 do
         if pos(s,configlist[x])>0 then
             begin
               if MessageDlg('Delete Device', 'Do you really want to delete "' + s + '"?' +
                  LineEnding + 'If the device still exists, it will be recreated with default values on next start.',
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                  begin
                   closealsa;
                   configlist.Delete(x);
                   configlist[0]:='';
                   configlist.SaveToFile(configfilename);
                   if checklistbox1.ItemIndex >= 0 then checklistbox1.Items.Delete(checklistbox1.ItemIndex);
                   while checklistbox1.Items.Count<4 do checklistbox1.Items.Add('');
                    checklistbox1.ItemIndex:=-1;
                    edit1.text:='';
                   exit;
                  end;
        end;
  end;




procedure TForm2.Button1Click(Sender: TObject);
begin
  SaveParameter;
end;

procedure TForm2.parameterToGui(audioindex:integer);
var
  s:ansistring;
  x:integer;
  parts: TStringArray;
  valid: boolean;
begin
    s:=configlist[audioindex];
    parts := SplitString(s, ';');

  for x := 0 to High(parts) do
        begin
             s := parts[x];
             case x of
                   0:  audioname    := parts[x];
                   1:  audiodevice  := parts[x];
                   2:  Ed_ip.Text   := parts[x];
                   3:  Ed_port.Text := parts[x];
                   4:  Ed_freq.Text := parts[x];
                   5:  Ed_lat.Text  := parts[x];
                   6:  CBByteOrder.Checked := parts[x]='1';
                   7:  CBHide.Checked      := parts[x]='1';
                end;
        end;
end;



function tform2.audiodevicevalid(device:string):boolean;
var
  n:integer;
  pcm: PPsnd_pcm_t;
begin
   n := snd_pcm_open(@pcm, PChar(device), SND_PCM_STREAM_PLAYBACK, 0);
    if n <> 0 then
    begin
      result:=false;
    end
    else
    begin
      snd_pcm_drain(pcm);              // drain any remaining samples
      snd_pcm_close(pcm);
      pcm := nil;
      result:=true;
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
  Result := devname+';hw:' + cardnum + ',' + devnum+';';
end;



procedure TForm2.FillALSADevices;
var
  AList: TStringList;
  OutputStr,s: string;
  i, x,y, n, p,p2: integer;
  item, paramstr,audioname,hwname: string;
  parts:tstringarray;
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
             p:=pos(';',item);
             audioname:=copy(item,1,p);  // inclusive anfang und ende semicolon
             if pos (audioname,configlist.Text)=0  then      // fehlt in configliste
                  begin                      //defaultwerte eintragen
                  //ip=0.0.0.0  5010 'frequency=48000')'latency=28000');'swapbyte=0'); 'hide=0');
                  paramstr:= item+'0.0.0.0;5010;48000;28000;0;0;';
                  configlist.Add(paramstr);
                  end;
           end;
      end;
    end;
  finally
    AList.Free;
  end;


  // get first available für lastdevice  when empty



  s:=configlist[0];
  if s='' then
        begin
          for x:= 1 to configlist.Count-1 do
             begin
               s:= configlist[x];
               p:=pos(';',s,2);
               p2:=pos(';',s,p+1);
               hwname:=copy(s,p+1,p2-p-1);
               if audiodevicevalid(hwname) then
                    begin
                       configlist[0]:= configlist[1];
                       break;
                       end;
               end;
         end;


   s:=configlist[0];


  // mark not avail
  x:= configlist.Count;
  //alles nach combobox

  checklistbox1.Items.Clear;
  for x:=1 to  configlist.Count -1 do
                    begin
                      s:= configlist[x];
                      p:=pos(';',s,2);
                      p2:=pos(';',s,p+1);
                       hwname:=copy(s,p+1,p2-p-1);


                        if audiodevicevalid(hwname) then   checklistbox1.Items.Add(copy(s,1,p2-1)) else
                            checklistbox1.Items.Add(copy(s,1,p2-1)+' - unavailable');
                    end;

//     while checklistbox1.items.count < 4 do checklistbox1.items.add('');

      s:=configlist[0];
     parts := SplitString(s, ';');
     for x := 0 to High(parts) do
        begin
             s := parts[x];
             case x of
                   0:  audioname    := parts[x];
                   1:  audiodevice  := parts[x];
                end;
        end;

  edit1.text := audioname+';'+audiodevice;
  ParameterToGui(0);
  configlist.SaveToFile(configfilename);

   for x:= 0 to  checklistbox1.Count-1 do
       if pos(edit1.Text,checklistbox1.items[x])>0 then
           begin
             checklistbox1.checked[x]:=true;
             break;
           end;


  //  update combobox text
  Activate_Parameter;
end;




procedure TForm2.FormCreate(Sender: TObject);
begin
  ConfigFileName := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
              '.config/udp_player/udp_player.conf';

  if not fileexists(configfilename) then forcedirectories(extractfilepath(configfilename));

  configlist := TStringList.Create;
  if fileexists(configfilename) then
    configlist.LoadFromFile(configfilename);

  if configlist.Count<1 then configlist.Add('');

  FillALSADevices;
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
