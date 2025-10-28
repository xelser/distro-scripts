#!/bin/bash

# --- 1. Environment Detection and Theme Reading ---

# wm_de should ideally be set by the calling environment. If not, we determine it
# using standard desktop environment variables.
if [[ -z "${wm_de}" ]]; then
	if [ -z "${XDG_CURRENT_DESKTOP}" ]; then
		wm_de="$(echo "${DESKTOP_SESSION}" | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
	else
		wm_de="$(echo "${XDG_CURRENT_DESKTOP}" | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
	fi

	if [[ "${XDG_CURRENT_DESKTOP}" == *"Sway"* ]]; then
		wm_de="sway"
	elif [[ "${XDG_CURRENT_DESKTOP}" == *"i3"* ]]; then
		wm_de="i3"
	fi

	if [[ -z "${wm_de}" ]]; then
		wm_de="config"
	fi
fi

# Detect if we are in an X11 session
if [ -n "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    is_x11_session=true
else
    is_x11_session=false
fi

echo "Detected Environment/Mode: ${wm_de}"
echo "Is X11 Session: ${is_x11_session}"

# Initialize theme variables
gtk_theme=""
icon_theme=""
cursor_theme=""
cursor_size=""

# Initialize font variables
gtk_font_antialias=""
gtk_font_hinting=""
gtk_font_hintstyle=""
gtk_font_rgba=""

# Function to safely get gsettings value
get_gsetting() {
	local schema=$1
	local key=$2
	gsettings get "$schema" "$key" 2>/dev/null | sed "s/^'//;s/'$//"
}

# Function to safely get value from settings.ini
get_ini_setting() {
    local key=$1
    local config_file="$HOME/.config/gtk-3.0/settings.ini"

    if [ -f "${config_file}" ]; then
        # Use awk to find the key within the [Settings] block and extract the value
        awk -F '=' '
            $1 ~ /\[Settings\]/ { settings_block=1; next }
            /^\[/ { settings_block=0 }
            settings_block && $1 ~ /'"${key}"'/ {
                gsub(/^ +| +$/, "", $2);
                gsub(/"/, "", $2);
                print $2;
                exit
            }
        ' "${config_file}"
    fi
}


if [[ "${wm_de}" == "xfce" ]]; then
	gtk_theme="$(xfconf-query -c xsettings -p /Net/ThemeName -v 2>/dev/null)"
	icon_theme="$(xfconf-query -c xsettings -p /Net/IconThemeName -v 2>/dev/null)"
	cursor_theme="$(xfconf-query -c xsettings -p /Gtk/CursorThemeName -v 2>/dev/null)"
	cursor_size="$(xfconf-query -c xsettings -p /Gtk/CursorThemeSize -v 2>/dev/null)"

elif [[ "${wm_de}" == "cinnamon" ]] || [[ "${wm_de}" == "gnome" ]]; then
	# GSettings for theme/cursor
    schema_interface="org.gnome.desktop.interface"
	gtk_theme="$(get_gsetting "${schema_interface}" gtk-theme)"
	icon_theme="$(get_gsetting "${schema_interface}" icon-theme)"
	cursor_theme="$(get_gsetting "${schema_interface}" cursor-theme)"
	cursor_size="$(get_gsetting "${schema_interface}" cursor-size)"

    # GSettings for font settings
    gtk_font_antialias="$(get_gsetting "${schema_interface}" font-antialiasing)"
    gtk_font_hinting="$(get_gsetting "${schema_interface}" font-hinting)"
    gtk_font_hintstyle="$(get_gsetting "${schema_interface}" font-hint-style)"
    gtk_font_rgba="$(get_gsetting "${schema_interface}" subpixel-rendering)"

elif [[ -f $HOME/.config/gtk-3.0/settings.ini ]]; then
	# General fallback for WMs (config, sway, i3)
	gtk_theme="$(get_ini_setting 'gtk-theme-name')"
	icon_theme="$(get_ini_setting 'gtk-icon-theme-name')"
	cursor_theme="$(get_ini_setting 'gtk-cursor-theme-name')"

    # GTK font settings from settings.ini
    gtk_font_antialias="$(get_ini_setting 'gtk-enable-antialias')"
    gtk_font_hintstyle="$(get_ini_setting 'gtk-hint-style')"
    gtk_font_rgba="$(get_ini_setting 'gtk-xft-rgba')"
fi

# Set a default cursor size if detection failed or returned empty/zero
if [[ -z "${cursor_size}" || "${cursor_size}" == "0" ]]; then
	cursor_size="24"
fi

# Normalize GTK settings to Xft format
# Antialias
if [[ "${gtk_font_antialias}" == "1" || "${gtk_font_antialias}" == "true" ]]; then
    xft_antialias="true"
elif [[ "${gtk_font_antialias}" == "0" || "${gtk_font_antialias}" == "false" ]]; then
    xft_antialias="false"
elif [[ -z "${xft_antialias}" ]]; then
    xft_antialias="true"
fi

# Hinting
if [[ "${gtk_font_hinting}" == "1" || "${gtk_font_hinting}" == "true" ]]; then
    xft_hinting="true"
elif [[ "${gtk_font_hinting}" == "0" || "${gtk_font_hinting}" == "false" ]]; then
    xft_hinting="false"
elif [[ "${xft_antialias}" == "true" ]]; then
    xft_hinting="true"
fi

xft_hintstyle="${gtk_font_hintstyle}"
if [[ -z "${xft_hintstyle}" && "${xft_hinting}" == "true" ]]; then
    xft_hintstyle="hintslight"
fi

xft_rgba="${gtk_font_rgba}"
if [[ -z "${xft_rgba}" && "${xft_antialias}" == "true" ]]; then
    xft_rgba="rgb"
fi


if [[ -z "${gtk_theme}" ]]; then
	echo "Error: Could not determine current GTK theme. Exiting." >&2
	exit 1
fi

echo "GTK Theme: **${gtk_theme}**"
echo "Icon Theme: **${icon_theme}**"
echo "Cursor Theme: **${cursor_theme}**"
echo "Cursor Size: **${cursor_size}px**"
echo "Xft Antialias: **${xft_antialias}**"
echo "Xft Hintstyle: **${xft_hintstyle}**"

# --- 2. Find Absolute Theme Paths ---

theme_dir=""
if [ -d /usr/share/themes/"${gtk_theme}" ]; then
	theme_dir="/usr/share/themes/${gtk_theme}"
elif [ -d "$HOME/.themes/${gtk_theme}" ]; then
	theme_dir="$HOME/.themes/${gtk_theme}"
fi

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

	rm -f "${gtk4_config}/assets" "${gtk4_config}/gtk.css" "${gtk4_config}/gtk-dark.css"

	ln -sf "${theme_dir}/gtk-4.0/assets" "${gtk4_config}/assets"
	ln -sf "${theme_dir}/gtk-4.0/gtk.css" "${gtk4_config}/gtk.css"
	if [ -f "${theme_dir}/gtk-4.0/gtk-dark.css" ]; then
		ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "${gtk4_config}/gtk-dark.css"
	fi
else
	echo "Skipping GTK 4 theming (theme directory or gtk-4.0 subdirectory not found)."
fi

# --- 4. Apply Flatpak Overrides ---

if command -v flatpak &> /dev/null; then
	echo "Applying Flatpak overrides..."

	# 4a. Copy themes
	if [[ -n "${theme_dir}" ]]; then
		theme_dest="$HOME/.local/share/themes/${gtk_theme}"
		if [ ! -d "${theme_dest}" ]; then
			echo "Copying GTK theme to ${theme_dest} for Flatpak compatibility..."
			mkdir -p "$HOME/.local/share/themes"
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
			cp -r "${cursor_dir}" "$HOME/.local/share/icons/"
		else
			echo "Cursor theme already present in local share directory."
		fi
	fi

	# 4b. Expose necessary directories
	flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
	flatpak override --user --filesystem=xdg-config/gtk-4.0:ro
	flatpak override --user --filesystem=xdg-data/themes:ro
	flatpak override --user --filesystem=xdg-data/icons:ro


	# 4c. Set theme environment variables
	flatpak override --user --env=GTK_THEME="${gtk_theme}"
	flatpak override --user --env=XCURSOR_THEME="${cursor_theme}"
	flatpak override --user --env=XCURSOR_PATH="$HOME/.local/share/icons"
	flatpak override --user --env=XCURSOR_SIZE="${cursor_size}"

	# 4d. Kvantum (Qt) Theming for Flatpak
	if [ -f /usr/bin/kvantummanager ]; then
		echo "Configuring Kvantum for Flatpak apps..."
		flatpak override --user --filesystem="$HOME/.config/Kvantum:ro"
		flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum
		flatpak override --user --env=KVANTUM_THEME="${gtk_theme}"
	fi

	# 4e. Icon cache update
	if [[ "${icon_theme}" != "" ]] && [[ -d "$HOME/.local/share/icons/${icon_theme}" ]]; then
		echo "Updating icon cache for local share theme '${icon_theme}'..."
		gtk-update-icon-cache -f "$HOME/.local/share/icons/${icon_theme}" 2> /dev/null
	fi

else
	echo "Flatpak command not found. Skipping Flatpak overrides."
fi

# --- 5. Apply Sway Cursor Theme (Wayland only) ---

if [[ "${wm_de}" == "sway" ]]; then
	echo "Applying cursor theme to Sway..."

	sway_config_dir="$HOME/.config/sway/config.d"
	sway_config_file="${sway_config_dir}/cursor"
	sway_command="seat seat0 xcursor_theme \"${cursor_theme}\" ${cursor_size}"

	mkdir -p "${sway_config_dir}"

	if [ -f "${sway_config_file}" ] && grep -q "seat seat0 xcursor_theme" "${sway_config_file}"; then
		echo "Updating existing Sway cursor config line in ${sway_config_file}..."
		nvim -c "%s/^seat seat0 xcursor_theme .*/${sway_command}/g | wq" "${sway_config_file}" 2>/dev/null
	else
		echo "Writing new Sway cursor config to ${sway_config_file}..."
		echo -e "# Set by theme-sync script\n${sway_command}" > "${sway_config_file}"
	fi

	if command -v swaymsg &> /dev/null; then
		echo "Running swaymsg to apply immediately: ${sway_command}"
		swaymsg "${sway_command}" 2>/dev/null || echo "Warning: swaymsg failed to apply cursor theme. Is Sway running?"
	else
		echo "Warning: swaymsg not found. Cursor theme will be applied on next Sway restart."
	fi
else
	echo "Skipping Sway cursor theming (Not Sway environment)."
fi


# --- 6. Apply X11 Cursor Theme (i3/X11 only) ---

if [[ "${is_x11_session}" == true ]] && [[ -n "${cursor_theme}" ]]; then
    echo "Applying cursor theme via Xresources for X11/i3..."
    xresources_file="$HOME/.Xresources"

    # Ensure the file exists
    touch "${xresources_file}"

    theme_line="Xcursor.theme: ${cursor_theme}"
    size_line="Xcursor.size: ${cursor_size}"

    # Update Xcursor.theme
    if grep -q "Xcursor.theme:" "${xresources_file}"; then
        echo "  - Updating Xcursor.theme..."
        nvim -c "%s/^Xcursor.theme:.*/${theme_line}/g | wq" "${xresources_file}" 2>/dev/null
    else
        echo "  - Appending Xcursor.theme..."
        echo "${theme_line}" >> "${xresources_file}"
    fi

    # Update Xcursor.size
    if grep -q "Xcursor.size:" "${xresources_file}"; then
        echo "  - Updating Xcursor.size..."
        nvim -c "%s/^Xcursor.size:.*/${size_line}/g | wq" "${xresources_file}" 2>/dev/null
    else
        echo "  - Appending Xcursor.size..."
        echo "${size_line}" >> "${xresources_file}"
    fi

    echo "X11 cursor settings updated in ${xresources_file}. Changes take effect on next session restart."
fi


# --- 7. Apply GTK Font Settings to Xresources ---

if [[ "${is_x11_session}" == true ]]; then
    echo "Synchronizing GTK font settings to Xresources (Xft)..."
    xresources_file="$HOME/.Xresources"

    # Ensure the file exists (redundant, but safe)
    touch "${xresources_file}"

    declare -A xft_settings=(
        ["Xft.antialias"]="${xft_antialias}"
        ["Xft.hinting"]="${xft_hinting}"
        ["Xft.hintstyle"]="${xft_hintstyle}"
        ["Xft.rgba"]="${xft_rgba}"
    )

    for key in "${!xft_settings[@]}"; do
        value="${xft_settings[${key}]}"
        new_line="${key}: ${value}"

        if [[ -n "${value}" ]]; then
            escaped_key=$(echo "${key}" | sed 's/\./\\./g')

            if grep -q "^${key}:" "${xresources_file}"; then
                echo "  - Updating ${key} to ${value}..."
                nvim -c "%s/^${escaped_key}:.*/${new_line}/g | wq" "${xresources_file}" 2>/dev/null
            else
                echo "  - Appending ${key} with ${value}..."
                echo "${new_line}" >> "${xresources_file}"
            fi
        fi
    done

    echo "Xft settings updated in ${xresources_file}. Changes take effect on next session restart."
fi

# --- 8. Apply Xsettingsd Configuration for X11 Flatpak Apps ---

if [[ "${is_x11_session}" == true ]]; then
    echo "Configuring xsettingsd for X11 (to propagate themes and fonts to Flatpak apps)..."

    xsettingsd_dir="$HOME/.config/xsettingsd"
    xsettingsd_conf="${xsettingsd_dir}/xsettingsd.conf"
    mkdir -p "${xsettingsd_dir}"

    # Detect GTK font name
    gtk_font_name=""
    if command -v gsettings &> /dev/null; then
        gtk_font_name="$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null | sed "s/^'//;s/'$//")"
    fi
    if [[ -z "${gtk_font_name}" ]]; then
        gtk_font_name="$(get_ini_setting 'gtk-font-name')"
    fi
    if [[ -z "${gtk_font_name}" ]]; then
        gtk_font_name="Sans 10"
    fi

    echo "Detected GTK font name: ${gtk_font_name}"

    # Convert boolean values for xsettingsd (expects 0/1)
    xft_antialias_num=1
    xft_hinting_num=1

    if [[ "${xft_antialias}" == "false" ]]; then
        xft_antialias_num=0
    fi
    if [[ "${xft_hinting}" == "false" ]]; then
        xft_hinting_num=0
    fi

    # Default fallback values if missing
    [[ -z "${xft_hintstyle}" ]] && xft_hintstyle="hintslight"
    [[ -z "${xft_rgba}" ]] && xft_rgba="rgb"

    # Write xsettingsd configuration file
    cat > "${xsettingsd_conf}" <<EOF
Net/ThemeName "${gtk_theme}"
Net/IconThemeName "${icon_theme}"
Gtk/CursorThemeName "${cursor_theme}"
Gtk/CursorThemeSize ${cursor_size}
Gtk/FontName "${gtk_font_name}"
Xft/Antialias ${xft_antialias_num}
Xft/Hinting ${xft_hinting_num}
Xft/HintStyle "${xft_hintstyle}"
Xft/RGBA "${xft_rgba}"
EOF

    echo "xsettingsd configuration written to ${xsettingsd_conf}"

    # Restart or start xsettingsd service
    if pgrep -x "xsettingsd" >/dev/null; then
        echo "Restarting xsettingsd..."
        pkill -HUP xsettingsd || pkill xsettingsd
        sleep 0.5
        nohup xsettingsd >/dev/null 2>&1 &
    else
        echo "Starting xsettingsd..."
        nohup xsettingsd >/dev/null 2>&1 &
    fi

    echo "xsettingsd is now active. X11 Flatpak apps should inherit your theme, cursor, and font settings."
fi

# --- 9. Apply Theme to GNOME Settings (Fallback/Cohesion) ---

# This section writes the determined theme back to dconf.
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

# --- 10. Apply Settings to Root User (Sudo) ---

root_config_dir="/root/.config/gtk-3.0"
user_settings_file="$HOME/.config/gtk-3.0/settings.ini"

if [ -f "${user_settings_file}" ] && command -v sudo &> /dev/null; then
    echo "---"
    echo "Applying GTK settings for root applications (gparted, timeshift)..."

    # Create the target directory if it doesn't exist (requires sudo)
    sudo mkdir -p "${root_config_dir}" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "Copying ${user_settings_file} to ${root_config_dir}/..."
        # Copy the user's settings.ini to the root directory
        sudo cp "${user_settings_file}" "${root_config_dir}/settings.ini"

        # NOTE: Symlinking themes is complex as the paths might not exist for root,
        # but the settings.ini usually references themes in /usr/share/themes, which is visible.
        echo "Root settings applied. GTK apps run with sudo should now use your theme/cursor."
    else
        echo "Warning: Could not create root GTK configuration directory. Skipping root theme sync."
    fi
else
    echo "Skipping root GTK settings sync (settings.ini not found or sudo not available)."
fi


echo "Theming synchronization complete."
