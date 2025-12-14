#!/bin/bash

IP_Address_Receiver="192.168.192.123"
Port=5010

lxterminal -e /usr/bin/ffmpeg -f pulse -i default -acodec copy \
-f rtp -fflags nobuffer -flags low_delay -max_delay 0 \
-flush_packets 1 \
rtp://$IP_Address_Receiver:$Port
