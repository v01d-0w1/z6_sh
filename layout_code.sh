#!/bin/bash

# Ask user for a workspace number (1–10)
read -p "Enter workspace number (1-10): " target_ws

# Validate input
if ! [[ "$target_ws" =~ ^[1-9]$|^10$ ]]; then
    echo "Invalid workspace number."
    exit 1
fi

# Switch to the specified workspace
i3-msg "workspace number $target_ws" >/dev/null

# Wait for workspace focus
for i in {1..10}; do
    focused_ws=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).num')
    if [[ "$focused_ws" == "$target_ws" ]]; then
        break
    fi
    sleep 0.1
done

if [[ "$focused_ws" != "$target_ws" ]]; then
    echo "Failed to switch to workspace $target_ws"
    exit 1
fi

# Apply layout
i3-msg "append_layout /home/z6/.i3/code.json" >/dev/null &

kitty -e nvim & 
sleep 2
kitty &
sleep 0.4
kitty --class=kitty -e cava &
sleep 0.4
kitty --class=kitty -e ~/.config/i3/scripts/play_media.sh &
