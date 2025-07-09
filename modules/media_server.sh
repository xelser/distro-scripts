#!/bin/bash

set -e

MEDIA_DIR="/mnt/Media"
GROUP_NAME="mediaaccess"

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

# 🔐 Set up shared group access to media directory
setup_media_group_access() {
    local service_user="$1"
    echo "[*] Setting up group-based access for $service_user..."

    if ! getent group "$GROUP_NAME" > /dev/null; then
        echo "[+] Creating group '$GROUP_NAME'..."
        sudo groupadd "$GROUP_NAME"
    fi

    sudo usermod -aG "$GROUP_NAME" "$service_user"
    sudo usermod -aG "$GROUP_NAME" xelser

    echo "[*] Applying group permissions to $MEDIA_DIR..."
    sudo chgrp -R "$GROUP_NAME" "$MEDIA_DIR"
    sudo chmod -R 775 "$MEDIA_DIR"
    sudo chmod g+s "$MEDIA_DIR"

    echo "[✓] Group permissions applied. You may need to reboot for group changes to take effect."
}

# 📦 Install Jellyfin
install_jellyfin() {
    echo "[*] Installing Jellyfin..."

    if [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]; then
        sudo apt install -y curl gnupg2 apt-transport-https ca-certificates
        curl -fsSL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key \
            | gpg --dearmor \
            | sudo tee /usr/share/keyrings/jellyfin.gpg > /dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu noble main" \
            | sudo tee /etc/apt/sources.list.d/jellyfin.list
        sudo apt update
        sudo apt install -y jellyfin-server jellyfin-ffmpeg7

    elif [[ "$ID" == "debian" ]]; then
        codename=$(lsb_release -cs)
        sudo apt install -y curl gnupg2 apt-transport-https ca-certificates
        curl -fsSL https://repo.jellyfin.org/debian/jellyfin_team.gpg.key \
            | gpg --dearmor \
            | sudo tee /usr/share/keyrings/jellyfin.gpg > /dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/debian $codename main" \
            | sudo tee /etc/apt/sources.list.d/jellyfin.list
        sudo apt update
        sudo apt install -y jellyfin-server jellyfin-ffmpeg

    elif [[ "$ID" == "arch" ]]; then
        if ! command -v yay &> /dev/null; then
            echo "[✗] 'yay' AUR helper not found. Please install it first."
            exit 1
        fi
        yay -S --noconfirm jellyfin jellyfin-ffmpeg

    elif [[ "$ID" == "fedora" ]]; then
        sudo tee /etc/yum.repos.d/jellyfin.repo > /dev/null <<EOF
[Jellyfin]
name=Jellyfin Repository
baseurl=https://repo.jellyfin.org/releases/server/fedora/stable/
enabled=1
gpgcheck=1
gpgkey=https://repo.jellyfin.org/jellyfin_team.gpg.key
EOF
        sudo dnf install -y jellyfin-server jellyfin-ffmpeg
    else
        echo "[✗] Unsupported distro for Jellyfin."
        exit 1
    fi

    start_and_check_service jellyfin
    setup_media_group_access jellyfin
}

# 📦 Install Plex
install_plex() {
    echo "[*] Installing Plex Media Server..."

    if [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" || "$ID" == "debian" ]]; then
        curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key \
            | gpg --dearmor \
            | sudo tee /usr/share/keyrings/plex.gpg > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" \
            | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
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
    setup_media_group_access plex
}

# 🚀 Entry point
main() {
    if [ ! -f /etc/os-release ]; then
        echo "[✗] Cannot detect OS. /etc/os-release not found."
        exit 1
    fi

    . /etc/os-release

    echo "[*] Detected OS: $PRETTY_NAME"
    echo "[*] Installing Jellyfin and Plex Media Server..."

    install_jellyfin
    install_plex

    echo
    echo "🎉 Both Jellyfin and Plex are installed!"
    echo "🔗 Jellyfin: http://localhost:8096/web"
    echo "🔗 Plex:     http://localhost:32400/web"
    echo "📁 Media directory: $MEDIA_DIR"
    echo "🔐 Ensure ports 8096 and 32400 are open in your firewall for remote access."
}

main

