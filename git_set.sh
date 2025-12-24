#!/bin/bash

echo "create <1> or update <2>"

read -p "choose:" state

echo "path of the repo(home/z6/git_repo/your path)"
read path

if [ $state = 1 ]; then

    echo "url"
    read url
    cd /home/z6/git_repo/$path
    git init
    git add .
    git commit -m "Initial commit"
    git remote add origin $url
    git push -u origin main

elif [ $state = 2 ]; then

    cd /home/z6/$path
    git add . 
    git commit -m "initial"
    git push -u origin main
else
    echo "wrong input"
fi

