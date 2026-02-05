#!/bin/bash

echo "availabel project/directory:"
echo "============================"
ls -1 ~/opencode/

echo " "
read -p "project directory (~/opencode/): " requestedDir

presentDir=($(ls  ~/opencode/))
found=false

for Dirloop in "${presentDir[@]}"; do
    if [ "$Dirloop" == "$requestedDir" ]; then
        found=true
        break
    fi
done

if [ "$found" == true ]; then
    cd ~/opencode/"$requestedDir"
else
    read -p "do you want to create the directory (y/n): " choose
    if [ "$choose" = "y" ]; then
        mkdir ~/opencode/"$requestedDir"
    fi
fi

cd ~/opencode/"$requestedDir"

pwd

/home/linuxbrew/.linuxbrew/bin/opencode
