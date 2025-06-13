#!/bin/bash

cd ~/Music/

#for f in *.mp4; do ffmpeg -i "$f" -vn -ab 192k -ar 44100 -y "${f%.mp4}.mp3"; done
shopt -s nocaseglob
for f in *.{mp4,mkv,avi,mov,webm,flv,wmv,m4a,wav,aac,ogg,flac}; do
  [ -f "$f" ] || continue
  ffmpeg -i "$f" -vn -ab 192k -ar 44100 -y "${f%.*}.mp3"
done
shopt -u nocaseglob

shopt -s extglob
rm -f !(*.mp3)

