
# Check whether if the windowing system is Xorg or Wayland
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	export MOZ_ENABLE_WAYLAND=1
	export OBS_USE_EGL=1
fi

# QT/Kvantum theme
if [ -f /usr/bin/qt5ct ]; then
	export QT_QPA_PLATFORM="xcb"
	export QT_QPA_PLATFORMTHEME="qt5ct"
fi

# Custom ID
export distro_id="$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | cut -d'"' -f2)"

if [ -z ${XDG_CURRENT_DESKTOP} ]; then
	export wm_de="$(echo $DESKTOP_SESSION | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
else
	export wm_de="$(echo $XDG_CURRENT_DESKTOP | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
fi
