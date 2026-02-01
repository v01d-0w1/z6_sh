#!/bin/bash

read -p "project directory (~/opencode/): " requestedDir

ls ~/opencode/ | presentDir=()

for Dirloop in "${present-dir[@]}"; do
    if [ $Dirloop == requestedDir ]; then
        cd ~/opencode/requestedDir
    else
        read -p "do you want to create the directory (y/n): " choice
        if [ $choice == "y" ]; then
            mkdir ~/opencode/$requestedDir
            cd ~/opencode/$requestedDir
        fi
    fi
done
pwd

opencode
