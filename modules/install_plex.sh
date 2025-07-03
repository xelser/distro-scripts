#!/bin/bash

set -e

# 🔧 Enable and verify Plex Media Server status
start_and_check_plex() {
    echo "[*] Enabling and starting Plex Media Server..."
    sudo systemctl enable --now plexmediaserver

    echo "[*] Verifying Plex Media Server status..."
    if systemctl is-active --quiet plexmediaserver; then
        echo "[✓] Plex Media Server is running."
    else
        echo "[✗] Plex Media Server failed to start."
        echo "    Check logs via: sudo journalctl -u plexmediaserver"
        exit 1
    fi
}

# 📦 Install Plex on Debian/Ubuntu/Mint
install_plex_debian() {
    echo "[+] Detected Debian-based system..."

    echo "[*] Adding Plex GPG key..."
    curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/plex.gpg > /dev/null

    echo "[*] Adding Plex APT repository..."
    echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" \
        | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

    echo "[*] Installing Plex Media Server..."
    sudo apt update
    sudo apt install -y plexmediaserver

    start_and_check_plex
}

# 📦 Install Plex on Arch Linux
install_plex_arch() {
    echo "[+] Detected Arch-based system..."

    if ! command -v yay &> /dev/null; then
        echo "[✗] 'yay' AUR helper not found. Please install it first."
        exit 1
    fi

    echo "[*] Installing Plex via AUR..."
    yay -S --noconfirm plex-media-server

    start_and_check_plex
}

# 📦 Install Plex on Fedora
install_plex_fedora() {
    echo "[+] Detected Fedora system..."

    echo "[*] Adding Plex YUM repository..."
    sudo tee /etc/yum.repos.d/plex.repo > /dev/null <<EOF
[Plexrepo]
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

# 🚀 Entry point
main() {
    if [ -f /etc/debian_version ]; then
        install_plex_debian
    elif [ -f /etc/arch-release ]; then
        install_plex_arch
    elif [ -f /etc/fedora-release ]; then
        install_plex_fedora
    else
        echo "[✗] Unsupported distribution. Manual installation required."
        exit 1
    fi

    echo
    echo "📺 Plex is installed!"
    echo "🔗 Access it at: http://localhost:32400/web"
    echo "🔐 Ensure port 32400 is open in your firewall for remote access."
}

main

