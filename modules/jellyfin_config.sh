#!/bin/bash
# Configures Jellyfin Media Server permissions.
# Sets up a shared group for media access and prepares Jellyfin for hardware acceleration.

set -euo pipefail

# --- Configuration ---
MEDIA_DIR="/mnt/Media"
GROUP_NAME="mediaaccess"
JELLYFIN_USER="jellyfin"
HW_GROUPS=("render" "video")

# --- Logging Helpers ---
info()    { echo "[*] $*"; }
success() { echo "[✓] $*"; }
warn()    { echo "[!] $*"; }
fail()    { echo "[✗] $*"; exit 1; }

# --- Functions ---

check_jellyfin_installed() {
		info "Checking if Jellyfin is installed..."
		id -u "$JELLYFIN_USER" &>/dev/null \
				|| fail "System user '$JELLYFIN_USER' not found. Is Jellyfin installed?"
		success "Jellyfin is installed."
}

start_and_check_service() {
		local service="$1"
		info "Enabling and starting $service..."
		sudo systemctl enable --now "$service"

		info "Verifying $service status..."
		systemctl is-active --quiet "$service" \
				&& success "$service is running." \
				|| fail "$service failed to start. Check logs with: sudo journalctl -u $service"
}

setup_media_group_access() {
		local service_user="$1"
		local current_user="$USER"

		info "Setting up group-based access for '$service_user' and '$current_user'..."

		if ! getent group "$GROUP_NAME" &>/dev/null; then
				info "Creating group '$GROUP_NAME'..."
				sudo groupadd "$GROUP_NAME"
		fi

		for user in "$service_user" "$current_user"; do
				if ! id -nG "$user" | grep -qw "$GROUP_NAME"; then
						info "Adding '$user' to '$GROUP_NAME'..."
						sudo usermod -aG "$GROUP_NAME" "$user"
				fi
		done

		info "Setting ownership and permissions on $MEDIA_DIR..."
		sudo chown -R "$current_user:$GROUP_NAME" "$MEDIA_DIR"
		sudo find "$MEDIA_DIR" -type d -exec chmod 775 {} +
		sudo find "$MEDIA_DIR" -type f -exec chmod 664 {} +
		sudo find "$MEDIA_DIR" -type d -exec chmod g+s {} +

		# Uncomment to use ACLs instead:
		# sudo setfacl -R -m g:"$GROUP_NAME":rwX "$MEDIA_DIR"
		# sudo setfacl -d -m g:"$GROUP_NAME":rwX "$MEDIA_DIR"

		success "Group permissions applied. You may need to log out and back in for changes to take effect."
}

add_jellyfin_to_hw_groups() {
		info "Adding '$JELLYFIN_USER' to hardware access groups..."
		for group in "${HW_GROUPS[@]}"; do
				if getent group "$group" &>/dev/null; then
						info "Adding $JELLYFIN_USER to '$group'..."
						sudo gpasswd -a "$JELLYFIN_USER" "$group"
				else
						warn "Group '$group' not found. Skipping."
				fi
		done
}

# --- Entry Point ---

main() {
		info "Starting Jellyfin configuration..."

		check_jellyfin_installed
		start_and_check_service "$JELLYFIN_USER"
		setup_media_group_access "$JELLYFIN_USER"
		# add_jellyfin_to_hw_groups

		local host_ip
		host_ip=$(hostname -I | awk '{print $1}')

		echo
		echo "🎉 Jellyfin configuration complete!"
		echo "🔗 Web UI: http://$host_ip:8096"
		echo "📁 Media directory: $MEDIA_DIR"
		echo "🔐 Remember to open port 8096 in your firewall for remote access."
}

main "$@"
