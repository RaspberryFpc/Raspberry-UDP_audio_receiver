# Network Audio Receiver (UDP) for Raspberry Pi (FPC)

UDP network audio receiver for Raspberry Pi with very low latency via ALSA.

---

## ⚡ Quick Start

### Sender (System Audio)

1. Install ffmpeg:

```bash
sudo apt install ffmpeg
```

2. Edit the provided `StartFFmpegTransmitter.sh` script:

   * Replace the IP address with your receiver's IP.
   * Set the port number to match the receiver configuration.
3. Make the script executable:

```bash
chmod +x StartFFmpegTransmitter.sh
```

4. Place the script on the desktop and double-click to start transmitting.

### Receiver

1. Start the player:

```bash
./udp_player
```

2. The window will appear and start playback automatically when UDP packets are received.
3. Choose the audio output device in settings (3.5 mm jack, HDMI, USB, and more).

**Silence Handling:**

* If no audio packets arrive for 5 seconds, ALSA stops and releases the output.
* Playback resumes automatically when new packets arrive.

---

## ✨ Features

* UDP audio streaming with very low latency
* Uncompressed audio for maximum quality
* Automatic detection of incoming audio packets
* Silence handling with automatic ALSA release and re-initialization
* Selectable audio output (3.5 mm jack, HDMI, USB, and more)
* Adjustable latency per output device:
  * 3.5 mm jack ≈ 22000 (=22 ms)
  * USB audio stick ≈ 3000 (=3 ms)
* Start minimized option
* Separate settings window for configuration
* Startup script provided for FFmpeg sender

---

## 💠 Requirements

* Raspberry Pi running Debian Bookworm
* ALSA installed
* Network connection for receiving UDP packets

---

## 🧪 Test Setup

* **Sender**: Raspberry Pi 4 playing YouTube videos via Wi-Fi.
* **Receiver**: Another Raspberry Pi 4 connected via LAN.
* Receiver audio output connected to HiFi receiver (3.5 mm jack, HDMI, or USB).

---

## ▶️ Usage

Refer to the Quick Start section above.

**Audio Output Selection:**

* Choose your desired output device in settings.
* Supported outputs: 3.5 mm jack, HDMI, USB, and more.

**Silence Handling:**

* ALSA output stops after 5 seconds of no packets and restarts automatically when new packets arrive.

---

## 🎯 Optimization Notes

* **Lower buffer size** → lower audio delay
* **Too low** → possible dropouts or crackling audio
* **Best settings depend on:**

  * **Network type**: LAN generally allows lower latency than Wi-Fi
  * **Raspberry Pi performance**: CPU load affects real-time audio
  * **Audio hardware**: output device and drivers
  * **Network traffic**: heavy traffic may cause packet loss or jitter

**Approximate latency values per output device (1000 units = 1 ms):**

* 3.5 mm jack → \~22000 (=22 ms)
* USB audio stick → \~3000 (=3 ms)

---

## 🔊 If the audio is too quiet

* Use `alsamixer` (F6 to select device) and increase volume.
* Or via terminal:

```bash
amixer set 'Master' 100% unmute
```

---

## 📝 License

MIT License.

**Audio Output Update:**
Playback is now supported via 3.5 mm jack, HDMI, USB, and more. Select the desired device in the settings window.
