# UDP Audio Receiver for Raspberry Pi (FPC / Qt5 / X11)

This program receives audio data over UDP (e.g., RTP stream) and outputs it via ALSA. It was developed in Free Pascal using Codetyphon with Qt5 and runs under X11 on Debian Bookworm.

The program automatically detects whether packets are being received:
- If packets arrive → Audio is played.
- If no packets are received for 5 seconds → Audio output stops, window is hidden.

---

## 💠 Requirements

- Raspberry Pi with Debian Bookworm
- Codetyphon with Qt5 (e.g., qt5pas; GTK2 should work as well)
- ALSA installed
- Network connection for receiving UDP packets

---

## 🔧 Compilation

1. Ensure Codetyphon is installed and set up.
2. Open the project in Codetyphon.
3. Set the widgetset to `Qt5` (alternatively `gtk2`).
4. Compile.

Alternatively, via command line:
```bash
fpc -Mdelphi -Fu/path/to/qt5-units your_program.pas
```

---

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
./udp_audio_receiver
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

---

## 📁 Autostart

Create the file:
```bash
/home/pi/.config/autostart/UdpReceiver.desktop
```

With the following content:
```ini
[Desktop Entry]
Type=Application
Exec=/path/to/program/udp_audio_receiver
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Udp_Receiver
Comment=Automatically starts Udp_Receiver
Name[de_DE]=Udp_Receiver.desktop
```

Adjust path and filename accordingly.

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

**Author:** RaspberryPiFpcHub  
**GitHub:** https://github.com/RaspberryPiFpcHub

