 ---

layout: default
title: Network Audio Receiver (UDP) for Raspberry Pi
description: Lightweight UDP stereo audio receiver for Raspberry Pi with very low latency via ALSA. Developed in Free Pascal on Debian Bookworm.
------------------------------------------------------------------------------------------------------------------------------------------------

# 🎶 Network Audio Receiver (UDP) for Raspberry Pi

A lightweight **UDP stereo audio receiver** for Raspberry Pi.
It outputs directly to **ALSA**, ensuring **very low latency** – ideal for real-time monitoring and live audio.

---

## ✨ Features

* Receives **stereo audio over UDP** (e.g., RTP stream)
* Direct **ALSA audio output** for minimal delay
* Developed in **Free Pascal** using **Codetyphon** on **Debian Bookworm**
* **Automatic detection** of incoming packets:

  * Packets arrive → audio plays instantly
  * No or silent packets for 5 seconds → audio output stops
* **No codec** → uncompressed audio, maximum quality, minimal processing delay
* Supports multiple audio outputs: **3.5 mm jack, HDMI, USB, and more** (selectable in settings)
* On startup, the window is visible
* If the “Start Minimized” checkbox is selected, the application will start minimized

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

## 🎯 Latency Optimization

Approximate latency values per output device (buffer size 1000 = 1 ms):

* **3.5 mm jack** → \~22000 (=22 ms)
* **USB audio stick** → \~3000 (=3 ms)

**Notes:**

* Lower buffer size → lower delay
* Too low → possible dropouts or crackling audio
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
