#!/bin/bash
#
# Cohesive Desktop Theme Synchronizer
# This script reads the current GTK, Icon, and Cursor themes from common
# desktop environments and ensures they are consistently applied to:
# 1. GTK 4 applications (via ~/.config/gtk-4.0 symlinks).
# 2. Flatpak applications (via copying themes to standard user data directories and applying overrides).
# 3. Qt applications using Kvantum (via Flatpak overrides).
#
# Note: The script avoids 'sudo' and focuses only on user-level configuration.

# --- 1. Environment Detection and Theme Reading ---

# wm_de should ideally be set by the calling environment. If not, we determine it
# using standard desktop environment variables.
if [[ -z "${wm_de}" ]]; then
	if [ -z "${XDG_CURRENT_DESKTOP}" ]; then
		# Use DESKTOP_SESSION as fallback
		# Note: The specific cuts are used to normalize complex session strings.
		wm_de="$(echo "${DESKTOP_SESSION}" | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
	else
		# Use XDG_CURRENT_DESKTOP (preferred source)
		wm_de="$(echo "${XDG_CURRENT_DESKTOP}" | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
	fi

	# Final check: If the parsing resulted in an empty string, fall back to generic 'config' mode.
	if [[ -z "${wm_de}" ]]; then
		wm_de="config"
	fi
fi

echo "Detected Environment/Mode: ${wm_de}"

# Initialize theme variables
gtk_theme=""
icon_theme=""
cursor_theme=""
cursor_size="" # Initialize cursor size variable

# Function to safely get gsettings value
get_gsetting() {
    local schema=$1
    local key=$2
    gsettings get "$schema" "$key" 2>/dev/null | sed "s/^'//;s/'$//"
}

if [[ "${wm_de}" == "xfce" ]]; then
    gtk_theme="$(xfconf-query -c xsettings -p /Net/ThemeName -v 2>/dev/null)"
    icon_theme="$(xfconf-query -c xsettings -p /Net/IconThemeName -v 2>/dev/null)"
    cursor_theme="$(xfconf-query -c xsettings -p /Gtk/CursorThemeName -v 2>/dev/null)"
    # Get cursor size from xfconf
    cursor_size="$(xfconf-query -c xsettings -p /Gtk/CursorThemeSize -v 2>/dev/null)"

elif [[ "${wm_de}" == "cinnamon" ]]; then
    gtk_theme="$(get_gsetting org.cinnamon.desktop.interface gtk-theme)"
    icon_theme="$(get_gsetting org.cinnamon.desktop.interface icon-theme)"
    cursor_theme="$(get_gsetting org.cinnamon.desktop.interface cursor-theme)"
    # Get cursor size from GSettings
    cursor_size="$(get_gsetting org.gnome.desktop.interface cursor-size)" # Cinnamon often uses GNOME's schema for size

elif [[ "${wm_de}" == "gnome" ]]; then
    gtk_theme="$(get_gsetting org.gnome.desktop.interface gtk-theme)"
    icon_theme="$(get_gsetting org.gnome.desktop.interface icon-theme)"
    cursor_theme="$(get_gsetting org.gnome.desktop.interface cursor-theme)"
    # Get cursor size from GSettings
    cursor_size="$(get_gsetting org.gnome.desktop.interface cursor-size)"

elif [[ -f $HOME/.config/gtk-3.0/settings.ini ]]; then
    # General fallback for WMs or unknown DEs (matches 'config' mode)
    config_file="$HOME/.config/gtk-3.0/settings.ini"
    # NOTE: Using 'sed' to strip only leading space, preserving spaces in theme names.
    gtk_theme="$(grep 'gtk-theme-name' "${config_file}" | cut -d'=' -f2 | sed 's/^[[:space:]]*//')"
    icon_theme="$(grep 'gtk-icon-theme-name' "${config_file}" | cut -d'=' -f2 | sed 's/^[[:space:]]*//')"
    cursor_theme="$(grep 'gtk-cursor-theme-name' "${config_file}" | cut -d'=' -f2 | sed 's/^[[:space:]]*//')"
fi

# Set a default cursor size if detection failed or returned empty/zero
if [[ -z "${cursor_size}" || "${cursor_size}" == "0" ]]; then
    cursor_size="24" # Default to 32px for modern desktop environments
fi


if [[ -z "${gtk_theme}" ]]; then
    echo "Error: Could not determine current GTK theme. Exiting." >&2
    exit 1
fi

echo "GTK Theme: ${gtk_theme}"
echo "Icon Theme: ${icon_theme}"
echo "Cursor Theme: ${cursor_theme}"
echo "Cursor Size: ${cursor_size}px" # Display detected/default size

# --- 2. Find Absolute Theme Paths ---

# Find the absolute directory for the GTK theme (GTK 4 symlinking needs this)
theme_dir=""
if [ -d /usr/share/themes/"${gtk_theme}" ]; then
	theme_dir="/usr/share/themes/${gtk_theme}"
elif [ -d "$HOME/.themes/${gtk_theme}" ]; then
	theme_dir="$HOME/.themes/${gtk_theme}"
fi

# Find the absolute directory for the Cursor theme (for Flatpak overrides)
cursor_dir=""
if [ -d /usr/share/icons/"${cursor_theme}" ]; then
	cursor_dir="/usr/share/icons/${cursor_theme}"
elif [ -d "$HOME/.icons/${cursor_theme}" ]; then
	cursor_dir="$HOME/.icons/${cursor_theme}"
fi

if [[ -z "${theme_dir}" ]]; then
    echo "Warning: Could not find GTK theme directory for '${gtk_theme}'. Skipping GTK4/Flatpak theming."
fi


# --- 3. Apply GTK 4 Theme Cohesion ---

if [[ -n "${theme_dir}" ]] && [[ -d "${theme_dir}/gtk-4.0" ]]; then
    echo "Applying GTK 4 symlinks..."
    gtk4_config="$HOME/.config/gtk-4.0"
    mkdir -p "${gtk4_config}"

    # Remove existing links/files to prevent conflicts
    rm -f "${gtk4_config}/assets" "${gtk4_config}/gtk.css" "${gtk4_config}/gtk-dark.css"

    # Create new symlinks
    ln -sf "${theme_dir}/gtk-4.0/assets" "${gtk4_config}/assets"
    ln -sf "${theme_dir}/gtk-4.0/gtk.css" "${gtk4_config}/gtk.css"
    # gtk-dark.css might not exist, so link it only if present
    if [ -f "${theme_dir}/gtk-4.0/gtk-dark.css" ]; then
        ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "${gtk4_config}/gtk-dark.css"
    fi
else
    echo "Skipping GTK 4 theming (theme directory or gtk-4.0 subdirectory not found)."
fi


# --- 4. Apply Flatpak Overrides (Theme Access) ---

if command -v flatpak &> /dev/null; then
    echo "Applying Flatpak overrides..."

    # 4a. Copy themes to user's local share directory for reliable Flatpak access
    if [[ -n "${theme_dir}" ]]; then
        theme_dest="$HOME/.local/share/themes/${gtk_theme}"
        if [ ! -d "${theme_dest}" ]; then
            echo "Copying GTK theme to ${theme_dest} for Flatpak compatibility..."
            mkdir -p "$HOME/.local/share/themes"
            # Use 'cp -r' to copy the directory recursively
            cp -r "${theme_dir}" "$HOME/.local/share/themes/"
        else
            echo "GTK theme already present in local share directory."
        fi
    fi

    if [[ -n "${cursor_dir}" ]]; then
        icon_dest="$HOME/.local/share/icons/${cursor_theme}"
        if [ ! -d "${icon_dest}" ]; then
            echo "Copying Cursor theme to ${icon_dest} for Flatpak compatibility..."
            mkdir -p "$HOME/.local/share/icons"
            # Use 'cp -r' to copy the directory recursively
            cp -r "${cursor_dir}" "$HOME/.local/share/icons/"
        else
            echo "Cursor theme already present in local share directory."
        fi
    fi

    # 4b. Expose necessary directories for Flatpak theming
    # This ensures maximum visibility for themes placed in standard/hidden/system locations.
    flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
    flatpak override --user --filesystem=xdg-config/gtk-4.0:ro
    #flatpak override --user --filesystem=home/.themes:ro
    #flatpak override --user --filesystem=home/.icons:ro
    flatpak override --user --filesystem=xdg-data/themes:ro
    flatpak override --user --filesystem=xdg-data/icons:ro


    # 4c. Set theme environment variables for apps that don't auto-detect
    flatpak override --user --env=GTK_THEME="${gtk_theme}"
    flatpak override --user --env=XCURSOR_THEME="${cursor_theme}"
    flatpak override --user --env=XCURSOR_PATH="$HOME/.local/share/icons"
    flatpak override --user --env=XCURSOR_SIZE="${cursor_size}" # Added cursor size override

    # 4d. Kvantum (Qt) Theming for Flatpak
    if [ -f /usr/bin/kvantummanager ]; then
        echo "Configuring Kvantum for Flatpak apps..."
        # Expose the user's Kvantum configuration directory
        flatpak override --user --filesystem="$HOME/.config/Kvantum:ro"
        # Force Qt apps to use the Kvantum style engine
        flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum
        # Optionally, set a Kvantum theme environment variable
        flatpak override --user --env=KVANTUM_THEME="${gtk_theme}"
    fi

    # 4e. Icon cache update for the copied theme
    # We update the cache on the copied version to ensure Flatpak sees it instantly.
    if [[ "${icon_theme}" != "" ]] && [[ -d "$HOME/.local/share/icons/${icon_theme}" ]]; then
        echo "Updating icon cache for local share theme '${icon_theme}'..."
        gtk-update-icon-cache -f "$HOME/.local/share/icons/${icon_theme}" 2> /dev/null
    fi

else
    echo "Flatpak command not found. Skipping Flatpak overrides."
fi


# --- 5. Apply Theme to GNOME Settings (If not already GNOME) ---

# This section writes the determined theme back to dconf, which manages
# themes for many DEs (Cinnamon, GNOME, etc.) and is often read by apps.
if [[ -n "${gtk_theme}" ]] && command -v gsettings &> /dev/null; then
    echo "Synchronizing themes via GSettings/dconf..."
    # Apply GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "'${gtk_theme}'" 2>/dev/null
    # Apply Icon theme
    gsettings set org.gnome.desktop.interface icon-theme "'${icon_theme}'" 2>/dev/null
    # Apply Cursor theme
    gsettings set org.gnome.desktop.interface cursor-theme "'${cursor_theme}'" 2>/dev/null
    # Apply Cursor size
    gsettings set org.gnome.desktop.interface cursor-size "${cursor_size}" 2>/dev/null
fi

echo "Theming synchronization complete."
