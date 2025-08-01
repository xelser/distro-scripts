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

    # Create group if missing
    if ! getent group "$GROUP_NAME" > /dev/null; then
        echo "[+] Creating group '$GROUP_NAME'..."
        sudo groupadd "$GROUP_NAME"
    fi

    # Add users to group
    for user in "$service_user" xelser; do
        if ! id -nG "$user" | grep -qw "$GROUP_NAME"; then
            echo "[+] Adding $user to $GROUP_NAME..."
            sudo usermod -aG "$GROUP_NAME" "$user"
        fi
    done

    # Apply ownership & permissions
    echo "[*] Assigning group ownership to $MEDIA_DIR..."
    sudo chown -R :"$GROUP_NAME" "$MEDIA_DIR"

    echo "[*] Setting permissions on media files and folders..."
    sudo find "$MEDIA_DIR" -type f -exec chmod 664 {} +
    sudo find "$MEDIA_DIR" -type d -exec chmod 775 {} +
    sudo find "$MEDIA_DIR" -type d -exec chmod g+s {} +

    echo "[✓] Group permissions applied. Log out and back in for group changes to take effect."
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
    echo "[*] Installing Plex Media Server..."

    install_plex

    echo
    echo "🎉 Plex is installed!"
    echo "🔗 Web UI: http://localhost:32400/web"
    echo "📁 Media directory: $MEDIA_DIR"
    echo "🔐 Ensure port 32400 is open in your firewall for remote access."
}

main
