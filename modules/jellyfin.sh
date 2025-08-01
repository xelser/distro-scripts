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
        sudo apt install -y jellyfin-server jellyfin-ffmpeg7

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

# 🚀 Entry point
main() {
    if [ ! -f /etc/os-release ]; then
        echo "[✗] Cannot detect OS. /etc/os-release not found."
        exit 1
    fi

    . /etc/os-release

    echo "[*] Detected OS: $PRETTY_NAME"
    echo "[*] Installing Jellyfin Media Server..."

    install_jellyfin

    echo
    echo "🎉 Jellyfin is installed!"
    echo "🔗 Web UI: http://localhost:8096/web"
    echo "📁 Media directory: $MEDIA_DIR"
    echo "🔐 Ensure port 8096 is open in your firewall for remote access."
}

main
