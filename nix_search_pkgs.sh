#!/bin/bash

# List of packages to check
packages=(
    nmap
    ncat
    ndiff
    nping
    zenmap
    metasploit-framework
    wireshark
    tshark
    aircrack-ng
    gobuster
    dirb
    cowpatty
    whatweb
    wifite
    sqlmap
    hashcat
    john
    theharvester
    powershell
    sherlock
    autopsy
    maltego
    burpsuite
    hping3
    snort
    nikto
    wpscan
    responder
    beef-xss
    impacket-scripts
    netcat
    netcat-traditional
    dirbuster
    crunch
    openssl
    nuclei
    netdiscover
    ettercap
    tcpdump
    bloodhound
    bettercap
    steghide
    rkhunter
    macchanger
    eyewitness
    sqlsus
    legion
    foremost
    dmitry
    commix
    cewl
    amass
    netexec
    fern-wifi-cracker
    dvwa
    crackmapexec
    armitage
    spiderfoot
    socat
    sara
    recon-ng
    reaver
    pompem
    mdk3
    masscan
    hash-identifier
    ffuf
    evil-winrm
    dirsearch
    chkrootkit
    bully
    arping
    yersinia
    wifipumpkin3
    subfinder
    sparrow-wifi
    medusa
    lbd
    hoaxshell
    havoc
    enum4linux
    dnsenum
    capstone
    arpwatch
    yara
    wifiphisher
    testdisk
    sublist3r
    scapy
    rubeus
    mitmproxy
    mimikatz
    metagoofil
    ligolo-ng
    goldeneye
    ghidra
    dnstracer
    dnscat2
    crowbar
    chirp
    cadaver
    airgeddon
    zaproxy
)

# Function to check if a package exists in Nix
check_nix_package() {
    local pkg="$1"
    # Try different common naming patterns in Nix
    local nix_names=(
        "$pkg"
        "${pkg//-/_}"
        "${pkg//_/-}"
        "python3.${pkg#python3-}"
        "perl${pkg#perl-}"
    )
    
    for nix_name in "${nix_names[@]}"; do
        if nix search nixpkgs "$nix_name" 2>/dev/null | grep -q "legacyPackages"; then
            return 0
        fi
    done
    return 1
}

# Function to check all packages
check_all_packages() {
    local available=()
    local not_available=()
    
    echo "Checking packages in Nix repository..."
    echo "======================================"
    
    for pkg in "${packages[@]}"; do
        echo -n "Checking: $pkg"
        if check_nix_package "$pkg"; then
            echo " ✓ (Available)"
            available+=("$pkg")
        else
            echo " ✗ (Not available)"
            not_available+=("$pkg")
        fi
        sleep 0.1 # Small delay to avoid overwhelming the system
    done
    
    # Generate report
    echo ""
    echo "======================================"
    echo "SUMMARY REPORT"
    echo "======================================"
    echo "Total packages checked: ${#packages[@]}"
    echo "Available in Nix: ${#available[@]}"
    echo "Not available in Nix: ${#not_available[@]}"
    echo ""
    
    echo "AVAILABLE PACKAGES:"
    echo "==================="
    printf '%s\n' "${available[@]}" | sort
    echo ""
    
    echo "NOT AVAILABLE PACKAGES:"
    echo "======================="
    printf '%s\n' "${not_available[@]}" | sort
    echo ""
    
    # Save results to files
    printf '%s\n' "${available[@]}" | sort > available_packages.txt
    printf '%s\n' "${not_available[@]}" | sort > not_available_packages.txt
    
    echo "Results saved to:"
    echo "- available_packages.txt"
    echo "- not_available_packages.txt"
}

# Function to show quick stats
show_stats() {
    local available=()
    local not_available=()
    
    echo "Quick check (this may take a moment)..."
    for pkg in "${packages[@]}"; do
        if check_nix_package "$pkg"; then
            available+=("$pkg")
        else
            not_available+=("$pkg")
        fi
    done
    
    echo "Quick Stats:"
    echo "============"
    echo "Total packages: ${#packages[@]}"
    echo "Available in Nix: ${#available[@]}"
    echo "Not available in Nix: ${#not_available[@]}"
    echo "Availability rate: $(( (${#available[@]} * 100) / ${#packages[@]} ))%"
}

# Main menu
while true; do
    echo ""
    echo "Nix Package Availability Checker"
    echo "================================"
    echo "1. Check all packages (full scan)"
    echo "2. Show quick availability stats"
    echo "3. View package list"
    echo "4. Exit"
    echo ""
    read -p "Choose an option (1-4): " choice
    
    case $choice in
        1)
            check_all_packages
            ;;
        2)
            show_stats
            ;;
        3)
            echo "Packages to check (${#packages[@]} total):"
            echo "========================================"
            printf '%s\n' "${packages[@]}" | sort
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose 1-4."
            ;;
    esac
done
