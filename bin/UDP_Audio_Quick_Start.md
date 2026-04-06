# DP Audio Streaming – Quick Start Guide

This guide explains how to start the UDP audio sender and how to install and use the UDP audio receiver with the provided `.deb` packages.

---

## Sender (Audio Transmitter)

Install the sender package:

```bash
sudo apt install /path/to/udp-sender.deb
```

Start the sender using the entry in the main menu.

In the settings, you can select the audio source, IP address, and port.

* The default IP address is `239.255.0.1` (multicast).
* To change the IP address:

  * For multicast: use an address in the range `224.0.0.0` – `239.255.255.255`.
  * For unicast (singlecast): use a free address in your local IPv4 network.

---

## Receiver (UDP Audio Player)

Install the receiver package:

```bash
sudo apt install /path/to/udp-player.deb
```

During installation:

* The binary is installed to `/usr/bin/udp_player`.
* A desktop menu entry is created.
* Required capabilities are set automatically (`cap_net_raw, cap_sys_nice+ep`), so the player can be started without `sudo`.



Start the receiver via the desktop menu entry.

### First start behavior

* A configuration file is created automatically.
* Default audio device settings are generated.
* Audio will play automatically when UDP packets arrive.

---

 ## Notes

* Sender and receiver port numbers must match.
* Multicast is used automatically if the IP address is in the range `224.0.0.0` – `239.255.255.255`.
* If you use unicast (singlecast), the receiver IP address should be `0.0.0.0` or the specific IP address used by the sender.
* For the lowest latency, use a USB audio device and, if possible, a wired (LAN) connection.
* The audio output device and volume can be configured in the receiver settings.

