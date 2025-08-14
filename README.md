 # UDP Audio Receiver for Raspberry Pi (FPC)

This program receives stereo audio data over UDP (e.g., RTP stream) and outputs it via ALSA. It was developed in Free Pascal using Codetyphon on Debian Bookworm

The program automatically detects whether packets are being received:
- If packets arrive → Audio is played.
- If no audio packets or only silent ones are received for 5 seconds → Audio output stops.
- For maximum quality, no codec is used – the audio is transmitted uncompressed.
- This allows for very low latency, making it ideal for real-time transmissions (e.g., monitoring, live audio).
- A separate settings form is now available.  
- The application window is now always visible.
- If the `Hide` checkbox is enabled the application is minimized at startup.
- A startup file for an FFmpeg audio sender (`StartFFmpegTransmitter.sh`) is provided; when placed on the desktop, it can be started with a double-click.

---

## 💠 Requirements

- Raspberry Pi with Debian Bookworm
- Codetyphon 
- ALSA installed
- Network connection for receiving UDP packets

---

## 🧪 Test Setup

The example test setup for development and verification was as follows:

- **Sender**: Raspberry Pi 4 playing YouTube videos in a browser, connected via **2.4 GHz Wi-Fi** to a router.
- **Receiver**: Another Raspberry Pi 4, connected via **Ethernet (LAN)** to the same router.
- The receiver’s **3.5 mm Jack audio output** was connected to a **HiFi receiver** for playback.

This setup demonstrated stable low-latency streaming under typical home network conditions.

---

## ▶️ Usage

### 📤 Sender (System Audio)

The sender transmits system audio – everything normally played through the speaker.

If not yet installed, install `ffmpeg`:
```bash
sudo apt install ffmpeg
```

To transmit system audio use the provided startup file `StartFFmpegTransmitter.sh`.

- IP address of the receiver → replace with the correct address of your receiver.
- Port → can be freely selected, but must match the receiver’s configuration.
- If the file is placed on the desktop, the sender can be started by simply double-clicking the file.

---

### 📥 Receiver

Simply start the receiver:
```bash
./udp_player
```
A window will appear and automatically start playing audio when UDP packets are received.

---

## 🎯 Optimization Notes

The audio latency is a **parameter of the receiver application** and can be set in its configuration.  

- **Lower latency values** → reduce the audio delay, improving real-time performance.  
- **Too low values** → may cause **sporadic audio dropouts**, depending on the connection type (Wi-Fi or LAN) and network stability.  
- **Extremely low values** → may result in **distorted / crackling audio** due to buffer underruns.  

The optimal setting depends on:
- Network quality and stability.
- Connection type (LAN generally allows lower latency than Wi-Fi).
- Performance of the Raspberry Pi and audio output hardware.

---

## 🔊 If the audio is too quiet …

This may occur if the receiver volume is set too low.

### Possible solutions:
- Use `alsamixer`, press `F6` to select the correct device, and increase volume
- Or use the terminal:
  ```bash
  amixer set 'Master' 100% unmute
  ```

---

## 📝 License

This project is licensed under the MIT License.
