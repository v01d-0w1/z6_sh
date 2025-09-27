#!/bin/bash
# clock-tui-foreground-alarms.sh

# Configuration
RINGTONE_FILE="$HOME/Music/jamtone.mp3"
CONFIG_DIR="$HOME/.config/clock-tui"
mkdir -p "$CONFIG_DIR"

# Try to find the clock binary (it's actually called 'tclock')
find_clock_binary() {
    if command -v tclock >/dev/null 2>&1; then
        echo "tclock"
        return 0
    fi
    if command -v clock-tui >/dev/null 2>&1; then
        echo "clock-tui"
        return 0
    fi
    return 1
}

CLOCK_BIN=$(find_clock_binary)

if [[ -z "$CLOCK_BIN" ]]; then
    echo "Error: Neither 'tclock' nor 'clock-tui' binary found!"
    exit 1
fi

echo "Found clock binary: $CLOCK_BIN"
sleep 2

ALARM_FILE="/tmp/clock_tui_alarms.$$"

# Load ringtone configuration
load_ringtone() {
    if [[ -f "$RINGTONE_FILE" ]]; then
        cat "$RINGTONE_FILE"
    else
        echo "classic"  # Default ringtone
    fi
}

# Save ringtone configuration
save_ringtone() {
    echo "$1" > "$RINGTONE_FILE"
}

cleanup() {
    rm -f "$ALARM_FILE"
    exit 0
}

trap cleanup EXIT INT TERM

# ASCII Art Headers
print_ascii_header() {
    local text="$1"
    case "${text^^}" in
        "ALARM MANAGEMENT")
            cat << "EOF"
    ╔═╗╦  ╦╔═╗╔╦╗╔═╗  ╔╦╗╔═╗╔╗╔╔╦╗╔═╗╔╦╗╦╔╗╔╔═╗
    ╠═╣╚╗╔╝║╣ ║║║║╣   ║║║╠═╣║║║ ║ ║╣ ║║║║║║║║ ╦
    ╩ ╩ ╚╝ ╚═╝╩ ╩╚═╝  ╩ ╩╩ ╩╝╚╝ ╩ ╚═╝╩ ╩╩╝╚╝╚═╝
EOF
            ;;
        "TCLOCK WITH ALARMS")
            cat << "EOF"
    ╔╦╗ ╔═╗╦  ╔═╗╔═╗╦ ╦  ╦╔╗╔╔═╗  ╔═╗╦  ╦╔═╗╔╦╗╔═╗╦╔═╗
     ║║╣ ║  ║ ║║ ║╚╦╝  ║║║║║ ║  ╠═╣╚╗╔╝║╣ ║║║║╣ ║╚═╗
    ═╩╝╚═╝╩═╝╚═╝╚═╝ ╩   ╩╝╚╝╚═╝  ╩ ╩ ╚╝ ╚═╝╩ ╩╚═╝╩╚═╝
EOF
            ;;
        "SET NEW ALARM")
            cat << "EOF"
    ╔═╗╔═╗╦  ╔═╗  ╔╗╔╔═╗╦ ╦  ╔═╗╦  ╦╔═╗╔╦╗╔═╗
    ╚═╗║╣ ║  ╠═╝  ║║║║ ║║║║  ╠═╣╚╗╔╝║╣ ║║║║╣ 
    ╚═╝╚═╝╩═╝╩    ╝╚╝╚═╝╚╩╝  ╩ ╩ ╚╝ ╚═╝╩ ╩╚═╝
EOF
            ;;
        "VIEW ACTIVE ALARMS")
            cat << "EOF"
    ╦╔╗╔╔═╗╦ ╦  ╔═╗ ╔═╗╦╔╦╗╔═╗╔╗╔╔═╗  ╔═╗╦  ╦╔═╗╔╦╗╔═╗╦╔═╗
    ║║║║║ ║║║║  ╠╣ ║║ ║║║║║║╣ ║║║║╣   ╠═╣╚╗╔╝║╣ ║║║║╣ ║╚═╗
    ╩╝╚╝╚═╝╚╩╝  ╚  ╚═╝╩╩ ╩╚═╝╝╚╝╚═╝  ╩ ╩ ╚╝ ╚═╝╩ ╩╚═╝╩╚═╝
EOF
            ;;
        "CANCEL ALARM")
            cat << "EOF"
    ╔═╗ ╔═╗╔╗╔╔═╗╔═╗╔═╗╦  ╔═╗  ╔═╗╦  ╦╔═╗╔╦╗╔═╗
    ║╣ ║ ║║║║║╣ ║╣ ║ ║║  ╠═╝  ╠═╣╚╗╔╝║╣ ║║║║╣ 
    ╚═╝╚═╝╝╚╝╚═╝╚═╝╚═╝╩═╝╩    ╩ ╩ ╚╝ ╚═╝╩ ╩╚═╝
EOF
            ;;
        "BACK TO CLOCK")
            cat << "EOF"
    ╔╗ ╔╗╔═╗╔╦╗╦ ╦  ╦╔╗╔  ╔═╗╦  ╦╔═╗╔═╗╦ ╦
    ╠╩╗║║║╣  ║ ╚╦╝  ║║║║  ║ ║║  ║║ ║║ ║╚╦╝
    ╚═╝╝╚╚═╝ ╩  ╩   ╩╝╚╝  ╚═╝╩═╝╩╚═╝╚═╝ ╩ 
EOF
            ;;
        "RINGTONE SETTINGS")
            cat << "EOF"
    ╦╔╗╔╔═╗╔╗╔╔═╗╔╦╗╦╔═╗╔╗╔  ╔═╗╔═╗╔═╗╔═╗╦  ╔═╗╔═╗
    ║║║║╠═╣║║║║╣  ║ ║║ ║║║║  ║╣ ╚═╗║╣ ║ ║║  ║╣ ╚═╗
    ╩╝╚╝╩ ╩╝╚╝╚═╝ ╩ ╩╚═╝╝╚╝  ╚═╝╚═╝╚═╝╚═╝╩═╝╚═╝╚═╝
EOF
            ;;
    esac
    echo ""
}

# Ringtone functions
play_classic_beep() {
    if command -v paplay >/dev/null 2>&1; then
        paplay <(sox -n -t wav - synth 0.3 sine 800 vol 0.4 2>/dev/null) 2>/dev/null &
    elif command -v aplay >/dev/null 2>&1; then
        aplay <(sox -n -t wav - synth 0.3 sine 800 vol 0.4 2>/dev/null) 2>/dev/null &
    else
        echo -e "\a"
    fi
}

play_chime() {
    if command -v paplay >/dev/null 2>&1; then
        # Pleasant chime sound
        paplay <(sox -n -t wav - synth 0.5 sine 523.25 vol 0.3 delay 0.1 sine 659.25 vol 0.3 2>/dev/null) 2>/dev/null &
    elif command -v aplay >/dev/null 2>&1; then
        aplay <(sox -n -t wav - synth 0.5 sine 523.25 vol 0.3 delay 0.1 sine 659.25 vol 0.3 2>/dev/null) 2>/dev/null &
    else
        echo -e "\a\a"
    fi
}

play_alert() {
    if command -v paplay >/dev/null 2>&1; then
        # Alert sound
        paplay <(sox -n -t wav - synth 0.2 sine 1000 vol 0.5 2>/dev/null) 2>/dev/null &
    elif command -v aplay >/dev/null 2>&1; then
        aplay <(sox -n -t wav - synth 0.2 sine 1000 vol 0.5 2>/dev/null) 2>/dev/null &
    else
        echo -e "\a\a\a"
    fi
}

play_bell() {
    if command -v paplay >/dev/null 2>&1; then
        # Church bell-like sound
        paplay <(sox -n -t wav - synth 0.6 sine 392 vol 0.4 2>/dev/null) 2>/dev/null &
    elif command -v aplay >/dev/null 2>&1; then
        aplay <(sox -n -t wav - synth 0.6 sine 392 vol 0.4 2>/dev/null) 2>/dev/null &
    else
        echo -e "\a"
    fi
}

play_digital() {
    if command -v paplay >/dev/null 2>&1; then
        # Digital beep
        paplay <(sox -n -t wav - synth 0.1 square 1200 vol 0.3 2>/dev/null) 2>/dev/null &
    elif command -v aplay >/dev/null 2>&1; then
        aplay <(sox -n -t wav - synth 0.1 square 1200 vol 0.3 2>/dev/null) 2>/dev/null &
    else
        echo -e "\a"
    fi
}

# Function to play alarm sound based on current ringtone
play_alarm_sound() {
    local ringtone=$(load_ringtone)
    
    case "$ringtone" in
        "classic") play_classic_beep ;;
        "chime") play_chime ;;
        "alert") play_alert ;;
        "bell") play_bell ;;
        "digital") play_digital ;;
        *) play_classic_beep ;;  # Default fallback
    esac
}

# Function to show ringtone settings
show_ringtone_settings() {
    local current_ringtone=$(load_ringtone)
    
    while true; do
        clear
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                                                                ║"
        print_ascii_header "RINGTONE SETTINGS"
        echo "║                                                                ║"
        echo "╠════════════════════════════════════════════════════════════════╣"
        echo "║                                                                ║"
        echo "║          Current ringtone: $current_ringtone                  ║"
        echo "║                                                                ║"
        echo "║          ┌────────────────────────────────────────────┐        ║"
        echo "║          │          1. Classic Beep                   │        ║"
        echo "║          └────────────────────────────────────────────┘        ║"
        echo "║                                                                ║"
        echo "║          ┌────────────────────────────────────────────┐        ║"
        echo "║          │          2. Chime                          │        ║"
        echo "║          └────────────────────────────────────────────┘        ║"
        echo "║                                                                ║"
        echo "║          ┌────────────────────────────────────────────┐        ║"
        echo "║          │          3. Alert                          │        ║"
        echo "║          └────────────────────────────────────────────┘        ║"
        echo "║                                                                ║"
        echo "║          ┌────────────────────────────────────────────┐        ║"
        echo "║          │          4. Bell                           │        ║"
        echo "║          └────────────────────────────────────────────┘        ║"
        echo "║                                                                ║"
        echo "║          ┌────────────────────────────────────────────┐        ║"
        echo "║          │          5. Digital                        │        ║"
        echo "║          └────────────────────────────────────────────┘        ║"
        echo "║                                                                ║"
        echo "║          ┌────────────────────────────────────────────┐        ║"
        echo "║          │          6. Test Sound                     │        ║"
        echo "║          └────────────────────────────────────────────┘        ║"
        echo "║                                                                ║"
        echo "║          ┌────────────────────────────────────────────┐        ║"
        echo "║          │          7. Back                           │        ║"
        echo "║          └────────────────────────────────────────────┘        ║"
        echo "║                                                                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -n "Choice [1-7]: "
        
        read -n1 choice
        echo ""
        
        case "$choice" in
            1) save_ringtone "classic"; current_ringtone="classic" ;;
            2) save_ringtone "chime"; current_ringtone="chime" ;;
            3) save_ringtone "alert"; current_ringtone="alert" ;;
            4) save_ringtone "bell"; current_ringtone="bell" ;;
            5) save_ringtone "digital"; current_ringtone="digital" ;;
            6) play_alarm_sound ;;
            7) break ;;
            *) 
                echo "Invalid choice!"
                sleep 1 
                ;;
        esac
    done
}

# Function to show alarm menu
show_alarm_menu() {
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    print_ascii_header "ALARM MANAGEMENT"
    echo "║                                                                ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                ║"
    echo "║          ┌────────────────────────────────────────────┐        ║"
    echo "║          │          1. SET NEW ALARM                  │        ║"
    echo "║          └────────────────────────────────────────────┘        ║"
    echo "║                                                                ║"
    echo "║          ┌────────────────────────────────────────────┐        ║"
    echo "║          │          2. VIEW ACTIVE ALARMS             │        ║"
    echo "║          └────────────────────────────────────────────┘        ║"
    echo "║                                                                ║"
    echo "║          ┌────────────────────────────────────────────┐        ║"
    echo "║          │          3. CANCEL ALARM                   │        ║"
    echo "║          └────────────────────────────────────────────┘        ║"
    echo "║                                                                ║"
    echo "║          ┌────────────────────────────────────────────┐        ║"
    echo "║          │          4. RINGTONE SETTINGS              │        ║"
    echo "║          └────────────────────────────────────────────┘        ║"
    echo "║                                                                ║"
    echo "║          ┌────────────────────────────────────────────┐        ║"
    echo "║          │          5. BACK TO CLOCK                  │        ║"
    echo "║          └────────────────────────────────────────────┘        ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -n "Choice [1-5]: "
}

# [Rest of the functions remain the same: set_alarm, view_alarms, cancel_alarm, check_alarms, trigger_alarm]

# Function to set alarm
set_alarm() {
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    print_ascii_header "SET NEW ALARM"
    echo "║                                                                ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                ║"
    echo "║    Format: HH:MM or +MINUTES                                  ║"
    echo "║    Examples: 14:30 or +15 (for 15 minutes from now)           ║"
    echo "║                                                                ║"
    echo "║    Alarm time:                                                 ║"
    echo "║    Alarm message:                                              ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    
    tput cup 8 18
    read alarm_input
    
    if [[ -z "$alarm_input" ]]; then
        return
    fi
    
    if [[ "$alarm_input" =~ ^\+([0-9]+)$ ]]; then
        local minutes=${BASH_REMATCH[1]}
        local alarm_time=$(date -d "+$minutes minutes" +%H:%M)
        local alarm_epoch=$(date -d "+$minutes minutes" +%s)
    elif [[ "$alarm_input" =~ ^([0-1][0-9]|2[0-3]):([0-5][0-9])$ ]]; then
        local alarm_time="$alarm_input"
        local today=$(date +%Y-%m-%d)
        local alarm_epoch=$(date -d "$today $alarm_time" +%s)
        local now_epoch=$(date +%s)
        
        if [[ $alarm_epoch -lt $now_epoch ]]; then
            alarm_epoch=$(date -d "tomorrow $alarm_time" +%s)
        fi
    else
        echo "Invalid time format!"
        sleep 2
        return
    fi
    
    tput cup 9 18
    read alarm_message
    alarm_message="${alarm_message:-Alarm!}"
    
    echo "$alarm_epoch|$alarm_time|$alarm_message" >> "$ALARM_FILE"
    
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║                    ALARM SET SUCCESSFULLY                     ║"
    echo "║                                                                ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                ║"
    echo "║            Time: $alarm_time                                  ║"
    echo "║            Message: $alarm_message                            ║"
    echo "║            Ringtone: $(load_ringtone)                         ║"
    echo "║                                                                ║"
    echo "║                    Press any key to continue                  ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    read -n1 -s
}

# Function to view alarms
view_alarms() {
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    print_ascii_header "VIEW ACTIVE ALARMS"
    echo "║                                                                ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                ║"
    
    if [[ ! -f "$ALARM_FILE" ]] || [[ ! -s "$ALARM_FILE" ]]; then
        echo "║                    No active alarms                          ║"
    else
        local count=1
        local now=$(date +%s)
        while IFS='|' read -r epoch time message; do
            local seconds_left=$((epoch - now))
            local minutes_left=$((seconds_left / 60))
            if [[ $seconds_left -gt 0 ]]; then
                printf "║    %2d. %s - %-25s (%3d minutes)    ║\n" "$count" "$time" "$message" "$minutes_left"
                ((count++))
            fi
        done < "$ALARM_FILE"
    fi
    
    echo "║                                                                ║"
    echo "║                    Press any key to continue                  ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    read -n1 -s
}

# Function to cancel alarm
cancel_alarm() {
    view_alarms
    if [[ ! -f "$ALARM_FILE" ]] || [[ ! -s "$ALARM_FILE" ]]; then
        return
    fi
    
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    print_ascii_header "CANCEL ALARM"
    echo "║                                                                ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                ║"
    echo "║          Enter alarm number to cancel:                        ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    
    tput cup 6 38
    read alarm_num
    
    if [[ "$alarm_num" =~ ^[0-9]+$ ]]; then
        local temp_file=$(mktemp)
        local count=1
        while IFS='|' read -r epoch time message; do
            if [[ $count -ne $alarm_num ]]; then
                echo "$epoch|$time|$message" >> "$temp_file"
            else
                echo "Cancelled alarm: $time - $message"
            fi
            ((count++))
        done < "$ALARM_FILE"
        mv "$temp_file" "$ALARM_FILE"
    fi
    sleep 2
}

# Function to check and trigger alarms
check_alarms() {
    if [[ ! -f "$ALARM_FILE" ]]; then
        return 0
    fi
    
    local now=$(date +%s)
    local temp_file=$(mktemp)
    local alarm_triggered=0
    
    while IFS='|' read -r epoch time message; do
        if [[ $now -ge $epoch ]]; then
            alarm_triggered=1
            trigger_alarm "$message"
        else
            echo "$epoch|$time|$message" >> "$temp_file"
        fi
    done < "$ALARM_FILE"
    
    mv "$temp_file" "$ALARM_FILE"
    return $alarm_triggered
}

# Function to trigger alarm
trigger_alarm() {
    local message="$1"
    
    for i in {1..10}; do
        clear
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                                                                ║"
        echo "║                        ╔═══════════╗                          ║"
        echo "║                        ║   ALARM!  ║                          ║"
        echo "║                        ╚═══════════╝                          ║"
        echo "║                                                                ║"
        printf "║                     %-30s           ║\n" "$message"
        echo "║                                                                ║"
        printf "║                         Ringing: %d/10                       ║\n" "$i"
        echo "║                                                                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        
        if [[ $((i % 2)) -eq 1 ]]; then
            play_alarm_sound
        fi
        sleep 1
    done
    
    echo "Press any key to continue..."
    read -n1 -s
}

# Main interactive loop
main() {
    while true; do
        if check_alarms; then
            clear
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║                                                                ║"
            print_ascii_header "TCLOCK WITH ALARMS"
            echo "║                                                                ║"
            echo "╠════════════════════════════════════════════════════════════════╣"
            echo "║                                                                ║"
            echo "║          ┌────────────────────────────────────────────┐        ║"
            echo "║          │               C - Show TClock              │        ║"
            echo "║          └────────────────────────────────────────────┘        ║"
            echo "║                                                                ║"
            echo "║          ┌────────────────────────────────────────────┐        ║"
            echo "║          │               A - Alarm Management         │        ║"
            echo "║          └────────────────────────────────────────────┘        ║"
            echo "║                                                                ║"
            echo "║          ┌────────────────────────────────────────────┐        ║"
            echo "║          │               Q - Quit                     │        ║"
            echo "║          └────────────────────────────────────────────┘        ║"
            echo "║                                                                ║"
            echo "╚════════════════════════════════════════════════════════════════╝"
            echo -n "Choice [C/A/Q]: "
            
            read -n1 choice
            echo ""
            
            case "$choice" in
                c|C)
                    echo "Starting TClock... (Press 'q' to return to menu)"
                    "$CLOCK_BIN"
                    ;;
                a|A)
                    while true; do
                        show_alarm_menu
                        read -n1 choice
                        echo ""
                        case "$choice" in
                            1) set_alarm ;;
                            2) view_alarms ;;
                            3) cancel_alarm ;;
                            4) show_ringtone_settings ;;
                            5) break ;;
                            *) 
                                clear
                                echo "╔════════════════════════════════════════════════════════════════╗"
                                echo "║                                                                ║"
                                echo "║                      Invalid choice!                          ║"
                                echo "║                      Press any key...                         ║"
                                echo "║                                                                ║"
                                echo "╚════════════════════════════════════════════════════════════════╝"
                                read -n1 -s 
                                ;;
                        esac
                    done
                    ;;
                q|Q)
                    echo "Goodbye!"
                    exit 0
                    ;;
                *)
                    clear
                    echo "╔════════════════════════════════════════════════════════════════╗"
                    echo "║                                                                ║"
                    echo "║                      Invalid choice!                          ║"
                    echo "║                      Press any key...                         ║"
                    echo "║                                                                ║"
                    echo "╚════════════════════════════════════════════════════════════════╝"
                    read -n1 -s
                    ;;
            esac
        fi
        sleep 1
    done
}

main
