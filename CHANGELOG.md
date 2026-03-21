 # Changelog

All notable changes to this project are documented in this file.

## [1.1.1] – 2026-03-21 
###Realtime UDP Audio Improvements
Audio delay display changed from samples to milliseconds (ms) for better readability
Reduced FFmpeg RTP packet size from default 1472 bytes to 736 bytes

### Latency Improvements
Sender latency reduced to approx. 3.9 ms due to smaller packet size
Network latency:~0.5 ms 
Receiver latency: approx. 2.5 ms
👉 Resulting in a total end-to-end latency of < 7 ms

This corresponds roughly to the acoustic delay of being ~2.5 meters away from a speaker



## [1.1.0] – 2026-03-18 
###Realtime UDP Audio Improvements
-Removed buffer duplication for direct packet processing.
-Switched to poll-based waiting for cleaner and more efficient socket handling.
-On USB audio devices, ALSA buffer times below 2.5 ms are now achievable.


## [1.0.13] – 2026-03-15
### Bugfix
- Fixed an issue where audio device addresses could change on each boot. 
- When reading the audio devices, the hardware addresses are now corrected if necessary to ensure consistent mapping.



## [1.0.12+1] – 2026-01-04
### Changed
Updated README
Renamed sender script to ffmpeg_transmitter
Moved IP address and port to constants in the sender script for easier configuration


## [1.0.12] – 2026-01-03
### Changed
- Configuration handling updated:
  - Config files are now stored in `~/.udp_player/udp_player.conf`
  - Config directory is created automatically on first start.

### Added
- Debian package (`.deb`) installation support.
- Desktop menu entry installed automatically via dpkg.
- Linux capabilities set on installation (`cap_net_raw,cap_sys_nice+ep`), allowing the player to run **without sudo**.

### Removed
- Requirement to start the player with `sudo` for real-time priority.

---

## [1.0.11] – 2025-12-22
### Improved
- Display of the audio output device status even when no audio stream is connected.

## [1.0.10] – 2025-12-21
### Added
- New low-CPU VU meter implementation.
- GUI now shows whether a stream is connected.
- GUI now indicates whether the audio output is ready.
- GUI displays the number of buffer duplications (not audible).

### Improved
- Audio thread priority increased to 40 for better real-time performance.
- Buffer duplication during underruns optimized to further reduce audible artifacts.

## [1.0.9] – 2025-12-14
### Removed
- Removed silence handling for resynchronisation – no longer required.

### Added
- In the unlikely case of a missing audio block, the last valid block is repeated up to five times to prevent audible dropouts.

## [1.0.8] – 2025-10-14
### Fixed
- Recovering of frames improved.

## [1.0.6] – 2025-10-14
### Fixed
- Selection of an unavailable audio device could completely prevent a restart.
- Unavailable devices can no longer be selected.
- During startup, all devices are checked for availability.
- Silence-based auto-shutdown has been removed.

## [1.0.5] – 2025-09-23
### Fixed
- Port setting: default value 5010 and alternative configurations now work correctly.
- Endian setting now functions as expected.
- Config file handling is now Linux-conform.

### Added
- Separate settings for all available audio outputs.
- VU meter display for audio signal levels.

## [1.0.4] – 2025-08-18
### Added
- Option to select the audio output device (Headphones/Jack, HDMI, USB sound card).

## [1.0.3] – 2025-08-13
### Fixed
- Crash when the settings form was closed while no sound was being played.

## [1.0.2] – 2025-08-13
### Added
- A separate settings form is now available.
- If the `Hide` checkbox is enabled, the application window will remain permanently hidden once audio starts playing.

## [1.0.1] – 2025-07-27
### Added
- A binary has been added to `/bin` for quick and simple testing.
