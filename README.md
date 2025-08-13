# UDP Audio Receiver for Raspberry Pi (FPC)

This program receives stereo audio data over UDP (e.g., RTP stream) and outputs it via ALSA. It was developed in Free Pascal using Codetyphon on Debian Bookworm

The program automatically detects whether packets are being received:
- If packets arrive → Audio is played.
- If no audio packets or only silent ones are received for 5 seconds → Audio output stops.
- For maximum quality, no codec is used – the audio is transmitted uncompressed.
- This allows for very low latency, making it ideal for real-time transmissions (e.g., monitoring, live audio).
- A separate settings form is now available.  
- The application window is now always visible.
- If the `Hide` checkbox is enabled the application is minimized at startup
- A startup file for an FFmpeg audio sender (StartFFmpegTransmitter.sh) is provided; when placed on the desktop, it can be started with a double-click.
---

## 💠 Requirements

- Raspberry Pi with Debian Bookworm
- Codetyphon 
- ALSA installed
- Network connection for receiving UDP packets


## ▶️ Usage

### 📤 Sender (System Audio)

The sender transmits system audio – everything normally played through the speaker.

If not yet installed, install `ffmpeg`:
```bash
sudo apt install ffmpeg
```

To transmit system audio use the provided statupfile StartFFmpegTransmitter.sh

- IP address of the receiver → replace with the correct address of your receiver.
- Port → can be freely selected, but must match the receiver’s configuration.
- If the file is placed on the desktop, the sender can be started by simply double-clicking the file.


### 📥 Receiver

Simply start the receiver:
```bash
./udp_player
```
A window will appear and automatically start playing audio when UDP packets are received.

---

## 🔊 If the audio is too quiet …

This may occur if the receiver volume is set too low.

### Possible solutions:
- Use `alsamixer`, press `F6` to select the correct device, and increase volume
- Or use the terminal:
  ```bash
  amixer set 'Master' 100% unmute
  ```

## 📝 License

This project is licensed under the MIT License.

