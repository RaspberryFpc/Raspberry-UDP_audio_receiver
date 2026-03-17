 ---
layout: default
title: Network Audio Receiver (UDP) for Raspberry Pi
description: Lightweight UDP stereo audio receiver for Raspberry Pi with very low latency via ALSA and PipeWire. Developed in Free Pascal on Debian Bookworm.
---

# 🎶 Network Audio Receiver (UDP) for Raspberry Pi

A lightweight **UDP stereo audio receiver** for Raspberry Pi.  
It outputs directly to **ALSA** (also compatible with **PipeWire** via ALSA emulation), ensuring **very low latency** – ideal for real-time monitoring and live audio.

---

## ✨ Features

* Receives **stereo audio over UDP** (e.g., RTP stream) with selectable audio output: 3.5 mm jack, HDMI, USB, and more (choose one device at a time)
* Direct **ALSA audio output** for minimal delay
* Fully compatible with **PipeWire** via ALSA emulation
* Developed in **Free Pascal** using **Codetyphon** on **Debian Bookworm**
* **No codec** → uncompressed audio, maximum quality, minimal processing delay
* Supports multiple audio outputs: **3.5 mm jack, HDMI, USB, and more** (selectable in settings)
* On startup, the window is visible
* If the “Start Minimized” checkbox is selected, the application will start minimized
* **Lightweight** with minimal dependencies (ALSA or PipeWire via ALSA)

---

## 💡 Example Test Setup

* **Sender**: Raspberry Pi 4 or Pi 5 streaming audio over UDP
* **Receiver**: Raspberry Pi 4 or Pi 5 connected via Ethernet
* **Output**: 3.5 mm jack → HiFi amplifier, or HDMI/USB audio

Result: Stable low-latency playback on a typical home network, even while streaming video.

---

## ▶️ Usage

### 📤 Sender (System Audio)

Install `ffmpeg`:

```bash
sudo apt install ffmpeg
```

To transmit system audio, use the provided startup script **ffmpeg_transmitter.sh**:

1. Edit the script and replace the IP address with the address of your receiver.  
2. Set the port number to match the configuration on the receiver.  
3. Make the script executable:

```bash
chmod +x ffmpeg_transmitter.sh
```

4. Save the file, place it on the desktop, and start it with a double-click.

### 📥 Receiver

Start the player:

```bash
./udp_player
```

- The player **does not require sudo**, as the necessary capabilities (`cap_net_raw,cap_sys_nice+ep`) are set during installation.  
- On first start, it will create a **configuration file** at:

```
/var/lib/udp_player/udp_player.conf
```

- A window appears and starts playback automatically.  
- Select the desired audio output in the settings window.  
- Repeats the last valid audio block up to five times if new data is missing, preventing audible dropouts.

---

## ⚙️ Settings Description

Control / Field | Description
--- | ---
**Audio Output Selection** | Choose the audio output device (Headphones/JACK, HDMI, USB audio, etc.). If no configuration exists for a device, a default configuration is created automatically at first start.
**IP** | IP address to receive audio from. Use `0.0.0.0` to listen on all network interfaces.
**Port** | UDP port for incoming audio. Default is `5010`.
**Frequency** | Audio sample rate in Hz.
**Latency** | Audio latency in samples. Typical values: 28000 for JACK/Headphones, 4000 for USB audio.
**Swap Byte Order** | Enable this if the incoming audio uses a different byte order (big/little endian).
**Hide Window** | If enabled, the application window remains minimized or hidden once audio starts.
**Test changes** | This button immediately applies the current settings without saving them.
**Save changes** | This button saves the current settings to the configuration file for future use.
**Delete Device** | This button deletes the selected device configuration. If the device exists, it will be recreated with default values at the next program start.
**Volume** | Sets the output volume of the selected ALSA sound card in percent. This directly controls the hardware mixer (e.g. Master or PCM) of the selected device and ensures consistent volume levels,
 especially for USB audio devices with dynamic addressing.
---

## 🎯 Latency Optimization

* **Lower buffer size** → lower delay  
* **Too low** → possible dropouts or crackling audio  
* Best settings depend on:
  * Network type (**LAN** allows lower latency than Wi-Fi)
  * Raspberry Pi performance
  * Audio hardware

---

## 🔊 Audio Volume

If sound is too quiet:

You can adjust the ALSA output volume directly in the application settings.
A new parameter allows you to control the output volume of the selected ALSA sound card.

Alternatively, you can still use system tools for manual adjustment:


```bash
alsamixer
```

* Press `F6` to select the right device  
* Raise the **Master** volume  

Or via terminal:

```bash
amixer set 'Master' 100% unmute
```

---
# 📦 Installation / Deinstallation via dpkg

## Installation Steps

1. Copy the `.deb` package to your Raspberry Pi.

2. Install the package:

```bash
sudo dpkg -i udp_player_x.y.z.deb
```

This will install:

```
/usr/bin/udp_player         # Binary
/usr/share/applications/... # Desktop menu entry
~/.udp_player/              # Config folder (empty on first start)
```

Necessary capabilities are automatically set (`cap_net_raw,cap_sys_nice+ep`) → no sudo required for running the player.

3. Start the player:

```bash
udp_player 
or use the menu entry created during installation.
```

---

## Deinstallation Steps

To remove the player completely:

```bash
sudo dpkg -r udp_player
```

This removes the binary and the menu entry.

To also remove the config folder (if you want a clean uninstall):

```bash
rm -rf ~/.udp_player
```


## 📜 License

This project is licensed under the **MIT License**.

---

## 🌐 Other Projects by the Author

* [pibackup](https://github.com/RaspberryFpc/pibackup) – Portable live backup and restore tool with GUI, Zstandard compression, auto-shrinking (resize2fs) and flexible restore options.
* [DS18B20-FPC-Pi-GUI](https://github.com/RaspberryFpc/DS18B20-FPC-Pi-GUI) – GUI tool to read DS18B20 temperature sensors with linearization for high accuracy.
* [RaspberryPi-BME280-GUI](https://github.com/RaspberryFpc/RaspberryPi-BME280-GUI) – Complete GUI application for accessing the BME280 I²C sensor using Free Pascal.
* [RaspberryPi-GPIOv2-FPC](https://github.com/RaspberryFpc/RaspberryPi-GPIOv2-FPC) – Simple and fast Pascal unit for controlling GPIO pins via the Linux GPIO character device interface.
