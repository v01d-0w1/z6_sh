#!/bin/bash

cd ~/Music/
for f in *.mp4; do ffmpeg -i "$f" -vn -ab 192k -ar 44100 -y "${f%.mp4}.mp3"; done
rm *.mp4

