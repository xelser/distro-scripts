#!/bin/bash

# --- Configuration ---

# Base directories
GAMING_DIR="$HOME/Documents/distro-scripts/gaming"
COMMON_DIR="$HOME/Documents/distro-scripts/common"

# The script relies on the 'distro_id' variable being set,
# for example: export distro_id="arch"
if [ -z "$distro_id" ]; then
    echo "Error: 'distro_id' environment variable is not set." >&2
    exit 1
fi

# Determine Window Manager/Desktop Environment
get_wm_de() {
    local wm_de=""
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        wm_de="$(echo "$XDG_CURRENT_DESKTOP" | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
    elif [ -n "$DESKTOP_SESSION" ]; then
        wm_de="$(echo "$DESKTOP_SESSION" | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
    fi
    echo "$wm_de"
}

WM_DE=$(get_wm_de)

# Set the destination directory
if [ -n "$WM_DE" ] && [ "$WM_DE" != "gnome" ] && [ "$WM_DE" != "cinnamon" ] && [ "$WM_DE" != "xfce" ] && [ "$WM_DE" != "kde" ]; then
    # For window managers, use only distro_id (as per your original script's fallback logic)
    DEST_DIR="$HOME/Documents/distro-scripts/dotfiles/${distro_id}"
else
    # For DEs, use the distro_id-wm_de naming convention
    DEST_DIR="$HOME/Documents/distro-scripts/dotfiles/${distro_id}-${WM_DE}"
fi

# Clean destination directory
rm -rf "$DEST_DIR"

# --- Helper Functions ---

# Save a folder (recursively copy contents)
save_folder () {
    local source_dir="$HOME/$1"
    local dest_dir="$DEST_DIR/$1"
    if [[ -d "$source_dir" ]]; then
        mkdir -p "$dest_dir" && cp -rf "$source_dir"* "$dest_dir"
    fi
}

# Save a single file
save_file () {
    local dir="$1"
    local filename="$2"
    local source_file="$HOME/$dir/$filename"
    local dest_dir="$DEST_DIR/$dir"
    if [[ -f "$source_file" ]]; then
        mkdir -p "$dest_dir" && cp -f "$source_file" "$dest_dir"
    fi
}

# Custom Dconf dump function
dconf_dump_to_file() {
    local path="$1"
    local dest_file="$DEST_DIR/$2"
    dconf dump "$path" > "$dest_file" 2>/dev/null
}

# Remove clutter for DEs
remove_clutter() {
    rm -rf "$DEST_DIR"/.config/Kvantum/
    rm -rf "$DEST_DIR"/.config/qt5ct/
    if [[ "$WM_DE" == "cinnamon" ]]; then
        rm -rf "$DEST_DIR"/.config/gtk-3.0/
    fi
}

# --- Main Logic ---

# 1. SHELL
cp -f "$HOME/.bash_aliases" "$COMMON_DIR/bash_aliases"
cp -f "$HOME/.bash_profile" "$COMMON_DIR/bash_profile"

# 2. DESKTOP ENVIRONMENTS
mkdir -p "$DEST_DIR"

case "$WM_DE" in
    xfce)
        # Menu Entries
        save_file /.config/menus/ xfce-applications.menu

        # Panel Settings
        xfce4-panel-profiles save "$HOME/.config/xfce4-panel-backups/my-panel.tar.bz2" 2>/dev/null
        save_file /.config/xfce4-panel-backups/ my-panel.tar.bz2

        remove_clutter
        ;;

    cinnamon)
        # Panel & Applet settings (The original used a specific grep list, retaining that logic)
        local temp_cinnamon_ini="/tmp/cinnamon_panel_beta.ini"
        dconf dump /org/cinnamon/ > "$temp_cinnamon_ini"

        local panel_ini="${DEST_DIR}/.config/panel.ini"
        mkdir -p "$(dirname "$panel_ini")"
        {
            sed 1q "$temp_cinnamon_ini"
            grep "enabled-applets" "$temp_cinnamon_ini"
            grep "panels-autohide" "$temp_cinnamon_ini"
            grep "enabled-extensions" "$temp_cinnamon_ini"
            grep "panels-enabled" "$temp_cinnamon_ini"
            grep "panels-height" "$temp_cinnamon_ini"
            grep "panels-hide-delay" "$temp_cinnamon_ini"
            grep "panels-show-delay" "$temp_cinnamon_ini"
            grep "panel-zone-icon-sizes" "$temp_cinnamon_ini"
            grep "panel-zone-symbolic-icon-sizes" "$temp_cinnamon_ini"
            grep "panel-zone-text-sizes" "$temp_cinnamon_ini"
        } >> "$panel_ini"

        # GNOME Terminal (used in Cinnamon)
        dconf_dump_to_file /org/gnome/terminal/legacy/profiles:/ .config/gnome-terminal-profile

        # Applets, Desklets, Extensions, Nemo Scripts
        save_folder /.config/cinnamon/
        #save_folder /.local/share/cinnamon/ # Commented out in original
        save_folder /.local/share/nemo/scripts/

        remove_clutter
        ;;

    gnome)
        # GNOME Shell (Favorite Apps, App Folders)
        local temp_shell_ini="/tmp/shell_beta.ini"
        dconf dump /org/gnome/shell/ > "$temp_shell_ini"
        local fav_apps_ini="${DEST_DIR}/.config/fav_apps.ini"
        mkdir -p "$(dirname "$fav_apps_ini")"
        sed 1q "$temp_shell_ini" > "$fav_apps_ini"
        grep "favorite-apps" "$temp_shell_ini" >> "$fav_apps_ini"

        dconf_dump_to_file /org/gnome/desktop/app-folders/ .config/app_folders.ini
        #dconf_dump_to_file /org/gnome/shell/extensions/ .config/extensions.ini # Commented out in original

        # Pop-Shell, Forge, GDM
        save_file /.config/pop-shell/ config.json
        save_folder /.config/forge/config/
        save_file /.config/ gdm-settings.ini

        remove_clutter
        ;;

    kde)
        # Konsave
        if command -v konsave &>/dev/null; then
            konsave -r defaults 2>/dev/null
            konsave -s defaults 2>/dev/null
            save_folder /.config/konsave/
            remove_clutter
        fi
        ;;

    *)
        # 3. WINDOW MANAGERS & OTHER
        WM_CONFIGS=(
            ".xinitrc"
            ".config/wayinitrc"
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
            ".config/niri/config.kdl"
            ".config/hypr/hyprland.conf"
            ".config/swhkd/swhkdrc"
            ".config/betterlockscreen/betterlockscreenrc"
            ".config/dunst/dunstrc"
            ".config/mako/config"
            ".fehbg"
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
            #".config/xsettingsd/xsettingsd.conf" # Commented out in original
        )
        for config in "${WM_CONFIGS[@]}"; do
            save_file "$(dirname "$config")/" "$(basename "$config")"
        done

        # Folders
        WM_FOLDERS=(
            ".config/sway/"
            ".config/autorandr/"
            ".config/picom/"
            ".config/gtklock/"
            #".config/nitrogen/"
            ".config/rofi/"
            ".config/wofi/"
            ".config/wlogout/"
            ".config/eww/"
            ".config/polybar/modules/"
            ".config/polybar/scripts/"
        )
        for folder in "${WM_FOLDERS[@]}"; do
            save_folder "$folder"
        done
        ;;
esac

# 4. DISTROBUTION SPECIFICS
case "$distro_id" in
    linuxmint) save_folder /.linuxmint/ ;;
    manjaro) save_folder /.config/manjaro/ ;;
esac

# 5. COMMON
COMMON_FILES=(
    ".config/mimeapps.list"
    #".gtk-bookmarks"
    ".config/gtk-3.0/bookmarks"
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
    #".config/ brave-flags.conf"
    ".config/libreoffice/4/user/registrymodifications.xcu"
    ".var/app/org.x.Warpinator/config/glib-2.0/settings/keyfile"
    ".config/syncthing-gtk/config.json"
    ".var/app/me.kozec.syncthingtk/config/syncthing-gtk/config.json"
    #".var/app/us.zoom.Zoom/config/zoomus.conf" # Commented out in original
    ".gtkrc-2.0"
    ".config/gtk-3.0/settings.ini"
    ".config/Kvantum/kvantum.kvconfig"
    ".config/qt5ct/qt5ct.conf"
)
for config in "${COMMON_FILES[@]}"; do
    save_file "$(dirname "$config")/" "$(basename "$config")"
done

COMMON_FOLDERS=(
    ".config/autostart/"
    ".config/nvim/" # Retaining for nvim preference
    #".config/redshift/"
    ".config/gammastep/"
    ".local/share/dark-mode.d/"
    ".local/share/light-mode.d/"
)
for folder in "${COMMON_FOLDERS[@]}"; do
    save_folder "$folder"
done

# Geany (specific logic retained)
#GEANY_CONFIG="$HOME/.config/geany/geany.conf"
#if [ -f "$GEANY_CONFIG" ]; then
#    killall geany 2>/dev/null
#    mkdir -p "$DEST_DIR/.config/geany/"
#    # The original script truncates the geany.conf file from line 223 onwards
#    sed '223,$d' "$GEANY_CONFIG" > "$DEST_DIR/.config/geany/geany.conf"
#fi

# 6. GAMING
GAMING_FOLDERS=(
    ".config/lutris/"
    ".var/app/net.lutris.Lutris/config/lutris/"
    ".config/MangoHud/"
)
for folder in "${GAMING_FOLDERS[@]}"; do
    save_folder "$folder"
done

# GAMING Files
save_file /.config/'Optimus Manager'/ 'Optimus Manager Qt'.conf
save_file /.config/goverlay/ MangoHud.conf

# 7. AUDIO
#if command -v pulseaudio-equalizer-gtk &>/dev/null && [ -d "$HOME/.config/pulse/presets/" ]; then
#    mkdir -p "$DEST_DIR/.config/pulse/"
#    cp -rf "$HOME/.config/pulse/presets/" "$DEST_DIR/.config/pulse/"
#    cp -rf "$HOME/.config/pulse/equalizerrc" "$DEST_DIR/.config/pulse/"
#    cp -rf "$HOME/.config/pulse/equalizerrc.availablepresets" "$DEST_DIR/.config/pulse/"
#fi

#if command -v pulseeffects &>/dev/null; then save_folder /.config/PulseEffects/ ; fi
if command -v easyeffects &>/dev/null; then save_folder /.config/easyeffects/ ; fi

# 8. THEMES (Plank - specific logic retained)
# if command -v plank &>/dev/null; then
#     save_folder /.config/plank/dock2/
#     dconf_dump_to_file /net/launchpad/plank/ .config/plank/plank.ini
# fi

# 9. FINAL CLUTTER REMOVAL (redundant now, but included for completeness from original)
if [[ "$WM_DE" == "gnome" ]] || [[ "$WM_DE" == "cinnamon" ]]; then
    remove_clutter
fi
