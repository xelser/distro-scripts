#!/bin/bash

# A script to configure Jellyfin Media Server permissions.
# It sets up a shared group for media access and prepares Jellyfin for hardware acceleration.

set -e -o pipefail

# --- Configuration ---
MEDIA_DIR="/mnt/Media"
GROUP_NAME="mediaaccess"

# --- Functions ---

# 🔍 Check if Jellyfin is installed
check_jellyfin_installed() {
    echo "[*] Checking if Jellyfin is installed..."

    # Check if jellyfin user exists
    if ! id -u jellyfin >/dev/null 2>&1; then
        echo "[✗] System user 'jellyfin' not found. Is Jellyfin installed?"
        exit 1
    fi

    echo "[✓] Jellyfin appears to be installed."
}

# 🔧 Enable and verify the jellyfin service
start_and_check_service() {
    local service_name="$1"
    echo "[*] Enabling and starting $service_name..."
    sudo systemctl enable --now "$service_name"

    echo "[*] Verifying $service_name status..."
    if systemctl is-active --quiet "$service_name"; then
        echo "[✓] $service_name is running."
    else
        echo "[✗] $service_name failed to start. Check logs with: sudo journalctl -u $service_name"
        exit 1
    fi
}

# 🔐 Set up shared group access to media directory
setup_media_group_access() {
    local service_user="$1"
    local current_user="$USER"

    echo "[*] Setting up group-based access for '$service_user' and '$current_user'..."

    if ! getent group "$GROUP_NAME" > /dev/null; then
        echo "[+] Creating group '$GROUP_NAME'..."
        sudo groupadd "$GROUP_NAME"
    fi

    for user in "$service_user" "$current_user"; do
        if ! id -nG "$user" | grep -qw "$GROUP_NAME"; then
            echo "[+] Adding '$user' to '$GROUP_NAME'..."
            sudo usermod -aG "$GROUP_NAME" "$user"
        fi
    done

    echo "[*] Setting ownership and permissions for $MEDIA_DIR..."
    sudo chown -R "$current_user":"$GROUP_NAME" "$MEDIA_DIR"
    sudo find "$MEDIA_DIR" -type d -exec chmod 775 {} +
    sudo find "$MEDIA_DIR" -type f -exec chmod 664 {} +
    sudo find "$MEDIA_DIR" -type d -exec chmod g+s {} +
    #sudo setfacl -R -m g:"$GROUP_NAME":rwX "$MEDIA_DIR"
    #sudo setfacl -d -m g:"$GROUP_NAME":rwX "$MEDIA_DIR"

    echo "[✓] Group permissions applied. You may need to log out and back in for changes to take effect."
}

# 🧩 Add Jellyfin user to hardware access groups
add_jellyfin_to_hw_groups() {
    echo "[*] Adding 'jellyfin' user to hardware access groups ('render', 'video')..."
    for group in render video; do
        if getent group "$group" >/dev/null; then
            echo "[+] Adding jellyfin to group '$group'."
            sudo gpasswd -a jellyfin "$group"
        else
            echo "[!] Warning: Group '$group' not found. Skipping."
        fi
    done
}

# 🚀 Script Entry Point
main() {
    echo "[*] Starting Jellyfin configuration..."

    check_jellyfin_installed
    add_jellyfin_to_hw_groups
    start_and_check_service jellyfin
    setup_media_group_access jellyfin

    echo
    echo "🎉 Jellyfin configuration complete!"
    echo "🔗 Access the web UI at: http://$(hostname -I | awk '{print $1'}):8096"
    echo "📁 Media directory is configured at: $MEDIA_DIR"
    echo "🔐 Remember to open port 8096 in your firewall for remote access."
}

main "$@"
