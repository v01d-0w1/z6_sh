#!/bin/bash

set -e

CONFIG_DIR="$HOME/.config/polybar"
SCRIPTS_DIR="$CONFIG_DIR/scripts"

echo "Creating config directories..."
mkdir -p "$SCRIPTS_DIR"

echo "Writing scripts..."

cat > "$SCRIPTS_DIR/wifi.sh" << 'EOF'
#!/bin/bash

TRANSPARENT="#00000000"
WIFI_BG="#00cc4e"
FG="#ffffff"

interface=$(iw dev | awk '/Interface/ {print $2}' | head -n1)
if [ -z "$interface" ]; then
    essid="Disconnected"
else
    essid=$(iw dev "$interface" link | grep SSID | cut -d" " -f2-)
fi

arrow=""

echo "%{F$WIFI_BG}%{B$TRANSPARENT}$arrow%{B$WIFI_BG}%{F$FG}  $essid %{F-}%{B-}"
EOF

cat > "$SCRIPTS_DIR/battery.sh" << 'EOF'
#!/bin/bash

BATTERY_BG="#00d900"
WIFI_BG="#00cc4e"
FG="#ffffff"

status=$(acpi -b | awk '{print $3}' | tr -d ",")
charge=$(acpi -b | grep -oP "[0-9]+(?=%)")

icon=""
if [ "$charge" -lt 20 ]; then icon=""
elif [ "$charge" -lt 40 ]; then icon=""
elif [ "$charge" -lt 60 ]; then icon=""
elif [ "$charge" -lt 80 ]; then icon=""
else icon=""
fi

arrow=""

echo "%{F$BATTERY_BG}%{B$WIFI_BG}$arrow%{B$BATTERY_BG}%{F$FG} $icon $status $charge% %{F-}%{B-}"
EOF

cat > "$SCRIPTS_DIR/volume.sh" << 'EOF'
#!/bin/bash

VOLUME_BG="#00bd00"
BATTERY_BG="#00d900"
FG="#ffffff"

volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n1)
mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
icon=""
if [ "$mute" = "yes" ]; then icon=""; fi

arrow=""

echo "%{F$VOLUME_BG}%{B$BATTERY_BG}$arrow%{B$VOLUME_BG}%{F$FG} $icon $volume %{F-}%{B-}"
EOF

cat > "$SCRIPTS_DIR/date.sh" << 'EOF'
#!/bin/bash

DATE_BG="#009400"
VOLUME_BG="#00bd00"
FG="#ffffff"

arrow=""

echo "%{F$DATE_BG}%{B$VOLUME_BG}$arrow%{B$DATE_BG}%{F$FG}  $(date +'%a %d %b') %{F-}%{B-}"
EOF

cat > "$SCRIPTS_DIR/time.sh" << 'EOF'
#!/bin/bash

TIME_BG="#005e00"
DATE_BG="#009400"
FG="#ffffff"

arrow=""

echo "%{F$TIME_BG}%{B$DATE_BG}$arrow%{B$TIME_BG}%{F$FG}  $(date +'%H:%M:%S') %{F-}%{B-}"
EOF

echo "Making scripts executable..."
chmod +x "$SCRIPTS_DIR/"*.sh

echo "Writing polybar config..."

cat > "$CONFIG_DIR/config" << EOF
[colors]
transparent = #00000000
time_bg = #005e00
date_bg = #009400
volume_bg = #00bd00
battery_bg = #00d900
wifi_bg = #00cc4e
fg = #ffffff

[module/wifi]
type = custom/script
exec = $SCRIPTS_DIR/wifi.sh
interval = 10

[module/battery]
type = custom/script
exec = $SCRIPTS_DIR/battery.sh
interval = 30

[module/volume]
type = custom/script
exec = $SCRIPTS_DIR/volume.sh
interval = 1

[module/date]
type = custom/script
exec = $SCRIPTS_DIR/date.sh
interval = 60

[module/time]
type = custom/script
exec = $SCRIPTS_DIR/time.sh
interval = 1

[bar/mybar]
width = 100%
offset-y = 
height = 18          
modules-left =
modules-center =
modules-right = wifi battery volume date time
font-0 = "Hack Nerd Font:size=10;2"
background = #00000000
foreground = \${colors.fg}
EOF

echo -e "\n✅ Setup complete!\n"
echo "Run your bar with:"
echo "polybar mybar"
echo "To restart polybar:"
echo "killall -q polybar && polybar mybar &"

polybar mybar
