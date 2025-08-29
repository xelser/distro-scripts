#!/bin/bash

set -e

MEDIA_DIR="/mnt/Media"

# 🔧 Enable and verify a systemd service
start_and_check_service() {
    local service_name="$1"
    echo "[*] Enabling and starting $service_name..."
    sudo systemctl enable --now "$service_name"

    echo "[*] Verifying $service_name status..."
    if systemctl is-active --quiet "$service_name"; then
        echo "[✓] $service_name is running."
    else
        echo "[✗] $service_name failed to start. Check logs via: sudo journalctl -u $service_name"
        exit 1
    fi
}

# 📦 Install Plex
install_plex() {
    echo "[*] Installing Plex Media Server..."

    if [[ "$ID" == "debian" ]]; then
        # Use the official Plex repository for Debian
        curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /usr/share/keyrings/plex.gpg > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list > /dev/null
        sudo apt update
        sudo apt install -y plexmediaserver

    elif [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]; then
        curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /usr/share/keyrings/plex.gpg > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
        sudo apt update
        sudo apt install -y plexmediaserver

    elif [[ "$ID" == "arch" ]]; then
        if ! command -v yay &> /dev/null; then
            echo "[✗] 'yay' AUR helper not found. Please install it first."
            exit 1
        fi
        yay -S --noconfirm plex-media-server

    elif [[ "$ID" == "fedora" ]]; then
        sudo tee /etc/yum.repos.d/plex.repo > /dev/null <<EOF
[Plexrepo]
name=Plex Media Server
baseurl=https://downloads.plex.tv/repo/rpm/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
EOF
        sudo dnf install -y plexmediaserver
    else
        echo "[✗] Unsupported distro for Plex."
        exit 1
    fi

    start_and_check_service plexmediaserver
}

# 🚀 Entry point
main() {
    if [ ! -f /etc/os-release ]; then
        echo "[✗] Cannot detect OS. /etc/os-release not found."
        exit 1
    fi

    . /etc/os-release

    echo "[*] Detected OS: $PRETTY_NAME"

    install_plex
    configure_plex

    echo
    echo "🎉 Plex is installed and configured!"
    echo "🔗 Web UI: http://localhost:32400/web"
    echo "📁 Media directory: $MEDIA_DIR"
    echo "🔐 Ensure port 32400 is open in your firewall for remote access."
}

main
