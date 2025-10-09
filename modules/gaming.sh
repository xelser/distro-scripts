#!/bin/bash

# Install: Steam, Gamemode & MangoHud
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm \
	steam lutris gamescope {lib32-,}gamemode {lib32-,}mangohud

[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes \
	steam lutris gamescope gamemode{,.i686} mangohud{,.i686}

[ -f /usr/bin/apt ] && sudo apt install --yes \
	steam lutris gamescope gamemode{,:i386} mangohud

# Install: Lutris Wine Deps
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/lutris_wine_dep.sh)"

################################### FLATPAK ##################################

# Install (Flatpak) : Lutris & MangoHud
# flatpak install --assumeyes --noninteractive flathub \
#	org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/23.08 \
#	net.lutris.Lutris

# MangoHud Config File
#flatpak override --user --filesystem=xdg-config/MangoHud:ro
#if [[ ${machine} == "E5-476G" ]]; then
#	flatpak override --user --filesystem=/run/media/$USER/Games:rw
#	flatpak override --user --filesystem=/run/media/$USER/Shared:rw
#fi

################################### CONFIG ###################################

# Steam with MangoHud (some games may not launch at all)
#cp -r /usr/share/applications/steam.desktop $HOME/.local/share/applications/
#sed -i s"/\/usr\/bin\/steam-runtime/mangohud \/usr\/bin\/steam-runtime/"g $HOME/.local/share/applications/steam.desktop

# Gamemode
sudo usermod -aG gamemode $(whoami)

