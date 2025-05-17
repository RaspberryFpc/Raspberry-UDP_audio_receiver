# UDP-Audio-Empfänger für Raspberry Pi (FPC / Qt5 / X11)

Dieses Programm empfängt Audio-Daten über UDP (z. B. RTP-Stream) und gibt sie über ALSA aus. Es wurde in Free Pascal unter Verwendung von Codetyphon mit Qt5 entwickelt und läuft unter X11 auf Debian Bookworm.

Das Programm erkennt automatisch, ob Pakete empfangen werden:
- Wenn Pakete ankommen → Audio wird abgespielt.
- Wenn 5 Sekunden lang keine Pakete empfangen werden → Audioausgabe wird gestoppt, Fenster wird ausgeblendet.

---

## 💠 Voraussetzungen

- Raspberry Pi mit Debian Bookworm
- ALSA installiert
- Netzwerkverbindung für den Empfang von UDP-Paketen

---

## 🔧 Kompilierung

1. Stelle sicher, dass Codetyphon eingerichtet ist.
2. Projekt in Codetyphon öffnen.
3. Kompilieren.

---

## ▶️ Verwendung

### 📤 Sender (Systemaudio)

Der Sender überträgt den System-Sound – also alles, was normalerweise über die Lautsprecher wiedergegeben wird.

Falls noch nicht vorhanden, `ffmpeg` installieren:
```bash
sudo apt install ffmpeg
```

Zur Übertragung vom Systemsound den Sender mit folgendem Befehl starten:
```bash
ffmpeg -f pulse -i default \
       -acodec copy -f rtp \
       -fflags nobuffer -flags low_delay \
       -max_delay 0 -flush_packets 1 \
       -rtbufsize 0 -avioflags direct \
       -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 1 \
       rtp://192.168.1.1:5010
```

- `192.168.1.1` ist die IP-Adresse des Empfängers → anpassen!
- `5010` ist die Portnummer → frei wählbar, muss mit Empfänger übereinstimmen

### 📥 Empfänger

Starte den Empfänger einfach:
```bash
./udp_audio_receiver
```

Es erscheint ein Fenster und beginnt automatisch mit der Audiowiedergabe, sobald UDP-Pakete empfangen werden.

---

## 🔊 Wenn der Ton zu leise ist …

Das kann passieren, wenn der Empfänger zu leise eingestellt ist.

### Möglichkeiten:
- In `alsamixer` mit `F6` das richtige Gerät wählen und Lautstärke anpassen
- Im Terminal:
  ```bash
  amixer set 'Master' 100% unmute
  ```

---

## 📁 Autostart

Erstelle die Datei:
```bash
/home/pi/.config/autostart/UdpReceiver.desktop
```

Mit folgendem Inhalt:
```ini
[Desktop Entry]
Type=Application
Exec=/pfad/zum/Programm/udp_audio_receiver
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Udp_Receiver
Comment=Startet Udp_Receiver automatisch
Name[de_DE]=Udp_Receiver.desktop
```

Pfad und Dateinamen entsprechend anpassen.

---

## 📝 Lizenz

Dieses Projekt steht unter der [MIT-Lizenz](LICENSE).

---

**Autor:** RaspberryPiFpcHub  
**GitHub:** https://github.com/RaspberryPiFpcHub

