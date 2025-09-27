#!/bin/bash
PID_FILE="/tmp/sleep-inhibitor.pid"

if [ -f "$PID_FILE" ]; then
    # Kill existing process
    kill $(cat "$PID_FILE") 2>/dev/null
    rm -f "$PID_FILE"
    notify-send "Sleep Mode" "✅ Enabled - System will sleep normally"
else
    # Start new process in background
    while true; do xdotool key Shift; sleep 59; done &
    echo $! > "$PID_FILE"
    notify-send "Sleep Mode" "❌ Disabled - Preventing system sleep"
fi
