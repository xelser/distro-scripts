#!/bin/bash

check_flag () {
	[ ! -f /.flag ] && sudo cp -rf $1 $1.bak || sudo cp -rf $1.bak $1
}

################################ PREPARATIONS ################################

# Set to performance
[ -f /usr/bin/powerprofilesctl ] && powerprofilesctl list | grep -q performance && powerprofilesctl set performance

# Connect to Wifi
wget --spider --quiet http://google.com > /dev/null 2>&1 || if [[ ${machine} == "E5-476G" || "G41T-R3" ]]; then
	export wifidevice="58:AE:F1:36:7E:BC password A3jW3GBX"

	[ -f /usr/bin/nmcli ] && sudo nmcli device wifi connect ${wifidevice}
else
	[ -f /usr/bin/nmtui ] && sudo nmtui
fi

# Update Time (Enable Network Time)
sudo timedatectl set-ntp true

################################ POST INSTALL ################################

# Update User Dirs
[ -f /usr/bin/xdg-user-dirs-update ] && xdg-user-dirs-update
 
# Create Symlinks
if [[ $USER == "xelser" ]]; then
	[ ! -d $HOME/Documents/"xelser's Documents" ] && ln -sf /run/media/$USER/Media/Documents $HOME/Documents/"xelser's Documents"
	[ ! -d $HOME/Downloads/"xelser's Downloads" ] && ln -sf /run/media/$USER/Media/Downloads $HOME/Downloads/"xelser's Downloads"
	[ ! -d $HOME/Music/"xelser's Music" ]         && ln -sf /run/media/$USER/Media/Music     $HOME/Music/"xelser's Music"
	[ ! -d $HOME/Pictures/"xelser's Pictures" ]   && ln -sf /run/media/$USER/Media/Pictures  $HOME/Pictures/"xelser's Pictures"
	[ ! -d $HOME/Videos/"xelser's Videos" ]       && ln -sf /run/media/$USER/Media/Videos    $HOME/Videos/"xelser's Videos"
fi

# Essential Packages
if [ -f /usr/bin/nala ]; then sudo nala install --assume-yes ntfs-3g \
	flatpak neofetch nano htop zip un{zip,rar} tar ffmpeg ffmpegthumbnailer tumbler gvfs xdg-user-dirs dconf-editor \
	fonts-noto gtk2-engines-murrine gtk2-engines-pixbuf wget curl git openssh-client intel-media-va-driver i965-va-driver
elif [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm ntfs-3g \
	flatpak neofetch nano htop zip un{zip,rar} tar ffmpeg ffmpegthumbnailer tumbler gvfs xdg-user-dirs dconf-editor \
	noto-fonts-{cjk,emoji} gtk-engine-murrine gtk-engines wget curl git openssh libva-intel-driver intel-media-driver
elif [ -f /usr/bin/dnf5 ]; then sudo dnf5 install --assumeyes --best --allowerasing ntfs-3g \
	flatpak neofetch nano htop zip un{zip,rar} tar ffmpeg ffmpegthumbnailer tumbler gvfs xdg-user-dirs dconf-editor \
	google-noto-{cjk,emoji-color}-fonts gtk-murrine-engine gtk2-engines wget curl git openssh libva-intel-driver intel-media-driver
fi

# Audio
[ -f /usr/bin/easyeffects ] && [ -f $HOME/.config/easyeffects/output/default.json ] && easyeffects -l default
[ -f /usr/bin/pulseeffects ] && [ -f $HOME/.config/PulseEffects/output/default.json ] && pulseeffects -l default

# Flatpak
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/flatpak.sh)"

# Distro Post Install Script
[ -f $HOME/.config/${distro_id}-post.sh ] && bash $HOME/.config/${distro_id}-post.sh

# Fonts
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/x11_fonts.sh)"

# DE Post Install Script
[[ ${wm_de} == "gnome" ]] || [[ ${wm_de} == "cinnamon" ]] || [[ ${wm_de} == "xfce" ]] && \
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/${wm_de}_settings.sh)"

# rEFInd
#sudo dmesg | grep -q "EFI v" && [[ ${machine} == "E5-476G" ]] && \
#	bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/refind.sh)"

# openbox menu
[ -f /bin/obmenu-generator ] && obmenu-generator -p -i -u -d -c

# Hide Apps
name=(calf org.gnome.dspy org.gnome.Devhelp org.gnome.Sysprof lstopo htop avahi-discover bssh bvnc
	stoken-gui stoken-gui-small qv4l2 qvidcap pcmanfm-desktop-pref syncthing-start mpv)

for app in "${name[@]}"; do
	if [ -f /usr/share/applications/${app}.desktop ]; then mkdir -p $HOME/.local/share/applications/
		cp -rf /usr/share/applications/${app}.desktop $HOME/.local/share/applications/${app}.desktop
		echo "NoDisplay=true" >> $HOME/.local/share/applications/${app}.desktop
	fi
done

# daemons
[ -f /usr/bin/ulauncher ] && systemctl enable --user ulauncher
[ -f /usr/bin/syncthing ] && systemctl enable --user syncthing
[ -f /usr/bin/transmission-daemon ] && transmission-daemon

################################### THEMES ###################################

# General Theming
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/theming.sh)"

# Darkman
[ -f /usr/bin/darkman ] && systemctl --user enable --now darkman

# KDE configs (konsave)
[ -f /usr/bin/konsave ] && konsave -a defaults 2>/dev/null

# Nitrogen
[ -f /bin/nitrogen ] && nitrogen --restore

# Waypaper
[ -f /bin/waypaper ] && waypaper --restore

# Plank
if [ -f /usr/bin/plank ] && [ -f $HOME/.config/plank/plank.ini ]; then
	cat $HOME/.config/plank/plank.ini | dconf load /net/launchpad/plank/
	dconf write /net/launchpad/plank/enabled-docks "['dock2']"
fi

# Geany
if [ -f /bin/geany ]; then
	cd /tmp/ && rm -rf geany-themes && git clone https://github.com/geany/geany-themes
	cd geany-themes && ./install.sh 1> /dev/null
fi

# LibreOffice Papirus Icon Theme
if [ -f /bin/libreoffice ]; then
	wget -qO- https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-libreoffice-theme/master/install-papirus-root.sh | sh
fi

##################################### END ####################################

# Flag end of installation
sudo touch /.flag

# Housekeeping
if   [ -f /usr/bin/yay ]; then
	yay -Qtdq | yay -Rnsu - --noconfirm 1> /dev/null
	yay -Sc --noconfirm
elif [ -f /usr/bin/pacman ]; then
	sudo pacman -Qtdq | sudo pacman -Rnsu - --noconfirm 1> /dev/null
	sudo pacman -Sc --noconfirm
elif [ -f /usr/bin/nala ]; then
	sudo nala autoremove --purge --assume-yes
	sudo nala clean
elif [ -f /usr/bin/apt ]; then
	sudo apt autoremove --purge --yes
	sudo apt autoclean
elif [ -f /usr/bin/dnf ]; then
	sudo dnf autoremove --assumeyes
	sudo dnf clean all
fi

[ -f /usr/bin/flatpak ] && flatpak uninstall --unused --delete-data --assumeyes

# Profile
if [[ ${wm_de} == "cinnamon" ]]; then
	cinnamon-settings user >&/dev/null
elif [[ ${wm_de} == "gnome" ]]; then
	gnome-control-center system >&/dev/null
	cp -rf /var/lib/AccountsService/icons/$USER $HOME/.face
elif [[ ${wm_de} == "kde" ]]; then
	systemsettings kcm_users >&/dev/null
	cp -rf /var/lib/AccountsService/icons/$USER $HOME/.face
else
	mugshot >&/dev/null
fi

# Logout
logout () {
if [[ ${wm_de} == "gnome" ]]; then	
	gnome-session-quit --force
elif [[ ${wm_de} == "cinnamon" ]]; then
	cinnamon-session-quit --logout --force
elif [[ ${wm_de} == "xfce" ]]; then
	xfce4-session-logout --logout --fast 
elif [[ ${wm_de} == "kde" ]]; then
	qdbus org.kde.ksmserver /KSMServer logout 0 0 2
elif [[ ${wm_de} == "i3" ]]; then
	i3-msg exit
fi

}

if [ $? -eq 0 ]; then
	echo && read -p "Logout? (Y/n): " end
	case $end in
	   n)	echo "Logout Cancelled";;
	   *)	echo "Logging out... "
	   	rm $HOME/.config/${distro_id}-post.sh
	   	rm $HOME/.config/post.sh
	   	logout;;
	esac
else echo "Error Detected. Logout Cancelled"
fi
