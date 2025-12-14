#!/bin/bash

# Settings
gsettings set org.cinnamon desklet-decorations '0'
gsettings set org.cinnamon.desktop.interface clock-use-24h 'false'
gsettings set org.cinnamon.desktop.media-handling autorun-never 'false'
gsettings set org.cinnamon.desktop.notifications bottom-notifications 'true'
gsettings set org.cinnamon.desktop.peripherals.touchpad send-events 'disabled-on-external-mouse'
gsettings set org.cinnamon.desktop.screensaver use-custom-format 'true'
gsettings set org.cinnamon.desktop.screensaver time-format '%I:%M %p'
gsettings set org.cinnamon.desktop.wm.preferences button-layout ':minimize,maximize,close'
gsettings set org.cinnamon.muffin placement-mode 'center'
gsettings set org.cinnamon.settings-daemon.peripherals.keyboard numlock-state 'on'
gsettings set org.cinnamon.settings-daemon.plugins.color night-light-enabled 'true'
gsettings set org.cinnamon.settings-daemon.plugins.color night-light-temperature '5800'

# Apps
gsettings set org.cinnamon.recorder file-extension 'mp4'
gsettings set org.cinnamon.recorder framerate '60'
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar 'false'
gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'
gsettings set org.nemo.desktop desktop-layout 'false::false'
gsettings set org.nemo.preferences show-hidden-files 'false'
gsettings set org.nemo.window-state geometry '683x545+153+96'
gsettings set org.nemo.window-state start-with-menu-bar 'false'
gsettings set org.x.editor.preferences.ui menubar-visible 'false'
gsettings set org.x.editor.preferences.ui toolbar-visible 'false'
gsettings set org.x.editor.preferences.editor tabs-size '2'
gsettings set org.x.editor.preferences.editor insert-spaces 'false'
gsettings set org.x.reader show-menubar 'false'
gsettings set org.x.reader show-toolbar 'false'
gsettings set org.x.viewer.ui toolbar 'false'
gsettings set org.x.warpinator.preferences receiving-folder 'file:///media/Media/Shared'
gsettings set io.github.celluloid-player.Celluloid dark-theme-enable 'false'
gsettings set io.github.celluloid-player.Celluloid mpv-options "hwdec=auto-safe sub-font='Ubuntu Mono' sub-font-size=30 sub-color='#FFFF00' slang=en,eng"

#################################### Config ####################################

# Bookmarks
#cat << EOF >> $HOME/.config/gtk-3.0/bookmarks
#file:///home/xelser/.config .config
#file:///home/xelser/.local .local
#file:///home/xelser/Documents/distro-scripts distro-scripts
#EOF

# GNOME Backgrounds
#cd /tmp/ && git clone https://github.com/xelser/gnome-backgrounds-day-night
#cp -rf gnome-backgrounds-day-night/{backgrounds,gnome-background-properties} $HOME/.local/share/

# GNOME Terminal Profile
cat $HOME/.config/gnome-terminal-profile | dconf load /org/gnome/terminal/legacy/profiles:/

# Cinnamon Panel
cat $HOME/.config/panel.ini | dconf load /org/cinnamon/

