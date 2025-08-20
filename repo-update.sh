#!/bin/bash

cp -r ~/.config/i3/* ~/z3
cp -r ~/.config/qutebrowser/* ~/zute/
cp -r ~/.config/nvim/* ~/zvim/
cp -r ~/.tmux* ~/z_mux/
cp -r ~/.config/polybar/* ~/zpoly/
cp -r ~/.config/bat/* ~/zbat/

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
