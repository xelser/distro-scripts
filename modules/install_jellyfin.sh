#!/bin/bash

set -e

# 🔧 Enable and verify Jellyfin service
start_and_check_jellyfin() {
    echo "[*] Enabling and starting Jellyfin Media Server..."
    sudo systemctl enable --now jellyfin

    echo "[*] Verifying Jellyfin service status..."
    if systemctl is-active --quiet jellyfin; then
        echo "[✓] Jellyfin Media Server is running."
    else
        echo "[✗] Jellyfin failed to start. Check logs via: sudo journalctl -u jellyfin"
        exit 1
    fi
}

# 📦 Install Jellyfin on Ubuntu or Linux Mint
install_jellyfin_ubuntu() {
    echo "[+] Detected Ubuntu-based system..."

    echo "[*] Installing dependencies..."
    sudo apt install -y curl gnupg2 apt-transport-https ca-certificates

    echo "[*] Adding Jellyfin GPG key..."
    curl -fsSL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/jellyfin.gpg > /dev/null

    echo "[*] Adding Jellyfin APT repository for Ubuntu 24.04 (noble)..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu noble main" \
        | sudo tee /etc/apt/sources.list.d/jellyfin.list

    echo "[*] Installing Jellyfin server and FFmpeg..."
    sudo apt update
    sudo apt install -y jellyfin-server jellyfin-ffmpeg7

    start_and_check_jellyfin
}

# 📦 Install Jellyfin on Debian
install_jellyfin_debian() {
    echo "[+] Detected Debian-based system..."

    # Detect codename (e.g., bookworm, bullseye)
    codename=$(lsb_release -cs)

    echo "[*] Installing dependencies..."
    sudo apt install -y curl gnupg2 apt-transport-https ca-certificates

    echo "[*] Adding Jellyfin GPG key..."
    curl -fsSL https://repo.jellyfin.org/debian/jellyfin_team.gpg.key \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/jellyfin.gpg > /dev/null

    echo "[*] Adding Jellyfin APT repository for Debian ($codename)..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/debian $codename main" \
        | sudo tee /etc/apt/sources.list.d/jellyfin.list

    echo "[*] Installing Jellyfin server and FFmpeg..."
    sudo apt update
    sudo apt install -y jellyfin-server jellyfin-ffmpeg

    start_and_check_jellyfin
}

# 📦 Install Jellyfin on Arch Linux
install_jellyfin_arch() {
    echo "[+] Detected Arch-based system..."

    if ! command -v yay &> /dev/null; then
        echo "[✗] 'yay' AUR helper not found. Please install it first."
        exit 1
    fi

    echo "[*] Installing Jellyfin server and FFmpeg from AUR..."
    yay -S --noconfirm jellyfin jellyfin-ffmpeg

    start_and_check_jellyfin
}

# 📦 Install Jellyfin on Fedora
install_jellyfin_fedora() {
    echo "[+] Detected Fedora system..."

    echo "[*] Adding Jellyfin repository..."
    sudo tee /etc/yum.repos.d/jellyfin.repo > /dev/null <<EOF
[Jellyfin]
name=Jellyfin Repository
baseurl=https://repo.jellyfin.org/releases/server/fedora/stable/
enabled=1
gpgcheck=1
gpgkey=https://repo.jellyfin.org/jellyfin_team.gpg.key
EOF

    echo "[*] Installing Jellyfin server and FFmpeg..."
    sudo dnf install -y jellyfin-server jellyfin-ffmpeg

    start_and_check_jellyfin
}

# 🚀 Entry point
main() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|linuxmint)
                install_jellyfin_ubuntu
                ;;
            debian)
                install_jellyfin_debian
                ;;
            arch)
                install_jellyfin_arch
                ;;
            fedora)
                install_jellyfin_fedora
                ;;
            *)
                echo "[✗] Unsupported distribution: $ID"
                exit 1
                ;;
        esac
    else
        echo "[✗] Cannot detect OS. /etc/os-release not found."
        exit 1
    fi

    echo
    echo "🎬 Jellyfin Server is installed!"
    echo "🔗 Access it at: http://localhost:8096"
    echo "🔐 Ensure port 8096 is open in your firewall for remote access."
}

main

