#!/bin/bash
# Servarr host setup: mergerfs pool + fstab, Docker, Jellyfin (Intel QSV), Tailscale exit node, media permissions.
# Run as your normal user (not root). Uses sudo where needed.

set -euo pipefail

# ---------- Configuration ----------
MEDIA_DIR="/mnt/Orico"
GROUP_NAME="mediaaccess"
JELLYFIN_USER="jellyfin"
HW_GROUPS=("render" "video")

# ---------- Logging helpers ----------
info()    { echo "[*] $*"; }
success() { echo "[+] $*"; }
warn()    { echo "[!] $*"; }
fail()    { echo "[x] $*"; exit 1; }

# ---------- Functions ----------

preflight() {
	[ "$(id -u)" -ne 0 ] || fail "Run this as your normal user, not root, so group changes apply to you."
	command -v sudo &>/dev/null || fail "sudo is required."
}

install_base_packages() {
	info "Installing base packages..."
	sudo apt-get update
	sudo apt-get install -y ca-certificates curl gnupg ethtool xfsprogs \
		intel-media-va-driver-non-free libvpl2 libvpl-tools vainfo
			sudo install -m 0755 -d /etc/apt/keyrings
			success "Base packages installed."
		}

# Make an empty mountpoint immutable so nothing can be written to the root disk
# if the drive or pool is not mounted. Skipped when the path is already mounted.
protect_mountpoint() {
	local dir="$1"
	if mountpoint -q "$dir"; then
		return 0
	fi
	sudo chattr +i "$dir" 2>/dev/null \
		|| warn "Could not set immutable flag on $dir."
	}

	setup_storage() {
		info "Installing mergerfs..."
		sudo apt-get install -y mergerfs

		info "Creating mount points..."
		local n
		for n in 1 2 3 4 5; do
			sudo mkdir -p "/mnt/Media${n}"
			protect_mountpoint "/mnt/Media${n}"
			sudo blkid -L "Media${n}" &>/dev/null \
				|| warn "No filesystem labeled Media${n} found. Is the drive connected?"
			done
			sudo mkdir -p "$MEDIA_DIR"
			protect_mountpoint "$MEDIA_DIR"

			if grep -qE "# servarr.sh: media drives|[[:space:]]${MEDIA_DIR}[[:space:]]" /etc/fstab; then
				warn "fstab already has a $MEDIA_DIR or servarr.sh entry. Skipping. Edit /etc/fstab by hand if you want the new options."
			else
				info "Backing up /etc/fstab..."
				sudo cp /etc/fstab "/etc/fstab.bak.$(date +%Y%m%d%H%M%S)"

				info "Adding drives and mergerfs pool to /etc/fstab..."
				cat <<'EOF' | sudo tee -a /etc/fstab > /dev/null

# servarr.sh: media drives
# External HDDs
LABEL=Media1 /mnt/Media1 xfs defaults,noatime,logbsize=256k,allocsize=1m,nofail,x-systemd.device-timeout=10s 0 0
LABEL=Media2 /mnt/Media2 xfs defaults,noatime,logbsize=256k,allocsize=1m,nofail,x-systemd.device-timeout=10s 0 0
LABEL=Media3 /mnt/Media3 xfs defaults,noatime,logbsize=256k,allocsize=1m,nofail,x-systemd.device-timeout=10s 0 0
LABEL=Media4 /mnt/Media4 xfs defaults,noatime,logbsize=256k,allocsize=1m,nofail,x-systemd.device-timeout=10s 0 0
LABEL=Media5 /mnt/Media5 xfs defaults,noatime,logbsize=256k,allocsize=1m,nofail,x-systemd.device-timeout=10s 0 0

# mergerfs
/mnt/Media* /mnt/Orico fuse.mergerfs defaults,allow_other,use_ino,cache.files=partial,dropcacheonclose=true,category.create=mspmfs,moveonenospc=true,minfreespace=20G,fsname=mergerfs,x-systemd.requires-mounts-for=/mnt/Media1,x-systemd.requires-mounts-for=/mnt/Media2,x-systemd.requires-mounts-for=/mnt/Media3,x-systemd.requires-mounts-for=/mnt/Media4,x-systemd.requires-mounts-for=/mnt/Media5 0 0
EOF
			fi

			info "Mounting drives..."
			sudo systemctl daemon-reload
			sudo mount -a || warn "mount -a reported errors. Check your drives and /etc/fstab."
			mountpoint -q "$MEDIA_DIR" \
				|| fail "$MEDIA_DIR is not mounted. Check the drive labels, then run: sudo mount -a"
							success "mergerfs pool mounted at $MEDIA_DIR."
						}

						install_docker() {
							info "Installing Docker..."
							curl -fsSL https://download.docker.com/linux/debian/gpg \
								| sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
															sudo chmod a+r /etc/apt/keyrings/docker.gpg

															echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
																| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

															sudo apt-get update
															sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
																docker-buildx-plugin docker-compose-plugin

															sudo usermod -aG docker "$USER"
															success "Docker installed."
														}

														install_jellyfin() {
															info "Installing Jellyfin..."
															curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key \
																| sudo gpg --dearmor --yes -o /etc/apt/keyrings/jellyfin.gpg

															local version_os version_codename dpkg_arch
															version_os="$(awk -F'=' '/^ID=/{ print $NF }' /etc/os-release)"
															version_codename="$(awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release)"
															dpkg_arch="$(dpkg --print-architecture)"

															cat <<EOF | sudo tee /etc/apt/sources.list.d/jellyfin.sources > /dev/null
Types: deb
URIs: https://repo.jellyfin.org/${version_os}
Suites: ${version_codename}
Components: main
Architectures: ${dpkg_arch}
Signed-By: /etc/apt/keyrings/jellyfin.gpg
EOF

sudo apt-get update
sudo apt-get install -y jellyfin
sudo systemctl enable --now jellyfin
success "Jellyfin installed."
}

install_tailscale() {
	info "Installing Tailscale..."
	curl -fsSL https://tailscale.com/install.sh | sh
	success "Tailscale installed."
}

disable_transmission() {
	info "Disabling transmission-daemon (if present)..."
	if systemctl list-unit-files | grep -q '^transmission-daemon.service'; then
		sudo systemctl disable --now transmission-daemon
		success "transmission-daemon disabled."
	else
		warn "transmission-daemon not installed. Skipping."
	fi
}

configure_network_for_exit_node() {
	info "Enabling IP forwarding..."
	grep -qxF 'net.ipv4.ip_forward=1' /etc/sysctl.conf \
		|| echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf > /dev/null
			grep -qxF 'net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf \
				|| echo 'net.ipv6.conf.all.forwarding=1' | sudo tee -a /etc/sysctl.conf > /dev/null
							sudo sysctl -p > /dev/null

							local iface
							iface=$(ip route | awk '/^default/ {print $5; exit}')
							[ -n "$iface" ] || fail "Could not detect primary network interface."
							info "Detected interface: $iface"

							sudo ethtool -K "$iface" rx-udp-gro-forwarding on \
								|| warn "Could not enable UDP GRO forwarding on $iface (driver may not support it)."

	# Persist UDP GRO via NetworkManager dispatcher (only if NetworkManager is in use)
	if [ -d /etc/NetworkManager/dispatcher.d ]; then
		local dispatcher=/etc/NetworkManager/dispatcher.d/99-udp-gro
		info "Creating NetworkManager dispatcher script..."
		cat <<EOF | sudo tee "$dispatcher" > /dev/null
#!/bin/bash
if [ "\$1" = "$iface" ] && [ "\$2" = "up" ]; then
		ethtool -K $iface rx-udp-gro-forwarding on
fi
EOF
sudo chmod +x "$dispatcher"
else
	warn "NetworkManager dispatcher dir not found. UDP GRO will not persist across reboots."
	fi
	success "Network configured for exit node."
}

check_jellyfin_installed() {
	info "Checking Jellyfin user..."
	id -u "$JELLYFIN_USER" &>/dev/null \
		|| fail "System user '$JELLYFIN_USER' not found. Is Jellyfin installed?"
			success "Jellyfin user found."
		}

		start_and_check_service() {
			local service="$1"
			info "Enabling and starting $service..."
			sudo systemctl enable --now "$service"

			systemctl is-active --quiet "$service" \
				&& success "$service is running." \
				|| fail "$service failed to start. Check logs with: sudo journalctl -u $service"
			}

			setup_media_group_access() {
				local service_user="$1"
				local current_user="$USER"

				info "Setting up group access for '$service_user' and '$current_user'..."

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

	success "Group permissions applied."
}

add_jellyfin_to_hw_groups() {
	info "Adding '$JELLYFIN_USER' to hardware access groups..."
	for group in "${HW_GROUPS[@]}"; do
		if getent group "$group" &>/dev/null; then
			sudo gpasswd -a "$JELLYFIN_USER" "$group"
		else
			warn "Group '$group' not found. Skipping."
		fi
	done
}

configure_tailscale() {
	info "Configuring Tailscale (exit node + SSH)..."
	sudo tailscale up --advertise-exit-node --ssh
}

prompt_reboot() {
	echo
	read -r -p "Reboot now to apply group and network changes? [y/N] " answer
	case "$answer" in
		[yY]|[yY][eE][sS])
			info "Rebooting..."
			sudo systemctl reboot
			;;
		*)
			info "Skipping reboot. Reboot later with: sudo systemctl reboot"
			;;
	esac
}

# ---------- Entry point ----------

main() {
	info "Starting servarr setup..."

	preflight
	install_base_packages
	setup_storage
	install_docker
	install_jellyfin
	install_tailscale
	disable_transmission
	configure_network_for_exit_node

	check_jellyfin_installed
	start_and_check_service "$JELLYFIN_USER"
	setup_media_group_access "$JELLYFIN_USER"
	add_jellyfin_to_hw_groups
	sudo systemctl restart "$JELLYFIN_USER"

	# Last, because it waits for you to authenticate in the browser
	configure_tailscale

	local host_ip
	host_ip=$(hostname -I | awk '{print $1}')

	echo
	echo "Setup complete."
	echo "Jellyfin web UI: http://$host_ip:8096"
	echo "Media directory: $MEDIA_DIR"
	echo
	echo "Next step: approve the exit node at admin.tailscale.com (Edit route settings)."

	prompt_reboot
}

main "$@"
