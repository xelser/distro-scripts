#!/bin/bash

# Apps
cat $HOME/.config/fav_apps.ini | dconf load /org/gnome/shell/
#cat $HOME/.config/extensions.ini | dconf load /org/gnome/shell/extensions/
dconf reset -f /org/gnome/desktop/app-folders/ && cat $HOME/.config/app_folders.ini | dconf load /org/gnome/desktop/app-folders/

# Tweaks
#gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:close'
#gsettings set org.gnome.desktop.wm.preferences focus-mode 'mouse'
gsettings set org.gnome.desktop.interface clock-show-weekday 'true'
gsettings set org.gnome.desktop.interface clock-show-date 'true'
gsettings set org.gnome.mutter center-new-windows 'true'

# Settings
gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.interface enable-hot-corners 'false'
gsettings set org.gnome.desktop.privacy remove-old-temp-files 'true'
gsettings set org.gnome.desktop.privacy remove-old-trash-files 'true'
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click 'true'
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled 'true'
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature '4700'
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden 'false'
gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first 'true'

# Apps
#gsettings set org.gnome.totem subtitle-font 'Roboto Medium 14'
#gsettings set org.gnome.eog.ui sidebar 'false'
gsettings set org.gnome.gnome-system-monitor current-tab 'resources'
gsettings set org.gnome.nautilus.window-state initial-size '(790, 580)'
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small-plus'
gsettings set org.gnome.nautilus.preferences show-delete-permanently 'true'
gsettings set org.gnome.Evince.Default fullscreen 'true'
gsettings set org.gnome.Evince.Default show-sidebar 'false'
gsettings set org.gnome.Evince.Default sizing-mode 'fit-width'
gsettings set org.gnome.TextEditor restore-session 'false'
gsettings set org.gnome.TextEditor style-scheme 'builder-dark'
gsettings set org.gnome.Console last-window-size '(737, 520)'
gsettings set org.gnome.Console theme 'auto'
gsettings set org.gnome.MultiWriter blank-drive 'false'
gsettings set org.gnome.MultiWriter enable-verify 'false'
gsettings set org.gnome.software download-updates 'false'
gsettings set org.gnome.software download-updates-notify 'false'
gsettings set org.gnome.builder.editor font-name 'Roboto Mono 10'
gsettings set org.gnome.builder.editor highlight-current-line 'true'
gsettings set org.gnome.builder.editor highlight-matching-brackets 'true'
gsettings set org.gnome.builder.editor style-scheme-name 'builder-dark'
gsettings set org.gnome.builder.editor wrap-text 'always'
gsettings set org.gnome.builder.spelling check-spelling "false"
gsettings set org.gnome.builder.terminal font-name 'Roboto Mono 10'
gsettings set io.github.celluloid-player.Celluloid dark-theme-enable 'false'
gsettings set io.github.celluloid-player.Celluloid mpv-options "hwdec=auto-safe sub-font='Roboto Mono' sub-font-size=30 sub-color='#FFFF00' slang=en,eng"

# GNOME Settings
gnome-control-center background
gnome-control-center sound