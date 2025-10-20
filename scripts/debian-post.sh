#!/bin/bash

################################ POST INSTALL ################################

# debloat
sudo apt autoremove --purge --yes zutty xterm

# jellyfin
#curl -s https://repo.jellyfin.org/install-debuntu.sh | sudo bash
sudo apt install --yes intel-media-va-driver-non-free libvpl2 libvpl-tools vainfo

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# brave browser
curl -fsS https://dl.brave.com/install.sh | sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/brave_flags.sh)"

# nvidia and envycontrol
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/debian_nvidia.sh)"

################################### THEMES ###################################

# install themes
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/grub.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-sainnhe-capitaine.sh)"

# set fonts
dconf write /org/gnome/desktop/interface/font-name "'Roboto Medium 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'JetBrainsMono Nerd Font 9'"

# text editor (pluma)
gsettings set org.mate.pluma color-scheme 'gruvbox-material-medium-dark'
gsettings set org.mate.pluma display-line-numbers true
gsettings set org.mate.pluma editor-font 'JetBrainsMono Nerd Font 10'
gsettings set org.mate.pluma highlight-current-line true
gsettings set org.mate.pluma toolbar-visible false
gsettings set org.mate.pluma use-default-font false

# separate apps
wayapp=(footclient foot foot-server)

for app in "${wayapp[@]}"; do
	if [ -f /usr/share/applications/${app}.desktop ]; then
		mkdir -p $HOME/.local/share/applications/
		cp -rf /usr/share/applications/${app}.desktop \
			$HOME/.local/share/applications/${app}.desktop
		echo "OnlyShowIn=Sway;" >> $HOME/.local/share/applications/${app}.desktop
	fi
done

x11app=(picom lxrandr timeshift-gtk gparted)

for app in "${x11app[@]}"; do
	if [ -f /usr/share/applications/${app}.desktop ]; then
		mkdir -p $HOME/.local/share/applications/
		cp -rf /usr/share/applications/${app}.desktop \
			$HOME/.local/share/applications/${app}.desktop
		echo "OnlyShowIn=i3;" >> $HOME/.local/share/applications/${app}.desktop
	fi
done
