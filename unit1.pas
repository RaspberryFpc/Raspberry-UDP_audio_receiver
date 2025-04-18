unit unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  dynlibs, Sockets, UnixType, pthreads;

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




type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    statuslabel: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow;
    procedure formhide;

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
  Form1: TForm1;
  ReceiverThread: TReceiverThread;
  delay: cint;

implementation

{$R *.frm}

const
  configFilename='udp_audio_receiver.conf';

var
  memostrings: TStringList;
  pcm: PPsnd_pcm_t;
  testbuffer: array [0..7 * 96 - 1] of smallint;
  received: integer;
  sock: longint;
  sockaddr: TInetSockAddr;
  endthread: boolean;
  frames, n: integer;
  res: boolean;

  parport, paripadresse, parfrequenz, parnetbuffer, parAlsaLatency, parswap: string;


procedure Tform1.FormShow;
begin
  form1.Show;
end;

procedure TForm1.formHide;
begin
  form1.hide;
end;


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


function openalsa: boolean;
const
  device = 'default' + #0;             // name of sound device   'hw:0,0'+ #0;//
begin
  Result := False;
  as_Load;       // load the library
  n := snd_pcm_open(@pcm, 'hw:0,0', SND_PCM_STREAM_PLAYBACK, 0);
  if n = 0 then
    n := snd_pcm_set_params(pcm, SND_PCM_FORMAT_S16_LE, SND_PCM_ACCESS_RW_INTERLEAVED, 2,                         // number of channels
      StrToInt(parfrequenz),                     // sample rate (Hz)
      1,                         // resampling on/off
      StrToInt(parAlsaLatency));                // latency (us)
  Result := n = 0;
  TThread.Synchronize(nil, @Form1.formshow);
end;


procedure closealsa;
begin
  TThread.Synchronize(nil, @Form1.formhide);
  snd_pcm_drain(pcm);              // drain any remaining samples
  snd_pcm_close(pcm);
  as_unload;
end;



procedure TForm1.FormCreate(Sender: TObject);
var
  i, x, p: integer;
  par1, par2, s: string;
begin
  memo1.Lines.LoadFromFile(extractfilepath(application.ExeName) + configFilename);
  for x := 0 to memo1.Lines.Count - 1 do
  begin
    s := lowercase(memo1.Lines[x]);
    p := pos('=', s);
    par1 := trim(copy(s, 1, p - 1));
    par2 := trim(copy(s, p + 1, 1000));
    if (par1) = 'ip' then  paripadresse := par2;
    if (par1) = 'port' then  parport := par2;
    if (par1) = 'sizenetworkbuffer' then  parnetbuffer := par2;
    if (par1) = 'frequenz' then parfrequenz := par2;
    if (par1) = 'swap' then parswap := par2;
    if (par1) = 'alsalatency' then parAlsaLatency := par2;
  end;


  // Starte RTP-Empfänger in einem eigenen Thread
  receiverthread := Treceiverthread.Create(False);

end;


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  memo1.Lines.SaveToFile(extractfilepath(application.ExeName) + configFilename);
  receiverThread.Terminate;
  receiverThread.WaitFor; // Wartet, bis der Thread beendet ist
  receiverThread.Free;    // Thread-Objekt freigebe
  endthread := True;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
end;


threadvar
  audiobuffer: array[0..4095] of byte;
  swapbuffer: array [0..2047] of word absolute audiobuffer;
  lastreceived: int64;
  testval: smallint;


procedure TReceiverThread.Execute;
var
  bufsize: integer = $8000;// 256 KB
  port: word;
  lport: longint;
  x: integer;
  timeout: TTimeVal;
  alsarun: boolean;
  sound: boolean;
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
  lport := 5010;
  trystrtoint(parport, Lport);
  port := lport;

  sockaddr.sin_port := htons(PORT);
  sockaddr.sin_addr := StrToNetAddr(paripadresse);

  fpsetsockopt(sock, SOL_SOCKET, SO_RCVBUF, @bufsize, SizeOf(bufsize));

  timeout.tv_sec := 2;  // Timeout auf 2 Sekunden setzen
  timeout.tv_usec := 0;
  fpsetsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, @timeout, SizeOf(timeout));


  if fpBind(sock, @sockaddr, SizeOf(sockaddr)) < 0 then
  begin
    writeln('Fehler beim Binden des Sockets.');
    Exit;
  end;

  //  openalsa;
  alsarun := False;  //true;
  repeat
    sound := False;

    received := fpRecv(sock, @audiobuffer, SizeOf(audiobuffer), 0); // in samples

    if received > 0 then
    begin
      for x := 12 to received - 1 do
        if audiobuffer[x] <> 0 then
        begin
          sound := True;
          break;
        end;


      if (not alsarun) and sound then
      begin
        openalsa;
        alsarun := True;
      end;
      if alsarun then
      begin
        snd_pcm_delay(pcm, @delay);
        if parswap <> '0' then
        begin
          for x := 6 to (received - 13) div 2 do swap(swapbuffer[x]);
        end;
        frames := snd_pcm_writei(pcm, @audiobuffer[12], (received - 12) div 4);
        if frames < 0 then
          frames := snd_pcm_recover(pcm, frames, 0); // try to recover from any error
        received := 0;
      end;
    end;
    if sound then lastreceived := gettickcount64;
    if gettickcount64 - lastreceived > 10000 then
    begin
      if alsarun = True then
      begin
        alsarun := False;
        closealsa;
      end;
    end;


  until terminated; //or ((gettickcount64-lastreceived)>100);
  if alsarun then
  begin
    closealsa;
    alsarun := False;
  end;
  closesocket(sock);
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  label1.Caption := IntToStr(delay);
end;




end.
