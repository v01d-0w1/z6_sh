#!/bin/bash
cd ~/invidious || exit

if docker compose ps --format json 2>/dev/null | grep -q '"Name":.*invidious.*"State":"running"'; then
    # Stop Invidious
    sudo docker compose down
    pkill -f "qutebrowser.*3000"
    notify-send "Invidious" "Stopped" -t 1000
else
    # Start Invidious
    sudo docker compose down
    sudo docker compose up & (setsid qutebrowser http://localhost:3000 >/dev/null 2>&1 &)
    notify-send "Invidious" "Starting..." -t 1000
    sleep 3
    
    # Launch qutebrowser in a completely detached way
fi

# Give it a moment to launch
sleep 1
exit
