#!/bin/bash

set -e

TRANSPARENT="#24a033"
TIME_BG="#000000"
DATE_BG="#004600"
VOLUME_BG="#006400"
BATTERY_BG="#009000"
WIFI_BG="#00b300"
FG="#ffffff"

echo "Creating /etc/i3blocks.conf..."
sudo tee /etc/i3blocks.conf > /dev/null <<EOF
separator=false
separator_block_width=0
markup=pango

[wifi]
command=/etc/i3blocks/scripts/wifi.sh
interval=10

[battery]
command=/etc/i3blocks/scripts/battery.sh
interval=30

[volume]
command=/etc/i3blocks/scripts/volume.sh
interval=1
signal=10

[date]
command=/etc/i3blocks/scripts/date.sh
interval=60

[time]
command=/etc/i3blocks/scripts/time.sh
interval=1
EOF

echo "Creating /etc/i3blocks/scripts/..."
sudo mkdir -p /etc/i3blocks/scripts

# WIFI (first block - no arrow)
sudo tee /etc/i3blocks/scripts/wifi.sh > /dev/null <<EOF
#!/bin/bash
interface=\$(iw dev | awk '/Interface/ {print \$2}' | head -n1)
if [ -z "\$interface" ]; then
    essid="Disconnected"
else
    essid=\$(iw dev "\$interface" link | grep SSID | cut -d" " -f2-)
fi
echo "<span foreground='$WIFI_BG' background='$TRANSPARENT'></span><span foreground='$FG' background='$WIFI_BG'>  \$essid </span>"
EOF

# BATTERY
sudo tee /etc/i3blocks/scripts/battery.sh > /dev/null <<EOF
#!/bin/bash
status=\$(acpi -b | awk '{print \$3}' | tr -d ",")
charge=\$(acpi -b | grep -oP "[0-9]+(?=%)")
icon=""
if [ "\$charge" -lt 20 ]; then icon=""
elif [ "\$charge" -lt 40 ]; then icon=""
elif [ "\$charge" -lt 60 ]; then icon=""
elif [ "\$charge" -lt 80 ]; then icon=""
else icon=""
fi
echo "<span foreground='$BATTERY_BG' background='$WIFI_BG'></span><span foreground='$FG' background='$BATTERY_BG'> \$icon \$status \$charge% </span>"
EOF

# VOLUME
sudo tee /etc/i3blocks/scripts/volume.sh > /dev/null <<EOF
#!/bin/bash
volume=\$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print \$5}' | head -n1)
mute=\$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print \$2}')
icon=""
if [ "\$mute" = "yes" ]; then icon=""; fi
echo "<span foreground='$VOLUME_BG' background='$BATTERY_BG'></span><span foreground='$FG' background='$VOLUME_BG'> \$icon \$volume </span>"
EOF

# DATE
sudo tee /etc/i3blocks/scripts/date.sh > /dev/null <<EOF
#!/bin/bash
echo "<span foreground='$DATE_BG' background='$VOLUME_BG'></span><span foreground='$FG' background='$DATE_BG'>  \$(date +'%a %d %b') </span>"
EOF

# TIME
sudo tee /etc/i3blocks/scripts/time.sh > /dev/null <<EOF
#!/bin/bash
echo "<span foreground='$TIME_BG' background='$DATE_BG'></span><span foreground='$FG' background='$TIME_BG'>  \$(date +'%H:%M:%S') </span>"
EOF

echo "Making scripts executable..."
sudo chmod +x /etc/i3blocks/scripts/*.sh

echo -e "\n✅ Setup complete! Reload i3 (Mod+Shift+R) and ensure your i3bar config includes:"
echo -e "\nbar {\n    status_command i3blocks\n    font pango:Hack Nerd Font 10\n    separator_symbol \"\"\n}\n"
