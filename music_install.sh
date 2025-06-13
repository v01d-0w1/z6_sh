#!/bin/bash

echo "url:"
read url

cd ~/Music/
~/app/yt-dlp_linux $url
~/mp4_to_mp3.sh
