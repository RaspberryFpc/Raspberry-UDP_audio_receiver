# Changelog

All notable changes to this project are documented in this file.

## [1.0.5] – 2025-09-23
### Fixed
- Port setting: default value 5010 and alternative configurations now work correctly.
- Endian setting now functions as expected.
- Config file handling is now Linux-conform, stored at `/home/pi/.config/udp_player.cfg`.

### Added
- Separate settings for all available audio outputs.
- VU meter display for audio signal levels.

## [1.0.4] – 2025-08-18
###Added
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
 - A binary has been added to /bin for quick and simple testing.

