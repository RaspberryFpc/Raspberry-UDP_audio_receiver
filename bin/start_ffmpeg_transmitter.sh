#!/bin/bash

lxterminal -e /usr/bin/ffmpeg -f pulse -i default -acodec pcm_s16le \
-f rtp -fflags nobuffer -flags low_delay -max_delay 0 \
-flush_packets 1 \
rtp://192.168.192.123:5010

