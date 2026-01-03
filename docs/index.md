---
layout: default
title: Network Audio Receiver (UDP) for Raspberry Pi
description: Lightweight UDP stereo audio receiver for Raspberry Pi with very low latency via ALSA. Developed in Free Pascal on Debian Bookworm.
---

# 🎶 Network Audio Receiver (UDP) for Raspberry Pi

A lightweight **UDP stereo audio receiver** for Raspberry Pi.
It outputs directly to **ALSA** (also compatible with PipeWire using its ALSA bridge), ensuring **very low latency** – ideal for real-time monitoring and live audio.

---

## ✨ Features

* Receives **stereo audio over UDP** (e.g., RTP stream) with selectable audio output: 3.5 mm jack, HDMI, USB, and more (choose one device at a time)
* Direct **ALSA audio output** for minimal delay (PipeWire ALSA bridge supported)
* Developed in **Free Pascal** using **Codetyphon** on **Debian Bookworm**
* **No codec** → uncompressed audio, maximum quality, minimal processing delay
* On startup, the window is visible
* If the “Start Minimized” checkbox is selected, the application will start minimized
* Settings can be activated immediately without saving
* Separate settings window for device configuration

---

## ⚙️ Settings Overview (Form2)

| Control / Field | Description |
|-----------------|-------------|
| **Audio Output Selection** | Choose the audio output device (3.5 mm jack, HDMI, USB, etc.). If no configuration exists for a device, a default configuration is created automatically at program start. Only one device can be selected at a time. |
| **IP** | IP address to receive audio from. Use `0.0.0.0` to listen on all network interfaces. |
| **Port** | UDP port for incoming audio. Default is `5010`. |
| **Frequency** | Audio sample rate in Hz (e.g., 48000). |
| **Latency** | Audio latency in samples. Typical values: 22000 for JACK/Headphones, 3000 for USB audio. |
| **Swap Byte Order** | Enable this if the incoming audio uses a different byte order (big/little endian). |
| **Hide Window** | If enabled, the application window starts once audio starts. |
| **Activate** | Immediately applies the current settings without saving them. |
| **Save** | Saves the current settings to the configuration file for future use. |
| **Delete Device** | Deletes the selected device configuration. If the device exists, it will be recreated with default values at the next program start. |

---

## 💡 Example Test Setup

* **Sender**: Raspberry Pi 4 or Pi 5 streaming YouTube audio via Wi-Fi
* **Receiver**: Raspberry Pi 4 or Pi5 connected via Ethernet
* **Output**: 3.5 mm jack → HiFi amplifier, or HDMI/USB audio

Result: Stable low-latency playback on a typical home network, even while streaming video via RealVNC.

---

## 📥 Receiver

Start the player:

```bash
./udp_player
````

A window appears and starts playback automatically.
**Audio output selection:** If this is the first run or no previous configuration was selected, choose your desired audio output (3.5 mm jack, HDMI, USB, etc.) in the settings window.

---

## 📤 Sender (System Audio)

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

---

