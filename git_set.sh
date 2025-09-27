#!/bin/bash

echo "create <1> or update <2>"

read -p "choose:" state

echo "path of the repo(home/z6/your path)"
read path

if [ $state = 1 ]; then

    echo "url"
    read url
    cd /home/z6/$path
    sudo git init
    sudo    git add .
    sudo     git commit -m "Main"
    sudo     git remote add origin $url
    sudo     git push -u origin main

elif [ $state = 2 ]; then

    cd /home/z6/$path
    sudo     git add . 
    sudo     git commit -m "Main"
    sudo     git push -u origin main
else
    echo "wrong input"
fi

