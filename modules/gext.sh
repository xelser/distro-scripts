#!/bin/bash

# Install PipX
if [ ! -f /usr/bin/gext ]; then
	if [ -f /usr/bin/nala ]; then sudo nala install --assume-yes \
		pipx libayatana-appindicator3-1 gir1.2-{gda-5,gsound-1}.0
	elif [ -f /usr/bin/dnf ]; then sudo dnf install --assumeyes \
		pipx libappindicator-gtk3 libgda{,-sqlite}
	fi

	# Install gnome-extensions-cli
	[ -f /usr/bin/pipx ] && pipx ensurepath && bash -c "pipx install gnome-extensions-cli --system-site-packages --force"
fi

# Install Extensions
gext --filesystem install 615 # appindicator
gext --filesystem install 6670 # bluetooth-battery-meter
gext --filesystem install 517 # caffeine
gext --filesystem install 307 # dash-to-dock
gext --filesystem install 4481 # forge
gext --filesystem install 4158 # gnome-ui-tune
gext --filesystem install 4691 # pip-on-top
gext --filesystem install 8 # places-menu

#gext --filesystem install 3928 # autoselectheadset
#gext --filesystem install 5237 # rounded-window-corners (no update)
	# pano@elhan.io

# Install Manually (DBus)
gext install 595 # autohide-battery
gext install 1401 # bluetooth-quick-connect
gext install 3193 # blur-my-shell
gext install 4269 # AlphabeticalAppGrid
gext install 3843 # just-perfection
#gext install 2236 # night-theme-switcher (bugged)
gext install 5575 # power-profile-switcher
gext install 352 # middleclickclose

# Extensions Configs
dconf write /org/gnome/shell/extensions/bluetooth-quick-connect/refresh-button-on "true"
dconf write /org/gnome/shell/extensions/blur-my-shell/brightness "0.4"
dconf write /org/gnome/shell/extensions/blur-my-shell/sigma "20"
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/blur "false"
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/force-light-text "true"
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/override-background-dynamically "true"
dconf write /org/gnome/shell/extensions/caffeine/inhibit-apps "['io.github.celluloid_player.Celluloid.desktop', 'org.mozilla.firefox.desktop', 'com.google.Chrome.desktop', 'firefox']"
dconf write /org/gnome/shell/extensions/caffeine/show-notifications "false"
dconf write /org/gnome/shell/extensions/dash-to-dock/apply-custom-theme "true"
dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-shrink "true"
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size "38"
dconf write /org/gnome/shell/extensions/dash-to-dock/height-fraction "1.0"
dconf write /org/gnome/shell/extensions/dash-to-dock/show-mounts "false"
dconf write /org/gnome/shell/extensions/dash-to-dock/show-trash "false"
dconf write /org/gnome/shell/extensions/forge/float-always-on-top-enabled "false"
dconf write /org/gnome/shell/extensions/forge/focus-border-toggle "false"
dconf write /org/gnome/shell/extensions/forge/move-pointer-focus-enabled "false"
dconf write /org/gnome/shell/extensions/forge/window-gap-size "3"
dconf write /org/gnome/shell/extensions/gnome-ui-tune/always-show-thumbnails "false"
#dconf write /org/gnome/shell/extensions/just-perfection/weather "false"
dconf write /org/gnome/shell/extensions/just-perfection/window-demands-attention-focus "true"
#dconf write /org/gnome/shell/extensions/just-perfection/world-clock "false"
dconf write /org/gnome/shell/extensions/middleclickclose/close-button "'right'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/enabled 'true'
dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/sunrise "'bash $HOME/.local/share/light-mode.d/light.sh'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/sunset "'bash $HOME/.local/share/dark-mode.d/dark.sh'"
#dconf write /org/gnome/shell/extensions/pip-on-top/stick "true"
#dconf write /org/gnome/shell/extensions/pop-shell/tile-by-default "true"
