#!/bin/bash

# ==================================================
# Configuration
# ==================================================
RECEIVER_IP="192.168.192.123"
RECEIVER_PORT="5010"

# ==================================================
# Start FFmpeg sender in terminal
# ==================================================
lxterminal -e /usr/bin/ffmpeg \
  -f pulse -i default \
  -acodec pcm_s16le \
  -f rtp \
  -pkt_size 736 \
  -fflags nobuffer \
  -flags low_delay \
  -max_delay 0 \
  -flush_packets 1 \
  rtp://${RECEIVER_IP}:${RECEIVER_PORT}
