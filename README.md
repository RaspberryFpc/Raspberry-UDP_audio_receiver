 # 🎶 Network Audio Receiver and Sender (UDP) for Raspberry Pi

A lightweight UDP stereo audio receiver together with an FFmpeg-based sender frontend for Raspberry Pi.

* Ultra-low latency audio streaming over UDP
* Direct ALSA output with PipeWire compatibility via ALSA emulation
* Developed in Free Pascal using Codetyphon
* Tested on Debian Bookworm and Debian Trixie
* Ideal for real-time monitoring, live audio, and low-latency streaming setups

---

## ✨ Features

* Receives stereo audio over UDP with selectable audio outputs such as 3.5 mm jack, HDMI, USB audio, and more
* Supports both multicast and unicast (singlecast)
* Default multicast settings work out of the box in almost any local network
* FFmpeg sender frontend included
* Direct ALSA audio output for minimal delay
* Fully compatible with PipeWire via ALSA emulation
* Uncompressed audio for maximum quality and minimal processing delay
* Lightweight with minimal dependencies
* Developed in Free Pascal using Codetyphon
* Window is visible on startup
* Optional “Start Minimized” mode
* Supports multiple audio devices with individual settings

---

## ⚡ Ultra-Low Latency Audio Streaming

This project is optimized for extremely low end-to-end latency and can achieve less than 7 ms total audio delay over the network.

By reducing the FFmpeg RTP packet size from the default 1472 bytes to 736 bytes, latency is significantly reduced across the entire transmission path.

* 🚀 Sender latency: approximately 3.9 ms
* 🌐 Network latency: approximately 0.5 ms
* 🎧 Receiver latency: approximately 2.5 ms

👉 Total latency: less than 7 ms

### 🔊 Real-World Comparison

This is roughly the same delay as standing about 2.5 meters away from a speaker.

### 💡 Designed for Performance

* Buffer and delay values are displayed in milliseconds for easier monitoring
* Optimized for low-latency ALSA playback
* Smaller packets improve response time with only minimal protocol overhead

---

## 💡 Example Test Setup

* Sender: Raspberry Pi 5 connected via Wi-Fi streaming audio over UDP
* Receiver: Raspberry Pi 4 connected via Ethernet
* Output: 3.5 mm jack to HiFi amplifier, HDMI audio, or USB audio

Result: Stable low-latency playback on a typical home network, even while streaming video.

---

## 📦 Downloads

Downloads are available from:

* [https://sourceforge.net/projects/raspberry-udp-audio-receiver/](https://sourceforge.net/projects/raspberry-udp-audio-receiver/)
* [https://github.com/RaspberryFpc/Raspberry-UDP_audio_receiver/](https://github.com/RaspberryFpc/Raspberry-UDP_audio_receiver/)

---

## 📥 Installation

Use the provided `.deb` packages from the `bin` directory.

Install the player:

```bash
sudo apt install /path/to/udp-player.deb
```

Install the sender:

```bash
sudo apt install /path/to/udp-sender.deb
```

---

## ▶️ Usage

### ▶️ Start the Player

Start the player using the desktop menu entry created during installation.

### 📤 Sender

Start the sender using the desktop menu entry.

In the sender settings, you can configure:

* Audio source
* Destination IP address
* UDP port

Default multicast address:

```text
239.255.0.1
```

For multicast, use an address in the range:

```text
224.0.0.0 – 239.255.255.255
```

For unicast (singlecast), use a free IPv4 address in your local network.

---

## ⚙️ Player Settings Description

| Control / Field        | Description                                                                                                                                          |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Audio Output Selection | Select the audio output device such as headphones, HDMI, or USB audio. If no configuration exists, a default configuration is created automatically. |
| IP                     | IP address to receive audio from. Use `0.0.0.0` to listen on all network interfaces.                                                                 |
| Port                   | UDP port for incoming audio. Default: `5010`                                                                                                         |
| Frequency              | Audio sample rate in Hz                                                                                                                              |
| Latency                | Audio latency in samples. Typical values: `22000` for headphone output and `4000` for USB audio                                                      |
| Swap Byte Order        | Enable this if the incoming audio stream uses a different byte order                                                                                 |
| Hide Window            | If enabled, the application window is minimized or hidden after audio playback starts                                                                |
| Test Changes           | Applies the current settings immediately without saving                                                                                              |
| Save Changes           | Saves the current settings to the configuration file                                                                                                 |
| Delete Device          | Deletes the selected device configuration. Missing configurations are recreated automatically at the next start                                      |

---

## 🎯 Latency Optimization

* Lower buffer sizes reduce delay
* Too low values may cause dropouts or crackling audio
* Best values depend on:

  * Network type (LAN is usually faster than Wi-Fi)
  * Raspberry Pi performance
  * Audio hardware

---

## 🔊 Audio Volume

If the sound is too quiet, increase the volume in the player settings.

---

## 📦 Deinstallation

```bash
sudo apt purge udp-player
sudo apt purge udp-sender
```

---

## 📜 License

This project is licensed under the MIT License.

---

## 🌐 Other Projects by the Author

* [pibackup](https://github.com/RaspberryFpc/pibackup) – Portable live backup and restore tool with GUI, Zstandard compression, auto-shrinking and flexible restore options.
* [DS18B20-FPC-Pi-GUI](https://github.com/RaspberryFpc/DS18B20-FPC-Pi-GUI) – GUI tool for reading DS18B20 temperature sensors with linearization for high accuracy.
* [RaspberryPi-BME280-GUI](https://github.com/RaspberryFpc/RaspberryPi-BME280-GUI) – GUI application for accessing the BME280 I²C sensor using Free Pascal.
* [RaspberryPi-GPIOv2-FPC](https://github.com/RaspberryFpc/RaspberryPi-GPIOv2-FPC) – Fast Pascal unit for controlling GPIO pins via the Linux GPIO character device interface.
