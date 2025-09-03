# Network Audio Receiver (UDP) for Raspberry Pi (FPC)

UDP network audio receiver for Raspberry Pi with very low latency via ALSA.

The program automatically detects whether packets are being received:

- If packets arrive → audio is played.
- If no audio packets, or only silent packets, are received for 5 seconds → audio output stops.
- For maximum quality, no codec is used – the audio is transmitted uncompressed.
- This allows for very low latency, making it ideal for real-time transmissions (e.g., monitoring, live audio).
- A separate settings window is available.
- At startup, the receiver window is always visible. If the `Hide` checkbox is selected, the window is automatically hidden when audio packets are received and remains hidden.
- A startup script for an FFmpeg audio sender (`StartFFmpegTransmitter.sh`) is provided. Place it on the desktop and start it with a double-click.

---

## 💠 Requirements

- Raspberry Pi running Debian Bookworm
- ALSA installed
- Network connection for receiving UDP packets

---

## 🧪 Test Setup

Example setup used during development and verification:

- **Sender**: Raspberry Pi 4 playing YouTube videos in a browser, connected via **2.4 GHz Wi-Fi** to a router.
- **Receiver**: Another Raspberry Pi 4, connected via **Ethernet (LAN)** to the same router.
- Receiver’s **3.5 mm jack audio output** connected to a **HiFi receiver** for playback.

This setup demonstrated stable low-latency streaming under typical home network conditions.

---

## ▶️ Usage

### 📤 Sender (System Audio)

The sender transmits system audio – everything normally played through the speaker.

If not yet installed, install `ffmpeg`:
```bash
sudo apt install ffmpeg
```

To transmit system audio, use the provided startup file `StartFFmpegTransmitter.sh`:

- Replace the IP address with the correct address of your receiver.
- Select a port that matches the receiver configuration.
- Place the file on the desktop and start it with a double-click.

---

### 📥 Receiver

Start the receiver:
```bash
./udp_player
```

The receiver window will appear and automatically start playing audio when UDP packets are received.

---

## 🎯 Optimization Notes

Audio latency can be configured in the receiver application:

- **Lower latency values** → reduce audio delay, improving real-time performance.
- **Too low values** → may cause sporadic audio dropouts, depending on network type and stability.
- **Extremely low values** → may result in distorted or crackling audio due to buffer underruns.

Optimal settings depend on:

- Network quality and stability
- Connection type (LAN generally allows lower latency than Wi-Fi)
- Performance of the Raspberry Pi and audio output hardware

---

## 🔊 If the audio is too quiet

This may occur if the receiver volume is set too low.

### Possible solutions:

- Use `alsamixer`, press `F6` to select the correct device, and increase the volume
- Or via terminal:
```bash
amixer set 'Master' 100% unmute
```

---

## 📝 License

This project is licensed under the MIT License.
