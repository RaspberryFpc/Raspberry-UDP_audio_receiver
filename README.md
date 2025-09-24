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
* **Automatic detection** of incoming packets:
  * Packets arrive → audio plays instantly
  * No or silent packets for 5 seconds → audio output stops
* **No codec** → uncompressed audio, maximum quality, minimal processing delay
* Supports multiple audio outputs: **3.5 mm jack, HDMI, USB, and more** (selectable in settings)
* On startup, the window is visible
* If the “Start Minimized” checkbox is selected, the application will start minimized
* **Lightweight** with minimal dependencies (ALSA or PipeWire via ALSA)

---

## 💡 Example Test Setup

* **Sender**: Raspberry Pi 4 streaming YouTube audio via Wi-Fi
* **Receiver**: Raspberry Pi 4 connected via Ethernet
* **Output**: 3.5 mm jack → HiFi amplifier, or HDMI/USB audio

Result: Stable low-latency playback in a typical home network.

---

## ▶️ Usage

### 📤 Sender (System Audio)

Install `ffmpeg`:

```bash
sudo apt install ffmpeg
```

To transmit system audio, use the provided startup script **`StartFFmpegTransmitter.sh`**:

1. Edit the script and replace the IP address with the address of your receiver.
2. Set the port number to match the configuration on the receiver.
3. Make the script executable:

```bash
chmod +x StartFFmpegTransmitter.sh
```

4. Save the file, place it on the desktop, and start it with a double-click.

### 📥 Receiver

Start the player:

```bash
./udp_player
```

A window appears and starts playback automatically when UDP packets arrive. Select the desired audio output in the settings window.

**Silence Handling:**

* If no audio packets arrive for 5 seconds, ALSA stops and releases the output.
* Playback resumes automatically when new packets arrive.

---

## ⚙️ Settings Description

Control / Field | Description
--- | ---
**Audio Output Selection** | Choose the audio output device (Headphones/JACK, HDMI, USB audio, etc.). If no configuration exists for a device, a default configuration is created automatically at program start.
**IP** | IP address to receive audio from. Use `0.0.0.0` to listen on all network interfaces.
**Port** | UDP port for incoming audio. Default is `5010`.
**Network Buffer** | Size of the receive buffer in bytes. Must be at least as large as a single sent audio block.
**Frequency** | Audio sample rate in Hz.
**Latency** | Audio latency in samples. Typical values: 22000 for JACK/Headphones, 3000 for USB audio.
**Swap Byte Order** | Enable this if the incoming audio uses a different byte order (big/little endian).
**Hide Window** | If enabled, the application window remains minimized or hidden once audio starts.
**Test changes** | Immediately applies the current settings without saving them.
**Save changes** | Saves the current settings to the configuration file for future use.
**Delete** | Deletes the selected device configuration. If the device exists, it will be recreated with default values at the next program start.

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

## 📜 License

This project is licensed under the **MIT License**.

---

## 🌐 Other Projects by the Author

* [pibackup](https://github.com/RaspberryFpc/pibackup) – Portable live backup and restore tool with GUI, Zstandard compression, auto-shrinking (resize2fs) and flexible restore options.
* [DS18B20-FPC-Pi-GUI](https://github.com/RaspberryFpc/DS18B20-FPC-Pi-GUI) – GUI tool to read DS18B20 temperature sensors with linearization for high accuracy.
* [RaspberryPi-BME280-GUI](https://github.com/RaspberryFpc/RaspberryPi-BME280-GUI) – Complete GUI application for accessing the BME280 I²C sensor using Free Pascal.
* [RaspberryPi-GPIOv2-FPC](https://github.com/RaspberryFpc/RaspberryPi-GPIOv2-FPC) – Simple and fast Pascal unit for controlling GPIO pins via the Linux GPIO character device interface.
