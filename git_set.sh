#!/bin/bash

echo "create <1> or update <2>"
read -p "choose:" state

echo "path of the repo(home/z6/your path)"
read path

if [ $state = 1 ]; then
    echo "url"
    read url
    cd /home/z6/$path
    
    # Initialize repo
    git init
    
    # Check and rename branch if needed
    current_branch=$(git branch --show-current 2>/dev/null || echo "master")
    if [ "$current_branch" = "master" ]; then
        git branch -m master main
    fi
    
    git add .
    git commit -m "Initial commit"
    git remote add origin $url
    git push -u origin main

elif [ $state = 2 ]; then
    cd /home/z6/$path
    
    git commit -m "Initial commit"

    # Check current branch and use appropriate name
    current_branch=$(git branch --show-current)
    if [ "$current_branch" = "master" ]; then
        git push -u origin master
    else
        git push -u origin main
    fi
else
    echo "wrong input"
fi
