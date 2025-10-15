unit unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, ComCtrls, dynlibs, Sockets, UnixType, pthreads, unit2, inifiles;

type
  TClassPriority = (cprOther, cprFIFO, cprRR);

  // Signed frames quantity
  snd_pcm_sframes_t = cint;

  // PCM handle
  PPsnd_pcm_t = ^Psnd_pcm_t;
  Psnd_pcm_t = Pointer;

  // PCM stream (direction)
  snd_pcm_stream_t = cint;

  // PCM sample format
  snd_pcm_format_t = cint;

  // PCM access type
  snd_pcm_access_t = cint;

  // Unsigned frames quantity
  snd_pcm_uframes_t = cuint;

const
  // Playback stream
  SND_PCM_STREAM_PLAYBACK: snd_pcm_stream_t = 0;
  SND_PCM_STREAM_CAPTURE: snd_pcm_stream_t = 1;
  SND_PCM_FORMAT_U8: cint = 1;  // Unsigned 8-bit PCM
  SND_PCM_FORMAT_S16_LE: cint = 2;  // Signed 16-bit PCM, Little Endian
  SND_PCM_FORMAT_S16_BE: cint = 3;  // Signed 16-bit PCM, Big Endian
  SND_PCM_FORMAT_S24_LE: cint = 6;  // Signed 24-bit PCM, Little Endian
  SND_PCM_FORMAT_S24_BE: cint = 7;  // Signed 24-bit PCM, Big Endian
  SND_PCM_FORMAT_FLOAT_LE: cint = 10; // 32-bit float PCM, Little Endian
  SND_PCM_ACCESS_RW_INTERLEAVED: snd_pcm_access_t = 3;

  RTP_HEADER_SIZE = 12;   // Standardgröße des RTP-Headers
  PORT = 5010;            // UDP-Port für RTP
  buffersize = 4096;

procedure closealsa;
function OpenAlsa: boolean;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    SpeedButton1: TSpeedButton;
    statuslabel: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private

  public

  end;



type
  TreceiverThread = class(TThread)
  protected
    procedure Execute; override;
  end;


var
  snd_pcm_open: function(pcm: PPsnd_pcm_t; Name: pchar; stream: snd_pcm_stream_t; mode: cint): cint; cdecl;
  snd_pcm_set_params: function(pcm: Psnd_pcm_t; format: snd_pcm_format_t; access: snd_pcm_access_t; channels, rate: cuint; soft_resample: cint; latency: cuint): cint; cdecl;
  snd_pcm_writei: function(pcm: Psnd_pcm_t; buffer: Pointer; size: snd_pcm_uframes_t): snd_pcm_sframes_t; cdecl;
  snd_pcm_recover: function(pcm: Psnd_pcm_t; err, silent: cint): cint; cdecl;
  snd_pcm_drain: function(pcm: Psnd_pcm_t): cint; cdecl;
  snd_pcm_close: function(pcm: Psnd_pcm_t): cint; cdecl;
  snd_pcm_avail: function(pcm: PSnd_pcm_t): integer; cdecl;
  snd_pcm_delay: function(pcm: Psnd_pcm_t; delay: Pcint): cint; cdecl;

  // Special function for dynamic loading of lib ...
  as_Handle: TLibHandle = dynlibs.NilHandle; // this will hold our handle for the lib
  ReferenceCounter: integer = 0;  // Reference counter

function as_IsLoaded: boolean; inline;
function as_Load: boolean; // load the lib
procedure as_Unload();     // unload and frees the lib from memory


var
  par_name, par_netbuffer, par_port, par_ip, par_freq, par_latency: string;
  par_byteorder, par_hide: boolean;


  Form1: TForm1;
  ReceiverThread: TReceiverThread;
  delay: cint;

const
  version = '1.0.6';


implementation

{$R *.frm}


var
  pcm: PPsnd_pcm_t;
  received: integer;
  sock: longint;
  sockaddr: TInetSockAddr;
  frames, n: integer;
  res: boolean;
  timercounter: word;
  peakleft, peakright: integer;
  DisplayPeakL, DisplayPeakR: integer;


function SetThreadPriority(aThreadID: TThreadID; class_priority: TClassPriority; sched_priority: integer): boolean;
var
  param: sched_param;
  ret: integer;
  aPriority: integer;
begin
  param.sched_priority := sched_priority;
  aPriority := Ord(class_priority);
  ret := pthread_setschedparam(pthread_t(aThreadID), aPriority, @param);
  Result := (ret = 0);
end;

function as_IsLoaded: boolean;
begin
  Result := (as_Handle <> dynlibs.NilHandle);
end;


function as_Load: boolean; // load the lib
var
  thelib: string = 'libasound.so.2';
begin // go & load the library
  as_Handle := DynLibs.SafeLoadLibrary(thelib); // obtain the handle we want
  if as_Handle <> DynLibs.NilHandle then
  begin // now we tie the functions to the VARs from above

    Pointer(snd_pcm_open) := DynLibs.GetProcedureAddress(as_Handle, PChar('snd_pcm_open'));
    Pointer(snd_pcm_set_params) := DynLibs.GetProcedureAddress(as_Handle, PChar('snd_pcm_set_params'));
    Pointer(snd_pcm_writei) := DynLibs.GetProcedureAddress(as_Handle, PChar('snd_pcm_writei'));
    Pointer(snd_pcm_recover) := DynLibs.GetProcedureAddress(as_Handle, PChar('snd_pcm_recover'));
    Pointer(snd_pcm_drain) := DynLibs.GetProcedureAddress(as_Handle, PChar('snd_pcm_drain'));
    Pointer(snd_pcm_close) := DynLibs.GetProcedureAddress(as_Handle, PChar('snd_pcm_close'));
    Pointer(snd_pcm_avail) := DynLibs.GetProcedureAddress(as_Handle, PChar('snd_pcm_avail'));
    Pointer(snd_pcm_delay) := DynLibs.GetProcedureAddress(as_Handle, PChar('snd_pcm_delay'));
    Result := as_IsLoaded;
    ReferenceCounter := 1;
  end;
end;

procedure as_Unload();
begin
  DynLibs.UnloadLibrary(as_Handle);
  as_Handle := DynLibs.NilHandle;
end;

function OpenAlsa: boolean;

  //function openalsa: boolean;
var
  device, au_name: string;   //'hw:0,0';             // name of sound device
  p: integer;
begin
  // paroutputdevice:=trim(paroutputdevice);
  //  closealsa;

  p := pos(' ', par_name);
  if p = 0 then  device := par_name
  else
    device := trim(copy(par_name, 1, p - 1));
  Result := False;
  // load the library
  n := snd_pcm_open(@pcm, PChar(device), SND_PCM_STREAM_PLAYBACK, 0);
  if n = 0 then
    n := snd_pcm_set_params(pcm, SND_PCM_FORMAT_S16_LE, SND_PCM_ACCESS_RW_INTERLEAVED, 2,                         // number of channels
      StrToInt(par_freq),                     // sample rate (Hz)
      1,                         // resampling on/off
      StrToInt(par_Latency));                // latency (us)
  Result := n = 0;
end;


procedure closealsa;
begin
  if assigned(pcm) then
  begin
    snd_pcm_drain(pcm);              // drain any remaining samples
    snd_pcm_close(pcm);
    pcm := nil;
  end;
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  form1.Caption := 'UDP player v' + version;
  as_Load;
end;



procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  form2.showmodal;
end;


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  receiverThread.Terminate;
  receiverThread.WaitFor; // Wartet, bis der Thread beendet ist
  receiverThread.Free;    // Thread-Objekt freigebe
  as_unload;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  form1.Close;
end;




type
  double_smallints = record
    L: smallint;
    R: smallint;
  end;

threadvar
  audiobuffer: array[0..4095] of byte;
  swapbuffer: array [0..2047] of word absolute audiobuffer;
  Framebuffer: array [0..1023] of double_smallints absolute audiobuffer;


procedure TReceiverThread.Execute;
var
  bufsize: integer = $8000;// 256 KB
  port: word;
  lport: longint;
  x, y: integer;
  timeout: TTimeVal;
  //  alsarun: boolean;
  sound: boolean;
  peak: integer;
begin
  res := SetThreadPriority(getcurrentthreadid, cprrr, 22);

  //  openalsa;
  sock := fpSocket(AF_INET, SOCK_DGRAM, 0);
  if sock < 0 then
  begin
    writeln('Fehler beim Erstellen des Sockets.');
    Exit;
  end;


  FillChar(sockaddr, SizeOf(sockaddr), 0);
  sockaddr.sin_family := AF_INET;
  lport := StrToInt(par_port);
  trystrtoint(par_port, Lport);
  port := lport;

  sockaddr.sin_port := htons(PORT);
  sockaddr.sin_addr := StrToNetAddr(par_ip);

  fpsetsockopt(sock, SOL_SOCKET, SO_RCVBUF, @bufsize, SizeOf(bufsize));

  timeout.tv_sec := 2;  // Timeout auf 2 Sekunden setzen
  timeout.tv_usec := 0;
  fpsetsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, @timeout, SizeOf(timeout));


  if fpBind(sock, @sockaddr, SizeOf(sockaddr)) < 0 then
  begin
    writeln('Fehler beim Binden des Sockets.');
    Exit;
  end;


  repeat
    received := fpRecv(sock, @audiobuffer, SizeOf(audiobuffer), 0); // in samples

    if assigned(pcm) and   (received>0) then
    begin

    if par_byteorder then
      begin
        for x := 0 to (received div 2) - 1 do
          swapbuffer[x] := SwapEndian(swapbuffer[x]);
      end;


      //beim 6.sample anfangen für links
       snd_pcm_delay(pcm, @delay);

      frames := snd_pcm_writei(pcm, @audiobuffer[12], (received - 12) div 4);
       if frames < 0 then
begin
  frames := snd_pcm_recover(pcm, frames, 0);
  if frames >= 0 then
    frames := snd_pcm_writei(pcm, @audiobuffer[12], (received - 12) div 4);
end;





    end;



      peakleft := 0;
      peakright := 0;

      for y := 3 to (received - 12) div 4 - 1 do
      begin
        if Framebuffer[y].L < 0 then
          peak := -integer(Framebuffer[y].L)   // erst in Integer casten
        else
          peak := Framebuffer[y].L;
        if peak > peakleft then
          peakleft := peak;

        if Framebuffer[y].R < 0 then
          peak := -integer(Framebuffer[y].R)
        else
          peak := Framebuffer[y].R;

        if peak > peakright then
          peakright := peak;
      end;

 //   sound := (peakleft > 0) or (peakright > 0);


  until terminated;
  closealsa;
  closesocket(sock);
end;




procedure VUMeter;
const
  decayStep = $8000 div 200; // für 4s bei 20ms
var
  peak: integer;
begin

  // atomar auslesen und zurücksetzen
  peak := InterlockedExchange(peakleft, 0);
  Dec(DisplayPeakL, decayStep);
  if DisplayPeakL < peak then DisplayPeakL := peak;

  peak := InterlockedExchange(Peakright, 0);
  Dec(DisplayPeakR, decayStep);
  if DisplayPeakR < peak then DisplayPeakR := peak;

  peakleft := 0;
  Peakright := 0;

  form1.Progressbar1.Position := displayPeakL;
  form1.Progressbar2.Position := displayPeakR;

end;




procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Inc(timercounter);
  if timercounter mod 25 = 0 then label1.Caption := IntToStr(delay);
  VUMeter;
end;



end.
