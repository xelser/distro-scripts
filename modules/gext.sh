#!/bin/bash

# Install PipX
if [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm \
	python-pipx libappindicator-gtk{2,3} libgda
elif [ -f /usr/bin/nala ]; then sudo nala install --assume-yes \
	pipx libayatana-appindicator3-1 gir1.2-{gda-5,gsound-1}.0
elif [ -f /usr/bin/dnf ]; then sudo dnf install --assumeyes \
	pipx libappindicator-gtk3 libgda{,-sqlite}
fi

# Install gnome-extensions-cli
pipx ensurepath && bash -c "pipx install gnome-extensions-cli --system-site-packages --force"

# Install Extensions
gext --filesystem install 4269 # AlphabeticalAppGrid
gext --filesystem install 615 # appindicator
gext --filesystem install 595 # autohide-battery
gext --filesystem install 1401 # bluetooth-quick-connect
gext --filesystem install 3193 # blur-my-shell
gext --filesystem install 517 # caffeine
gext --filesystem install 307 # dash-to-dock
gext --filesystem install 4481 # forge
gext --filesystem install 4158 # gnome-ui-tune
gext --filesystem install 3843 # just-perfection
gext --filesystem install 8 # places-menu
gext --filesystem install 5575 # power-profile-switcher
gext --filesystem install 352 # middleclickclose
gext --filesystem install 5237 # rounded-window-corners
gext --filesystem install 701 # scroll-workspaces
	# pano@elhan.io

# Extensions Configs
dconf write /org/gnome/shell/extensions/bluetooth-quick-connect/refresh-button-on "true"
dconf write /org/gnome/shell/extensions/blur-my-shell/brightness "0.4"
dconf write /org/gnome/shell/extensions/blur-my-shell/sigma "20"
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/override-background-dynamically "true"
dconf write /org/gnome/shell/extensions/caffeine/restore-state 'true'
dconf write /org/gnome/shell/extensions/caffeine/toggle-state 'true'
dconf write /org/gnome/shell/extensions/caffeine/user-enabled 'true'
dconf write /org/gnome/shell/extensions/dash-to-dock/apply-custom-theme "true"
dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-shrink "true"
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size "38"
dconf write /org/gnome/shell/extensions/dash-to-dock/height-fraction "1.0"
dconf write /org/gnome/shell/extensions/dash-to-dock/show-mounts "false"
dconf write /org/gnome/shell/extensions/dash-to-dock/show-trash "false"
dconf write /org/gnome/shell/extensions/forge/float-always-on-top-enabled "false"
dconf write /org/gnome/shell/extensions/forge/focus-border-toggle "false"
dconf write /org/gnome/shell/extensions/forge/window-gap-size "3"
dconf write /org/gnome/shell/extensions/gnome-ui-tune/always-show-thumbnails "false"
#dconf write /org/gnome/shell/extensions/just-perfection/weather "false"
dconf write /org/gnome/shell/extensions/just-perfection/window-demands-attention-focus "true"
#dconf write /org/gnome/shell/extensions/just-perfection/world-clock "false"
dconf write /org/gnome/shell/extensions/middleclickclose/close-button "'right'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/enabled 'true'
#dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/sunrise "'bash $HOME/.local/share/light-mode.d/switch.sh'"
#dconf write /org/gnome/shell/extensions/nightthemeswitcher/commands/sunset "'bash $HOME/.local/share/dark-mode.d/switch.sh'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/cursor-variants/enabled "true"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/cursor-variants/day "'Bibata-Modern-Classic'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/cursor-variants/night "'Bibata-Modern-Ice'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/gtk-variants/enabled "true"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/gtk-variants/day "'adw-gtk3'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/gtk-variants/night "'adw-gtk3-dark'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/icon-variants/enabled "true"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/icon-variants/day "'Tela-circle'"
dconf write /org/gnome/shell/extensions/nightthemeswitcher/icon-variants/night "'Tela-circle-dark'"
#dconf write /org/gnome/shell/extensions/pop-shell/tile-by-default "true"

# Install Manually (DBus)
gext install nightthemeswitcher@romainvigier.fr
