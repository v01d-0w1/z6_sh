#!/bin/bash

echo "give the path to install:"
read path
echo "url:"
read url

cd $path
~/app/yt-dlp_linux $url