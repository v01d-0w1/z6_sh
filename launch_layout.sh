#!/bin/bash

echo "1.code"
echo "2.study"
read -p "choose:" choice

if [ $choice = 1 ]; then
    ~/z6_sh/layout_code.sh
elif [ $choice = 2 ]; then
    ~/z6_sh/layout_study_session.sh
else 
    echo "wrong choice"
fi
