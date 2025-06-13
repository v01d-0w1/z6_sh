#!/bin/bash
while true; do
    cpipes -c 00ca00 -p 1 &
    PID=$!
    sleep 60
    kill "$PID"
    clear
done
