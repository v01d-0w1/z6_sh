#!/bin/bash

# Check if picom is running as a daemon
if pgrep -x "picom" > /dev/null; then
    echo "picom is running, killing it..."
    pkill picom
    echo "picom has been terminated"
else
    echo "picom is not running, starting it as daemon..."
    picom --daemon
    echo "picom has been started"
fi
