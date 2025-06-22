#!/bin/bash

echo "                                                                                    "
echo "                                                                                    "
echo "                                                                                    "
echo "                     ▄████████    ▄█    █▄       ▄████████    ▄████████    ▄████████" 
echo "                    ███    ███   ███    ███     ███    ███   ███    ███   ███    ███" 
echo "                    ███    █▀    ███    ███     ███    █▀    ███    █▀    ███    █▀ "
echo "                    ███         ▄███▄▄▄▄███▄▄  ▄███▄▄▄       ███          ███       "
echo "                    ███        ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ▀███████████ ▀███████████" 
echo "                    ███    █▄    ███    ███     ███    █▄           ███          ███"  
echo "                    ███    ███   ███    ███     ███    ███    ▄█    ███    ▄█    ███" 
echo "                    ████████▀    ███    █▀      ██████████  ▄████████▀   ▄████████▀ " 
echo "                                                                                    "
echo "                                                                                    "
echo "                                                                                    "



echo "⬤➤ cli-chess   (1)"
echo "⬤➤ chess-cli   (2)"
echo "⬤➤ lichess-cli (3)"
echo "chose ┐"
read -p "      └➤ " num

if [ "$num" = 1 ]; then
    cli-chess
elif [ "$num" = 2 ]; then
    chess-cli play
elif [ "$num" = 3 ]; then
    lichess-cli 
else 
    echo "⨂ wrong output"
fi
