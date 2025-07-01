#!/bin/bash

set -e

start_and_check_plex() {
    echo "[*] Enabling and starting Plex Media Server..."
    sudo systemctl enable --now plexmediaserver

    echo "[*] Checking Plex service status..."
    if systemctl is-active --quiet plexmediaserver; then
        echo "[✓] Plex Media Server is running!"
    else
        echo "[✗] Plex Media Server failed to start. Check with: sudo journalctl -u plexmediaserver"
        exit 1
    fi
}

install_plex_debian() {
    echo "[+] Detected Debian/Ubuntu-based system."

    echo "[*] Downloading latest Plex .deb package..."
    TEMP_DEB=$(mktemp --suffix=.deb)
    curl -sL "https://downloads.plex.tv/plex-media-server-new/latest.deb" -o "$TEMP_DEB"

    echo "[*] Installing Plex Media Server..."
    sudo apt update
    sudo apt install -y curl gdebi-core
    sudo gdebi -n "$TEMP_DEB"

    rm "$TEMP_DEB"

    start_and_check_plex
}

install_plex_arch() {
    echo "[+] Detected Arch-based system."

    if ! command -v yay &>/dev/null; then
        echo "[!] Yay not found. Please install yay first."
        exit 1
    fi

    echo "[*] Installing Plex via AUR..."
    yay -S --noconfirm plex-media-server

    start_and_check_plex
}

install_plex_fedora() {
    echo "[+] Detected Fedora system."

    echo "[*] Adding Plex Media Server repository..."
    sudo tee /etc/yum.repos.d/plex.repo <<EOF >/dev/null
[Plex Media Server]
name=Plex Media Server
baseurl=https://downloads.plex.tv/repo/rpm/\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
EOF

    echo "[*] Installing Plex Media Server..."
    sudo dnf install -y plexmediaserver

    start_and_check_plex
}

main() {
    if [ -f /etc/debian_version ]; then
        install_plex_debian
    elif [ -f /etc/arch-release ]; then
        install_plex_arch
    elif [ -f /etc/fedora-release ]; then
        install_plex_fedora
    else
        echo "[✗] Unsupported distribution. Please install Plex manually."
        exit 1
    fi

    echo
    echo "📺 Access Plex at: http://localhost:32400/web"
    echo "🔐 If needed, open ports 32400 (HTTP) in your firewall."
}

main

