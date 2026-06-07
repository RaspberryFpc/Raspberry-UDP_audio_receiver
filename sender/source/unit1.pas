unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,process,unit2,
  exethread ,BaseUnix;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtStart: TButton;
    BtStop: TButton;
    ListBox1: TListBox;
    SpeedButton1: TSpeedButton;
    procedure BtStartClick(Sender: TObject);
    procedure BtStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure restart;




  private

  public
     Configlist:tstringlist;
     ConfigFileName:string;
  end;


const
   configfile='ffmpegsender.cnf';

   ffmpegDefaultParameter: string =
     ('ffmpeg;-f pulse;-i;-acodec pcm_s16le;-ar 48000;-ac 2;-f rtp;-pkt_size 736;-fflags nobuffer;-flags low_delay;'+
     '-max_delay 0;-flush_packets 1;rtp://239.255.0.1:5010');


var
  Form1: TForm1;


implementation

{$R *.frm}
{ TForm1 }


procedure TForm1.BtStartClick(Sender: TObject);
var
  s:string;
  x:integer;
begin
  listbox1.items.Clear;
  terminate_all := False;
  s:=configlist[0];
  btstart.Enabled:=false;
  btstop.Enabled:=true;
  for x:=1 to length(s) do
     if s[x]=';' then s[x]:=' ';
  s:=trim(s);
  PrexeThreadedBash(s,listbox1);
 end;



procedure TForm1.BtStopClick(Sender: TObject);
begin
  terminate_all := True;
  if Assigned(th) then
  begin
    th.Stop;
    th := nil;
  end;
   ListboxAddScroll(listbox1,'CLOSED');
   btstart.Enabled:=true;
   btstop.Enabled:=false;
end;


procedure TForm1.restart;
var
  s:string;
  x:integer;
begin
if Assigned(th) then
begin
  terminate_all := True;
  th.Stop;
  th := nil;
  sleep(500);
  terminate_all := False;
  s:=configlist[0];
  for x:=1 to length(s) do
         if s[x]=';' then s[x]:=' ';
     PrexeThreadedBash(s,listbox1);
   end;
end;



  procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  terminate_all := True;

  if Assigned(th) then
  begin
    th.Stop;
    th := nil;
  end;
  Sleep(300);
end;

procedure TForm1.FormCreate(Sender: TObject);
  var
//  Proc: TProcess;
  SL: TStringList;
  i: Integer;
  Line, SourceName: String;
  x,p,n:integer;
  cnfstr,s:string;
  devicelist:tstringlist;
  proc:tprocess;
begin

  if fpGetUID = 0 then
  begin
    ShowMessage('This program must not be run with sudo or as root.');
    Halt(1);
  end;

  ConfigFileName := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) + '.config/ffmpegsender/ffmpegsender.conf';
  configlist:=tstringlist.create;
  forcedirectories(extractfilepath(configfilename));
  if fileexists(configfilename) then configlist.LoadFromFile(configfilename);

  ListBox1.Font.Size := 10;    // Schriftgröße
  ListBox1.ItemHeight := 10;   // Höhe jeder Zeile in Pixel


  devicelist:=tstringlist.Create;
  Proc := TProcess.Create(nil);
    SL := TStringList.Create;
    devicelist.Add('default');
  try
    Proc.Executable := 'pactl';
    Proc.Parameters.Add('list');
    Proc.Parameters.Add('short');
    Proc.Parameters.Add('sources');
    Proc.Options := [poUsePipes, poWaitOnExit, poStderrToOutPut];

    Proc.Execute;
    SL.LoadFromStream(Proc.Output);
    proc.free;
    for x:= 0 to sl.count-1 do
                 s:=(sl[x]);

    for i := 0 to SL.Count - 1 do
    begin
      Line := SL[i];

      // Zeilenformat:
      // 59<TAB>alsa_output....monitor<TAB>PipeWire<TAB>s16le...

      SourceName := Trim(Copy(Line,
        Pos(#9, Line) + 1,
        Pos(#9, Line, Pos(#9, Line) + 1) - Pos(#9, Line) - 1));

      if SourceName <> '' then
        devicelist.Add(SourceName);
    end;
     sl.free;

   // schon konfiguriert ?
   for x:=0 to devicelist.Count-1 do
    if pos(devicelist[x],configlist.text)=0 then
      // hinzufügen
      begin
           cnfstr:=ffmpegdefaultparameter;
           p:=pos('-i',cnfstr);
           insert(' '+devicelist[x],cnfstr,p+2);
           configlist.Add(cnfstr);
           forcedirectories(extractfilepath(configfilename));
           configlist.SaveToFile(configfilename);
      end;
  finally
  end;
   if paramstr(1)='-on' then BtStartClick(Self);
end;


procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  form2.showmodal;
end;

end.
