unit unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, ComCtrls, dynlibs, Sockets, UnixType, BaseUnix, Unix,
  pthreads, unit2;

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

  FIONREAD = $541B;


procedure closealsa;
function OpenAlsa: boolean;

var
   ConfigFileName:string;
    pcm: PPsnd_pcm_t;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    PaintBoxVU: TPaintBox;
    SpeedButton1: TSpeedButton;
    statuslabel: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure PaintBoxVUPaint(Sender: TObject);
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
  par_name, par_device, par_port, par_ip, par_freq, par_latency,par_volume: string;
  par_byteorder, par_hide: boolean;
  // Dpeakleft, Dpeakright, displaypeakleft, displaypeakright: smallint;
  displaypeakL, displaypeakR: integer;
  peakl: smallint;
  peakr: smallint;
  blockpeakL, blockpeakR: integer;
  rampleft, rampright: smallint;
  nc: integer;

  Form1: TForm1;
  ReceiverThread: TReceiverThread;
  delay: cint;
  framecount, underruns: integer;
  gain: double;

  VULeft, VURight: longint;        // aktueller Pegel
  PeakLeft, PeakRight: longint;   // Peak-Hold

  stream_ok, audio_ok: integer;



const
  version = '1.0.14';


implementation

{$R *.frm}


var
//  pcm: PPsnd_pcm_t;
  sock: longint;
  sockaddr: TInetSockAddr;
  frames, n: integer;
  res: boolean;



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


procedure NanoSleep(ns: int64);
var
  ts, rem: timespec;
begin
  ts.tv_sec := ns div 1000000000;
  ts.tv_nsec := ns mod 1000000000;

  while fpNanoSleep(@ts, @rem) <> 0 do
    ts := rem;
end;

procedure MicroSleep(us: int64);
var
  ts, rem: timespec;
begin
  ts.tv_sec := us div 1000000;           // Sekunden
  ts.tv_nsec := (us mod 1000000) * 1000; // Mikrosekunden → Nanosekunden

  while fpNanoSleep(@ts, @rem) <> 0 do
    ts := rem;
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
var
  device: string;
begin
  device := par_device;
  Result := False;
  // load the library
  n := snd_pcm_open(@pcm, PChar(device), SND_PCM_STREAM_PLAYBACK, 0);
  if n = 0 then
    n := snd_pcm_set_params(pcm, SND_PCM_FORMAT_S16_LE, SND_PCM_ACCESS_RW_INTERLEAVED, 2,                         // number of channels
      StrToInt(par_freq),                     // sample rate (Hz)
      1,                         // resampling on/off
      StrToInt(par_Latency));                // latency (us)
  Result := n = 0;

  if assigned(pcm) then
         form1.label6.Caption := 'Audio device: OK'
  else
    form1.label6.Caption := 'Audio device: failure';

  result:= assigned(pcm);

end;


procedure closealsa;
begin
  if assigned(pcm) then
  begin
    snd_pcm_drain(pcm);              // drain any remaining samples
    snd_pcm_close(pcm);
    pcm := nil;
    form1.label6.Caption := 'Audio device: failure';
  end;
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  form1.Caption := 'UDP player v' + version;
  as_Load;
end;

procedure TForm1.Label6Click(Sender: TObject);
begin

end;



procedure TForm1.PaintBoxVUPaint(Sender: TObject);
const
  MAX_LEVEL = 32767;
  PEAK_DECAY = 200;
  border = 2;
var
  L, R: integer;
  pL, pR: integer;
  h, mid: integer;
begin
  h := PaintBoxVU.Height;
  mid := h div 2; // aktuelle Werte holen (atomar)
  L := InterlockedExchange(vuleft, vuleft);
  R := InterlockedExchange(vuright, vuright);


  PeakLeft := PeakLeft - PEAK_DECAY;
  PeakRight := PeakRight - PEAK_DECAY;
  if L > PeakLeft then PeakLeft := L;
  if R > PeakRight then PeakRight := R;

  pL := (PaintBoxVU.Width * PeakLeft) div MAX_LEVEL;
  pR := (PaintBoxVU.Width * PeakRight) div MAX_LEVEL;
  with PaintBoxVU.Canvas do
  begin
    // Hintergrund
    Brush.Color := clBlack;
    FillRect(PaintBoxVU.ClientRect);
    // LEFT
    Brush.Color := clLime;
    // FillRect(Rect(0, 0, pL, mid - 2));
    FillRect(Rect(0, border, pL, mid - border div 2));
    // RIGHT
    Brush.Color := clAqua;
    FillRect(Rect(0, mid + border div 2, pR, h - border));
  end;
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
  double_smallints = packed record
    L, R: smallint;
  end;

function GetRTPHeaderSize(const Buf: pbyte; BufLen: integer): integer;
var
  Version, CC: byte;
  XBit: boolean;
  ExtLenWords: word;
begin
  // Minimalgröße prüfen
  if BufLen < 12 then
    Exit(0);

  // Erste Byte enthält Version (2 Bits), P, X, CC
  Version := (Buf[0] shr 6) and $03;  // Version
  if Version <> 2 then
    Exit(0); // Ungültige RTP-Version

  XBit := ((Buf[0] and $10) <> 0);    // 5. Bit = X
  CC := Buf[0] and $0F;               // untere 4 Bits = CSRC Count

  // Startgröße = 12 Bytes + CSRC-Liste
  Result := 12 + CC * 4;

  // Wenn Extension gesetzt, zusätzliche 4 + N*4 Bytes
  if XBit then
  begin
    if BufLen < Result + 4 then
      Exit(0); // Puffer zu klein für Extension-Header
    // Extension-Header: 2 Bytes Type + 2 Bytes Length in 32-Bit-Worten
    ExtLenWords := (Buf[Result + 2] shl 8) or Buf[Result + 3];
    Result := Result + 4 + ExtLenWords * 4;
  end;

  // Optional: prüfen, dass Result <= BufLen
  if Result > BufLen then
    Result := BufLen;
end;



procedure TReceiverThread.Execute;
const
  buffersize = 4096;
  framebuffersize = buffersize div 4;
  swapbuffersize = buffersize div 2;
var
  receivebuffer: array[0..buffersize - 1] of byte;
  framebuffer: array[0..framebuffersize - 1] of double_smallints absolute receivebuffer;
  swapbuffer: array[0..swapbuffersize - 1] of word absolute receivebuffer;
  lastreceived, received: integer;
  bufsize: integer = $10000;
  port: word;
  lport: longint;
  timeout: TTimeVal;
  minL, maxL, minR, maxR, v: smallint;
  headersize: integer;
  bufferduplicated: integer;
  flags: longint;
  bytesAvailable, empfang: integer;


  procedure setdisplaypeak;
  var
    y: integer;
  begin
    // Initialisierung
    minL := 0;
    maxL := 0;
    minR := 0;
    maxR := 0;
    // Schleife über alle Samples
    for y := headersize shr 2 to (received shr 2) - 1 do
    begin
      v := Framebuffer[y].L;
      if v < minL then
        minL := v; // größter Ausschlag nach unten
      if v > maxL then
        maxL := v; // größter Ausschlag nach oben
      v := Framebuffer[y].R;
      if v < minR then
        minR := v;
      if v > maxR then
        maxR := v;
    end;
    if minl < -32767 then minl := 32767;
    if minr < -32767 then minr := 32767;
    minl := -minl;
    minr := -minr;

    if maxl < minl then maxl := minl;
    if maxr < minr then maxr := minr;

    InterlockedExchange(VULeft, maxl);
    InterlockedExchange(VURight, maxr);
  end;


  procedure BufferToAlsa(Playbytes: integer);
  begin
    //    headersize:= 12;
    if not assigned(pcm) then exit;
    frames := snd_pcm_writei(pcm, @Framebuffer[headersize div 4], (Playbytes - headersize) div 4);
    if frames < 0 then
    begin
      frames := snd_pcm_recover(pcm, frames, 0);
      if frames >= 0 then
        frames := snd_pcm_writei(pcm, @Framebuffer[headersize div 4], (Playbytes - headersize) div 4);
    end;
  end;

  procedure bufferswapendian(buffersize: integer);
  var
    x: integer;
  begin
    if par_byteorder then
    begin
      for x := headersize to (buffersize shr 1) - 1 do swapbuffer[x] := SwapEndian(swapbuffer[x]);
    end;
  end;



  begin
  res := SetThreadPriority(getcurrentthreadid, cprrr, 40);
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

  timeout.tv_sec := 0;  // Timeout auf 1 ms setzen
  timeout.tv_usec := 1000;
  fpsetsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, @timeout, SizeOf(timeout));

  flags := fpfcntl(sock, F_GETFL, 0);      // aktuelle Flags lesen
  fpfcntl(sock, F_SETFL, flags or O_NONBLOCK); // O_NONBLOCK setzen



  if fpBind(sock, @sockaddr, SizeOf(sockaddr)) < 0 then
  begin
    writeln('Fehler beim Binden des Sockets.');
    Exit;
  end;

  empfang:=0;
   bufferduplicated :=10;

  repeat
      Dec(empfang);
      fpIoctl(sock, FIONREAD, @bytesAvailable);

      if bytesAvailable > 0 then
      begin
         received := fpRecv(sock, @receivebuffer, SizeOf(Framebuffer), 0); // in samples
         if empfang < 10 then headersize := getrtpheadersize(@receivebuffer, SizeOf(Framebuffer));
      if assigned(pcm) then
        begin
          snd_pcm_delay(pcm, @delay);
          interlockedexchange(framecount, delay);
       end;

        if received > 12 then
        begin
          bufferswapendian(received);
          BufferToAlsa(received);
          bufferduplicated := 0;
          setdisplaypeak;
        end;
        lastreceived := received;
        empfang := 100;
      end
      else

       begin
        if assigned(pcm) then
        begin
          snd_pcm_delay(pcm, @delay);
          interlockedexchange(framecount, delay);

          if (delay < 200) and (bufferduplicated < 5) then
          begin
            BufferToAlsa(lastreceived);
            Inc(bufferduplicated);
            interlockedincrement(underruns);
            MicroSleep(2500);
          end;
        end;
      end;
     MicroSleep(1000);

      if assigned(pcm) then  interlockedexchange(audio_ok, 1)
      else
        interlockedexchange(audio_ok, 0);

       if empfang > 0 then  interlockedexchange(stream_ok, 1)
      else
        interlockedexchange(stream_ok, 0);

        interlockedexchange(framecount, delay);

        until terminated;

  closealsa;
  closesocket(sock);
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Inc(nc);
  if nc mod 5 = 0 then label1.Caption := IntToStr(framecount);
  if nc mod 60 = 0 then
  begin
    label4.Caption := IntToStr(underruns);
    if audio_ok > 0 then
      label6.Caption := 'Audio device: OK'
    else
      form1.label6.Caption := 'Audio device: failure';
    if stream_ok > 0 then
      form1.label5.Caption := 'Audio stream: connected'
    else
    begin
      form1.label5.Caption := 'Audio stream: disconnected';
      vuleft := 0;
      vuright := 0;
    end;
  end;
  PaintBoxVU.Invalidate;
end;

end.
