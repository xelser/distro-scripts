
# Check whether if the windowing system is Xorg or Wayland
if [[ ${XDG_SESSION_TYPE} == "wayland" ]]; then
	export MOZ_ENABLE_WAYLAND=1
	export OBS_USE_EGL=1
fi

# QT/Kvantum theme
if [ -f /usr/bin/qt5ct ]; then
	export QT_QPA_PLATFORM="xcb"
	export QT_QPA_PLATFORMTHEME="qt5ct"
fi
