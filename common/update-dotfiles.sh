#!/bin/bash
# backup-dotfiles.sh
# Backs up dotfiles, DE/WM configs, and system settings
# Supports: Arch, Linux Mint, Fedora (and others)

set -euo pipefail

# --- Configuration ---
SCRIPTS_DIR="$HOME/Documents/distro-scripts"
COMMON_DIR="$SCRIPTS_DIR/common"
DOTFILES_DIR="$SCRIPTS_DIR/dotfiles"

DISTRO_ID="$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')"

# --- Logging ---
info()    { echo "  [*] $*"; }
success() { echo "  [✓] $*"; }
warn()    { echo "  [!] $*"; }
section() { echo; echo "==> $*"; }

# --- Detect WM / DE ---
get_wm_de() {
		local wm_de=""
		if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
				wm_de="$(echo "$XDG_CURRENT_DESKTOP" | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
		elif [[ -n "${DESKTOP_SESSION:-}" ]]; then
				wm_de="$(echo "$DESKTOP_SESSION" | tr '[:upper:]' '[:lower:]')"
		fi
		echo "$wm_de"
}

WM_DE="$(get_wm_de)"

# Known DEs get a distro-de folder, everything else is treated as a WM
KNOWN_DES=("gnome" "cinnamon" "xfce" "kde")
is_known_de() {
		local env="$1"
		for de in "${KNOWN_DES[@]}"; do
				[[ "$env" == "$de" ]] && return 0
		done
		return 1
}

if is_known_de "$WM_DE"; then
		DEST_DIR="$DOTFILES_DIR/${DISTRO_ID}-${WM_DE}"
else
		DEST_DIR="$DOTFILES_DIR/${DISTRO_ID}"
fi

# --- Helpers ---

# Copy a single file from $HOME into DEST_DIR, preserving relative path
save_file() {
		local rel_path="$1"
		local src="$HOME/$rel_path"
		local dest="$DEST_DIR/$(dirname "$rel_path")"
		if [[ -f "$src" ]]; then
				mkdir -p "$dest"
				cp -f "$src" "$dest"
		fi
}

# Copy a directory from $HOME into DEST_DIR, preserving relative path
save_folder() {
		local rel_path="${1%/}"
		local src="$HOME/$rel_path"
		local dest="$DEST_DIR/$rel_path"
		if [[ -d "$src" ]]; then
				mkdir -p "$dest"
				cp -rf "$src/." "$dest"
		fi
}

# Dump a dconf path to a file under DEST_DIR
dconf_dump() {
		local dconf_path="$1"
		local dest_rel="$2"
		local dest_file="$DEST_DIR/$dest_rel"
		mkdir -p "$(dirname "$dest_file")"
		dconf dump "$dconf_path" > "$dest_file" 2>/dev/null
}

# Remove Qt/GTK clutter that DEs don't need backed up
remove_clutter() {
		rm -rf "$DEST_DIR/.config/Kvantum/"
		rm -rf "$DEST_DIR/.config/qt5ct/"
		[[ "$WM_DE" == "cinnamon" ]] && rm -rf "$DEST_DIR/.config/gtk-3.0/"
}

# Save files from an array of relative paths
save_files() {
		local -n _files="$1"
		for f in "${_files[@]}"; do
				[[ "$f" == \#* ]] && continue
				save_file "$f"
		done
}

# Save folders from an array of relative paths
save_folders() {
		local -n _folders="$1"
		for d in "${_folders[@]}"; do
				[[ "$d" == \#* ]] && continue
				save_folder "$d"
		done
}

# --- Section: Shell ---
backup_shell() {
		section "Shell"
		mkdir -p "$COMMON_DIR"
		for f in .bash_aliases .bash_profile; do
				[[ -f "$HOME/$f" ]] && cp -f "$HOME/$f" "$COMMON_DIR/${f#.}" && info "$f"
		done
}

# --- Section: Desktop Environments & Window Managers ---
backup_de_wm() {
		section "Desktop Environment / Window Manager: ${WM_DE:-unknown}"
		mkdir -p "$DEST_DIR"

		case "$WM_DE" in
				xfce)
						save_file ".config/menus/xfce-applications.menu"
						xfce4-panel-profiles save "$HOME/.config/xfce4-panel-backups/my-panel.tar.bz2" 2>/dev/null
						save_file ".config/xfce4-panel-backups/my-panel.tar.bz2"
						remove_clutter
						;;

				cinnamon)
						local tmp_cinnamon="/tmp/cinnamon_panel.ini"
						dconf dump /org/cinnamon/ > "$tmp_cinnamon"

						local panel_ini="$DEST_DIR/.config/panel.ini"
						mkdir -p "$(dirname "$panel_ini")"
						{
								sed 1q "$tmp_cinnamon"
								grep -E \
										"enabled-applets|panels-autohide|enabled-extensions|\
panels-enabled|panels-height|panels-hide-delay|panels-show-delay|\
panel-zone-icon-sizes|panel-zone-symbolic-icon-sizes|panel-zone-text-sizes" \
										"$tmp_cinnamon"
						} >> "$panel_ini"

						dconf_dump /org/gnome/terminal/legacy/profiles:/ .config/gnome-terminal-profile
						save_folder ".config/cinnamon"
						#save_folder ".local/share/cinnamon"
						save_folder ".local/share/nemo/scripts"
						remove_clutter
						;;

				gnome)
						local tmp_shell="/tmp/gnome_shell.ini"
						dconf dump /org/gnome/shell/ > "$tmp_shell"

						local fav_ini="$DEST_DIR/.config/fav_apps.ini"
						mkdir -p "$(dirname "$fav_ini")"
						sed 1q "$tmp_shell" > "$fav_ini"
						grep "favorite-apps" "$tmp_shell" >> "$fav_ini"

						dconf_dump /org/gnome/desktop/app-folders/ .config/app_folders.ini
						#dconf_dump /org/gnome/shell/extensions/ .config/extensions.ini
						save_file ".config/pop-shell/config.json"
						save_folder ".config/forge/config"
						save_file ".config/gdm-settings.ini"
						remove_clutter
						;;

				kde)
						if command -v konsave &>/dev/null; then
								konsave -r defaults 2>/dev/null
								konsave -s defaults 2>/dev/null
								save_folder ".config/konsave"
								remove_clutter
						else
								warn "konsave not found, skipping KDE backup"
						fi
						;;

				*)
						# Window managers
						local -a WM_FILES=(
								".xinitrc"
								".config/wayinitrc"
								".fehbg"
								".local/bin/startw"
								".local/bin/i3-printscreen"
								".local/bin/maim-select"
								".config/alacritty/alacritty.toml"
								".config/foot/foot.ini"
								".config/awesome/rc.lua"
								".config/openbox/autostart"
								".config/openbox/environment"
								".config/openbox/rc.xml"
								".config/obmenu-generator/config.pl"
								".config/obmenu-generator/schema.pl"
								".config/i3/config"
								".config/swhkd/swhkdrc"
								".config/betterlockscreen/betterlockscreenrc"
								".config/dunst/dunstrc"
								".config/mako/config"
								#".config/waytrogen/config.json"
								".config/waypaper/config.ini"
								".config/ranger/rc.conf"
								#".config/ulauncher/settings.json"
								".config/fuzzel/fuzzel.ini"
								#".config/flameshot/flameshot.ini"
								".config/polybar/launch.sh"
								".config/polybar/config.ini"
								".config/waybar/config.jsonc"
								".config/waybar/style.css"
								".config/waybar/launch.sh"
								#".config/yambar/config.yml"
								".config/tint2/tint2rc"
								".config/xsettingsd.conf"
								".config/xsettingsd/xsettingsd.conf"
						)
						save_files WM_FILES

						local -a WM_FOLDERS=(
								".config/sway"
								".config/niri"
								".config/hypr"
								".config/autorandr"
								".config/picom"
								".config/gtklock"
								#".config/nitrogen"
								".config/rofi"
								".config/wofi"
								".config/wlogout"
								".config/eww"
								".config/noctalia"
								".config/DankMaterialShell"
								".config/polybar/modules"
								".config/polybar/scripts"
						)
						save_folders WM_FOLDERS
						;;
		esac

		success "DE/WM config saved"
}

# --- Section: Distro-specific ---
backup_distro_specific() {
		section "Distro-specific ($DISTRO_ID)"
		case "$DISTRO_ID" in
				linuxmint) save_folder ".linuxmint" ;;
				manjaro)   save_folder ".config/manjaro" ;;
				arch|fedora) info "No distro-specific extras for $DISTRO_ID" ;;
				*) info "No distro-specific config defined for $DISTRO_ID" ;;
		esac
}

# --- Section: Common ---
backup_common() {
		section "Common"

		local -a COMMON_FILES=(
				".config/mimeapps.list"
				#".gtk-bookmarks"
				".config/gtk-3.0/bookmarks"
				".config/gtk-3.0/settings.ini"
				".config/fontconfig/fonts.conf"
				#".config/libfm/libfm.conf"
				#".config/pcmanfm/default/pcmanfm.conf"
				".config/xfce4/helpers.rc"
				#".config/leafpad/leafpadrc"
				".vimrc"
				".config/mpv/mpv.conf"
				".config/celluloid/mpv.conf"
				#".config/redshift.conf"
				".config/transmission/settings.json"
				".config/qBittorrent/qBittorrent.conf"
				".config/inkscape/preferences.xml"
				#".config/brave-flags.conf"
				".config/libreoffice/4/user/registrymodifications.xcu"
				".var/app/org.x.Warpinator/config/glib-2.0/settings/keyfile"
				".config/syncthing-gtk/config.json"
				".var/app/me.kozec.syncthingtk/config/syncthing-gtk/config.json"
				#".var/app/us.zoom.Zoom/config/zoomus.conf"
				".gtkrc-2.0"
				".config/Kvantum/kvantum.kvconfig"
				".config/qt5ct/qt5ct.conf"
				".config/qt6ct/qt6ct.conf"
		)
		save_files COMMON_FILES

		local -a COMMON_FOLDERS=(
				".config/autostart"
				".config/nvim"
				#".config/redshift"
				".config/gammastep"
				".local/share/dark-mode.d"
				".local/share/light-mode.d"
		)
		save_folders COMMON_FOLDERS

		# Timeshift (root-owned, requires sudo)
		if [[ -f "/etc/timeshift/timeshift.json" ]]; then
				info "Backing up Timeshift config (requires sudo)..."
				sudo cp /etc/timeshift/timeshift.json "$COMMON_DIR/timeshift.json"
				success "Timeshift config saved"
		fi

		# Legacy: Geany (truncates config at line 223 to strip session data)
		#GEANY_CONFIG="$HOME/.config/geany/geany.conf"
		#if [[ -f "$GEANY_CONFIG" ]]; then
		#    killall geany 2>/dev/null
		#    mkdir -p "$DEST_DIR/.config/geany/"
		#    sed '223,$d' "$GEANY_CONFIG" > "$DEST_DIR/.config/geany/geany.conf"
		#fi

		success "Common configs saved"
}

# --- Section: Gaming ---
backup_gaming() {
		section "Gaming"

		local -a GAMING_FOLDERS=(
				".config/lutris"
				".var/app/net.lutris.Lutris/config/lutris"
				".config/MangoHud"
		)
		save_folders GAMING_FOLDERS
		save_file ".config/Optimus Manager/Optimus Manager Qt.conf"
		save_file ".config/goverlay/MangoHud.conf"

		success "Gaming configs saved"
}

# --- Section: Audio ---
backup_audio() {
		section "Audio"

		# Legacy: PulseAudio equalizer
		#if command -v pulseaudio-equalizer-gtk &>/dev/null && [[ -d "$HOME/.config/pulse/presets/" ]]; then
		#    mkdir -p "$DEST_DIR/.config/pulse/"
		#    cp -rf "$HOME/.config/pulse/presets/" "$DEST_DIR/.config/pulse/"
		#    cp -rf "$HOME/.config/pulse/equalizerrc" "$DEST_DIR/.config/pulse/"
		#    cp -rf "$HOME/.config/pulse/equalizerrc.availablepresets" "$DEST_DIR/.config/pulse/"
		#fi

		# Legacy: PulseEffects (replaced by EasyEffects)
		#if command -v pulseeffects &>/dev/null; then save_folder ".config/PulseEffects"; fi

		if command -v easyeffects &>/dev/null; then
				save_folder ".config/easyeffects"
				success "EasyEffects config saved"
		else
				info "EasyEffects not installed, skipping"
		fi
}

# --- Section: Themes ---
backup_themes() {
		section "Themes"

		# Legacy: Plank dock
		#if command -v plank &>/dev/null; then
		#    save_folder ".config/plank/dock2"
		#    dconf_dump /net/launchpad/plank/ .config/plank/plank.ini
		#fi

		info "No active theme configs to back up"
}

# --- Final cleanup pass ---
final_cleanup() {
		if [[ "$WM_DE" == "gnome" || "$WM_DE" == "cinnamon" ]]; then
				remove_clutter
		fi
}

# --- Entry Point ---
main() {
		echo "========================================"
		echo " Dotfile Backup"
		echo " Distro : $DISTRO_ID"
		echo " DE/WM  : ${WM_DE:-unknown}"
		echo " Dest   : $DEST_DIR"
		echo "========================================"

		rm -rf "$DEST_DIR"

		backup_shell
		backup_de_wm
		backup_distro_specific
		backup_common
		backup_gaming
		backup_audio
		backup_themes
		final_cleanup

		echo
		echo "========================================"
		success "Backup complete → $DEST_DIR"
		echo "========================================"
}

main "$@"
