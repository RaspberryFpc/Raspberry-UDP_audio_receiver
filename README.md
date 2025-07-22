# UDP Audio Receiver for Raspberry Pi (FPC)

This program receives stereo audio data over UDP (e.g., RTP stream) and outputs it via ALSA. It was developed in Free Pascal using Codetyphon on Debian Bookworm

The program automatically detects whether packets are being received:
- If packets arrive → Audio is played.
- If no audio packets or only silent ones are received for 5 seconds → Audio output stops, window is hidden.
- For maximum quality, no codec is used – the audio is transmitted uncompressed.
- This allows for very low latency, making it ideal for real-time transmissions (e.g., monitoring, live audio).

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

To transmit system audio, start the sender with the following command:
```bash
ffmpeg -f pulse -i default \
       -acodec copy -f rtp \
       -fflags nobuffer -flags low_delay \
       -max_delay 0 -flush_packets 1 \
       -rtbufsize 0 -avioflags direct \
       -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 1 \
       rtp://192.168.1.1:5010
```

- `192.168.1.1` is the IP address of the receiver → adjust accordingly!
- `5010` is the port number → freely selectable, must match the receiver

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

