#!/bin/bash

sudo cp -r ~/.config/i3/* ~/z3
sudo cp -r ~/.config/qutebrowser/* ~/zute/
sudo cp -r ~/.config/nvim/* ~/zvim/
sudo cp -r ~/.tmux* ~/z_mux/
sudo cp -r ~/.config/polybar/* ~/zpoly/
sudo cp -r ~/.config/bat/* ~/zbat/

git_update(){
    path=$1
    cd /home/z6/$path
    git add . 
    git commit -m "initial"
    git push -u origin main
}

git_update "z3"
git_update "zute"
git_update "zvim"
git_update "z_mux/"
git_update "zpoly/"
git_update "zbat/"
git_update "z6_sh"
