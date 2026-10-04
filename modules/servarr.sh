#!/bin/bash
# Servarr host setup: mergerfs pool + fstab, Docker, Tailscale exit node.
# Jellyfin and the rest of the stack run in Docker Compose.
# Run as your normal user (not root). Uses sudo where needed.

set -euo pipefail

# ---------- Configuration ----------
MEDIA_DIR="/mnt/Orico"

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

# A fresh XFS root is owned by root, so containers running as your user cannot
# write to it. This must run AFTER the drives are mounted: before that, the
# paths are empty immutable folders on the root disk and chown would fail.
fix_media_permissions() {
	local uid gid n dir
	uid="$(id -u)"
	gid="$(id -g)"

	info "Setting ownership and permissions on the XFS drives (owner ${uid}:${gid})..."
	for n in 1 2 3 4 5; do
		dir="/mnt/Media${n}"
		if ! mountpoint -q "$dir"; then
			warn "$dir is not mounted. Skipping permissions for it."
			continue
		fi
		sudo chown -R "${uid}:${gid}" "$dir"
		sudo find "$dir" -type d -exec chmod 775 {} +
		sudo find "$dir" -type f -exec chmod 664 {} +
	done
	success "Drive permissions applied."
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

/mnt/Media* /mnt/Orico fuse.mergerfs defaults,allow_other,use_ino,cache.files=partial,dropcacheonclose=true,category.create=mspmfs,moveonenospc=true,minfreespace=20G,fsname=mergerfs,x-systemd.requires-mounts-for=/mnt/Media1,x-systemd.requires-mounts-for=/mnt/Media2,x-systemd.requires-mounts-for=/mnt/Media3,x-systemd.requires-mounts-for=/mnt/Media4,x-systemd.requires-mounts-for=/mnt/Media5 0 0
EOF
		fi

		info "Mounting drives..."
		sudo systemctl daemon-reload
		sudo mount -a || warn "mount -a reported errors. Check your drives and /etc/fstab."
		mountpoint -q "$MEDIA_DIR" \
			|| fail "$MEDIA_DIR is not mounted. Check the drive labels, then run: sudo mount -a"

		fix_media_permissions
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

				install_tailscale() {
					info "Installing Tailscale..."
					curl -fsSL https://tailscale.com/install.sh | sh
					success "Tailscale installed."
				}

				configure_network_for_exit_node() {
					info "Enabling IP forwarding..."
					# Written with tee (not tee -a) so re-running the script does not duplicate lines
					printf '%s\n' \
						'net.ipv4.ip_forward = 1' \
						'net.ipv6.conf.all.forwarding = 1' \
						| sudo tee /etc/sysctl.d/99-tailscale.conf > /dev/null
											sudo sysctl -p /etc/sysctl.d/99-tailscale.conf > /dev/null

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
	install_tailscale
	configure_network_for_exit_node

	# Last, because it waits for you to authenticate in the browser
	configure_tailscale

	echo
	echo "Setup complete."
	echo "Media directory: $MEDIA_DIR"
	echo
	echo "Next step: approve the exit node at admin.tailscale.com (Edit route settings)."

	prompt_reboot
}

main "$@"
