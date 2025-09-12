#!/bin/bash

# List of packages
packages=(
    7zip CSFML NetworkManager OpenCL-Headers Thunar acpi aircrack-ng
    arc-theme autoconf autojump automake avahi base-system bat
    betterlockscreen blueman bluez bluez-alsa bridge-utils btop cargo
    cava cbonsai chrony clang clang-tools-extra clinfo cmake cmatrix
    coWPAtty cryptsetup curl dbus dialog dnsmasq dust feh figlet
    flameshot font-awesome font-hack-ttf fzf gcc gdb gimp git
    git-filter-repo git-lfs gnuchess go grub-i386-efi grub-x86-64-efi
    gvfs gvfs-afc gvfs-mtp hashcat hcxdumptool i3 i3blocks i3lock-color
    i3status jmtpfs john jp2a jq kitty light lightdm lightdm-gtk3-greeter
    lightdm-webkit2-greeter links linux lvm2 lxappearance make mdadm
    mesa-opencl meson mpc mpd mtools ncmpcpp neofetch network-manager-applet
    ninja nmap nnn openssl-devel papirus-icon-theme pavucontrol
    perl-AnyEvent-I3 picom pipes.c pixiewps pkg-config polybar preload
    pulseaudio python python3-adblock python3-pip python3-pipx qemu
    qutebrowser ranger reaver redshift rofi rsync rust smartmontools
    squashfs-tools stockfish syslinux termdown termshark thefuck
    thunar-archive-plugin thunar-volman timer-cli tlp tmux torbrowser-launcher
    tumbler upower vba-m viewnior virt-manager vlc void-docs-browse
    void-live-audio void-repo-nonfree wget wine winetricks wireless_tools
    xarchiver xclip xdotool xfce4-notifyd xorg xorriso xtools xwinwrap
    xz zathura zathura-pdf-mupdf
)

# Function to search local packages
search_local_packages() {
    local search_term="$1"
    echo "Searching local packages for: '$search_term'"
    echo "----------------------------------------"
    
    local found=0
    for pkg in "${packages[@]}"; do
        if [[ "$pkg" == *"$search_term"* ]]; then
            echo "✓ $pkg"
            found=1
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        echo "No local packages found matching '$search_term'"
    fi
}

# Function to search Nix packages
search_nix_packages() {
    local search_term="$1"
    echo "Searching Nix packages for: '$search_term'"
    echo "----------------------------------------"
    
    if command -v nix &> /dev/null; then
        nix search nixpkgs "$search_term" 2>/dev/null | head -20
        echo ""
        echo "Note: Showing first 20 results. Use 'nix search nixpkgs $search_term' for full results."
    else
        echo "Error: Nix package manager is not installed or not in PATH"
        echo "Install Nix from: https://nixos.org/download.html"
    fi
}

# Function to show all local packages
show_all_packages() {
    echo "All available local packages:"
    echo "----------------------"
    for pkg in "${packages[@]}"; do
        echo "• $pkg"
    done
    echo ""
    echo "Total local packages: ${#packages[@]}"
}

# Function to show package count
package_count() {
    echo "Total local packages available: ${#packages[@]}"
}

# Main menu
while true; do
    echo ""
    echo "Package Search Tool"
    echo "==================="
    echo "1. Search local packages"
    echo "2. Search Nix packages"
    echo "3. Show all local packages"
    echo "4. Show local package count"
    echo "5. Exit"
    echo ""
    read -p "Choose an option (1-5): " choice
    
    case $choice in
        1)
            read -p "Enter search term for local packages: " search_term
            search_local_packages "$search_term"
            ;;
        2)
            read -p "Enter search term for Nix packages: " search_term
            search_nix_packages "$search_term"
            ;;
        3)
            show_all_packages
            ;;
        4)
            package_count
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose 1-5."
            ;;
    esac
done
