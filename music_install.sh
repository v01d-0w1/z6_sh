#!/bin/bash

echo "url:"
read url

cd ~/Music/
~/app/yt-dlp_linux $url
~/z6_sh/mp4_to_mp3.sh
