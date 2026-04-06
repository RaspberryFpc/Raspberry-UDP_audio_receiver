unit alsa_volume;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ctypes, dynlibs;

function GetVolume(CardIndex: integer; out Percent: integer): boolean;
function SetVolume(CardIndex: integer; Percent: integer): boolean;


implementation

type
  Psnd_mixer_t = Pointer;
  Psnd_mixer_elem_t = Pointer;
  Psnd_mixer_selem_id_t = Pointer;

var
  asound: TLibHandle;

  snd_mixer_open: function(mixer: PPointer; mode: cint): cint; cdecl;
  snd_mixer_attach: function(mixer: Pointer; Name: pchar): cint; cdecl;
  snd_mixer_selem_register: function(mixer: Pointer; options: Pointer; classp: PPointer): cint; cdecl;
  snd_mixer_load: function(mixer: Pointer): cint; cdecl;
  snd_mixer_first_elem: function(mixer: Pointer): Pointer; cdecl;
  snd_mixer_elem_next: function(elem: Pointer): Pointer; cdecl;
  snd_mixer_selem_is_active: function(elem: Pointer): cint; cdecl;
  snd_mixer_selem_get_name: function(elem: Pointer): pchar; cdecl;

  snd_mixer_selem_has_playback_volume: function(elem: Pointer): cint; cdecl;
  snd_mixer_selem_get_playback_volume_range: function(elem: Pointer; min, max: Plongint): cint; cdecl;
  snd_mixer_selem_set_playback_volume_all: function(elem: Pointer; Value: clong): cint; cdecl;
  snd_mixer_selem_get_playback_volume: function(elem: Pointer; channel: cint; Value: Plongint): cint; cdecl;

  snd_mixer_close: function(mixer: Pointer): cint; cdecl;

const
  SND_MIXER_SCHN_FRONT_LEFT = 0;

function LoadALSA: boolean;
begin
  if asound <> 0 then exit(True);

  asound := LoadLibrary('libasound.so');
  if asound = 0 then exit(False);

  Pointer(snd_mixer_open) := GetProcAddress(asound, 'snd_mixer_open');
  Pointer(snd_mixer_attach) := GetProcAddress(asound, 'snd_mixer_attach');
  Pointer(snd_mixer_selem_register) := GetProcAddress(asound, 'snd_mixer_selem_register');
  Pointer(snd_mixer_load) := GetProcAddress(asound, 'snd_mixer_load');
  Pointer(snd_mixer_first_elem) := GetProcAddress(asound, 'snd_mixer_first_elem');
  Pointer(snd_mixer_elem_next) := GetProcAddress(asound, 'snd_mixer_elem_next');
  Pointer(snd_mixer_selem_is_active) := GetProcAddress(asound, 'snd_mixer_selem_is_active');
  Pointer(snd_mixer_selem_get_name) := GetProcAddress(asound, 'snd_mixer_selem_get_name');

  Pointer(snd_mixer_selem_has_playback_volume) := GetProcAddress(asound, 'snd_mixer_selem_has_playback_volume');
  Pointer(snd_mixer_selem_get_playback_volume_range) := GetProcAddress(asound, 'snd_mixer_selem_get_playback_volume_range');
  Pointer(snd_mixer_selem_set_playback_volume_all) := GetProcAddress(asound, 'snd_mixer_selem_set_playback_volume_all');
  Pointer(snd_mixer_selem_get_playback_volume) := GetProcAddress(asound, 'snd_mixer_selem_get_playback_volume');

  Pointer(snd_mixer_close) := GetProcAddress(asound, 'snd_mixer_close');

  Result := True;
end;

function OpenMixer(CardIndex: integer; out Mixer: Pointer): boolean;
var
  Name: string;
begin
  Result := False;

  if snd_mixer_open(@Mixer, 0) < 0 then exit;

  Name := 'hw:' + IntToStr(CardIndex);

  if snd_mixer_attach(Mixer, PChar(Name)) < 0 then exit;
  if snd_mixer_selem_register(Mixer, nil, nil) < 0 then exit;
  if snd_mixer_load(Mixer) < 0 then exit;

  Result := True;
end;

function FindVolumeElem(Mixer: Pointer): Pointer;
var
  elem: Pointer;
begin
  Result := nil;

  elem := snd_mixer_first_elem(Mixer);
  while elem <> nil do
  begin
    if (snd_mixer_selem_is_active(elem) <> 0) and (snd_mixer_selem_has_playback_volume(elem) <> 0) then
    begin
      Result := elem;
      exit;
    end;

    elem := snd_mixer_elem_next(elem);
  end;
end;

function SetVolume(CardIndex: integer; Percent: integer): boolean;
var
  mixer, elem: Pointer;
  minv, maxv: clong;
  Value: clong;
begin
  Result := False;

  if not LoadALSA then exit;
  if not OpenMixer(CardIndex, mixer) then exit;

  elem := FindVolumeElem(mixer);
  if elem = nil then
  begin
    snd_mixer_close(mixer);
    exit;
  end;

  snd_mixer_selem_get_playback_volume_range(elem, @minv, @maxv);

  Value := minv + (Percent * (maxv - minv) div 100);

  snd_mixer_selem_set_playback_volume_all(elem, Value);

  snd_mixer_close(mixer);
  Result := True;
end;

function GetVolume(CardIndex: integer; out Percent: integer): boolean;
var
  mixer, elem: Pointer;
  minv, maxv, Value: clong;
begin
  Result := False;
  Percent := 0;

  if not LoadALSA then exit;
  if not OpenMixer(CardIndex, mixer) then exit;

  elem := FindVolumeElem(mixer);
  if elem = nil then
  begin
    snd_mixer_close(mixer);
    exit;
  end;

  snd_mixer_selem_get_playback_volume_range(elem, @minv, @maxv);
  snd_mixer_selem_get_playback_volume(elem, SND_MIXER_SCHN_FRONT_LEFT, @Value);

  if maxv > minv then
    Percent := (Value - minv) * 100 div (maxv - minv);

  snd_mixer_close(mixer);
  Result := True;
end;

initialization
  asound := 0;

finalization
  if asound <> 0 then
    FreeLibrary(asound);

end.
