#!/bin/bash

# A script to install Jellyfin Media Server and configure permissions.
# It sets up a shared group for media access and installs dependencies
# for Intel-based hardware transcoding (VA-API/QSV).

set -e -o pipefail

# --- Configuration ---
# Set the path to your media directory.
MEDIA_DIR="/mnt/Media"
# Set the name of the group that will have access to the media.
GROUP_NAME="mediaaccess"

# --- Functions ---

# 🔧 Enable and verify a systemd service
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
    # The current user running the script. Add more usernames here if needed.
    local current_user="$USER"

    echo "[*] Setting up group-based access for '$service_user' and '$current_user'..."

    # Create group if it doesn't exist
    if ! getent group "$GROUP_NAME" > /dev/null; then
        echo "[+] Creating group '$GROUP_NAME'..."
        sudo groupadd "$GROUP_NAME"
    fi

    # Add service user and current user to the media group
    for user in "$service_user" "$current_user"; do
        if ! id -nG "$user" | grep -qw "$GROUP_NAME"; then
            echo "[+] Adding '$user' to '$GROUP_NAME'..."
            sudo usermod -aG "$GROUP_NAME" "$user"
        fi
    done

    echo "[*] Setting ownership and permissions for $MEDIA_DIR..."
    # Set group ownership recursively
    sudo chown -R root:"$GROUP_NAME" "$MEDIA_DIR"

    # Set base permissions: 775 for directories, 664 for files
    sudo find "$MEDIA_DIR" -type d -exec chmod 775 {} +
    sudo find "$MEDIA_DIR" -type f -exec chmod 664 {} +

    # Set SGID on directories to ensure new files/folders inherit the group
    sudo find "$MEDIA_DIR" -type d -exec chmod g+s {} +

    # Set Access Control Lists (ACLs) for robust permissions
    # -R: recursive, -m: modify
    # This ensures members of the group can read/write/execute(X)
    sudo setfacl -R -m g:"$GROUP_NAME":rwX "$MEDIA_DIR"
    # -d: default ACLs
    # This ensures new items created in the directory get the correct group permissions
    sudo setfacl -d -m g:"$GROUP_NAME":rwX "$MEDIA_DIR"

    echo "[✓] Group permissions applied. You may need to log out and back in for changes to take effect."
}

# 📦 Install Jellyfin and configure hardware transcoding
install_jellyfin() {
    # This variable is set from /etc/os-release in main()
    echo "[*] Starting Jellyfin installation for OS: $ID..."

    if [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" || "$ID" == "debian" ]]; then
        # --- Debian, Ubuntu, & Mint ---
        local repo_distro="$ID"
        # Linux Mint uses the Ubuntu repositories
        [[ "$ID" == "linuxmint" ]] && repo_distro="ubuntu"
        
        sudo apt-get update
        sudo apt-get install -y curl gpg apt-transport-https ca-certificates
        
        curl -fssl "https://repo.jellyfin.org/${repo_distro}/jellyfin_team.gpg.key" | \
            sudo gpg --dearmor -o /usr/share/keyrings/jellyfin.gpg
        
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/${repo_distro} $(lsb_release -cs) main" | \
            sudo tee /etc/apt/sources.list.d/jellyfin.list
        
        sudo apt-get update
        echo "[*] Installing Jellyfin and Intel VAAPI/QSV packages..."
        sudo apt-get install -y jellyfin-server jellyfin-ffmpeg7 \
            intel-media-va-driver-non-free libvpl2

    elif [[ "$ID" == "arch" ]]; then
        # --- Arch Linux ---
        echo "[*] Installing Jellyfin and Intel VAAPI/QSV packages..."
        sudo pacman -Syu --noconfirm --needed \
            jellyfin-server jellyfin-ffmpeg jellyfin-web \
            intel-media-driver libvpl vpl-gpu-rt

    elif [[ "$ID" == "fedora" ]]; then
        # --- Fedora ---
        echo "[*] Adding Jellyfin repository..."
        sudo tee /etc/yum.repos.d/jellyfin.repo > /dev/null <<EOF
[Jellyfin]
name=Jellyfin Repository
baseurl=https://repo.jellyfin.org/releases/server/fedora/stable/
enabled=1
gpgcheck=1
gpgkey=https://repo.jellyfin.org/jellyfin_team.gpg.key
EOF
        echo "[*] Installing Jellyfin and Intel VAAPI/QSV packages..."
        sudo dnf install -y jellyfin-server jellyfin-ffmpeg \
            libva-intel-media-driver libvpl intel-vpl-gpu-rt
    else
        echo "[✗] Unsupported distro for Jellyfin: '$ID'"
        exit 1
    fi

    # --- Common Post-Installation Steps ---
    echo "[*] Adding 'jellyfin' user to hardware access groups ('render', 'video')..."
    for group in render video; do
        if getent group "$group" >/dev/null; then
            echo "[+] Adding jellyfin to group '$group'."
            sudo gpasswd -a jellyfin "$group"
        else
            echo "[!] Warning: Group '$group' not found. Skipping."
        fi
    done

    start_and_check_service jellyfin
    setup_media_group_access jellyfin
}

# 🚀 Script Entry Point
main() {
    if [ ! -f /etc/os-release ]; then
        echo "[✗] Cannot detect OS: /etc/os-release not found."
        exit 1
    fi

    # Source the os-release file to get the $ID variable
    # shellcheck source=/dev/null
    . /etc/os-release

    echo "[*] Detected OS: $PRETTY_NAME"
    install_jellyfin

    echo
    echo "🎉 Jellyfin installation complete!"
    echo "🔗 Access the web UI at: http://$(hostname -I | awk '{print $1'}):8096"
    echo "📁 Media directory is configured at: $MEDIA_DIR"
    echo "🔐 Remember to open port 8096 in your firewall for remote access."
}

# Execute the main function, passing all script arguments
main "$@"
