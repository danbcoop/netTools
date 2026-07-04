#!/usr/bin/bash
fn="$1"
ffmpeg -i "$fn" \
    -c:v libxvid -q:v 3 \
    -s 720x576 -r 25 \
    -c:a mp2 -b:a 192k \
    -f avi "$fn.avi"
#    -aspect 4:3 \
