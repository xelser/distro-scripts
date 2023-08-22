#!/bin/bash

############################ XFCONF/DCONF/GSETTINGS ############################

if [[ ${wm_de} == "xfce" ]]; then

# Reset
for channel in $(xfconf-query -l | grep -v ':' | tr -d "[:blank:]")
do
    for property in $(xfconf-query -l -c $channel)
    do
        xfconf-query -c $channel -r -p $property
    done
done

# Settings
xfconf-query -cn xsettings -pn /Gtk/ButtonImages -t bool -s "false"
#xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "Adwaita"
xfconf-query -cn xsettings -pn /Gtk/FontName -t string -s "Noto Sans 10"
xfconf-query -cn xsettings -pn /Gtk/MonospaceFontName -t string -s "NotoMono Nerd Font 10"
xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Dark"
xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Gruvbox-Dark-BL"
xfconf-query -cn xsettings -pn /Xft/HintStyle -t string -s "hintslight"
xfconf-query -cn xsettings -pn /Xft/RGBA -t string -s "rgb"
#xfconf-query -cn xfwm4 -pn /general/borderless_maximize -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/button_layout -t string -s "|HMC"
xfconf-query -cn xfwm4 -pn /general/frame_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/inactive_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/margin_bottom -t int -s "10"
xfconf-query -cn xfwm4 -pn /general/margin_left -t int -s "10"
xfconf-query -cn xfwm4 -pn /general/margin_right -t int -s "10"
xfconf-query -cn xfwm4 -pn /general/margin_top -t int -s "52"
xfconf-query -cn xfwm4 -pn /general/move_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/placement_ratio -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/popup_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/resize_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/scroll_workspaces -t bool -s "true"
xfconf-query -cn xfwm4 -pn /general/show_dock_shadow -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/show_popup_shadow -t bool -s "true"
xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Gruvbox-Dark-BL"
xfconf-query -cn xfwm4 -pn /general/title_alignment -t string -s "center"
xfconf-query -cn xfwm4 -pn /general/title_font -t string -s "Noto Sans 10"
#xfconf-query -cn xfwm4 -pn /general/vblank_mode -t string -s "glx"
xfconf-query -cn xfwm4 -pn /general/wrap_cycle -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/wrap_windows -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/workspace_names -t string -t string -t string -t string -s "1" -s "2" -s "3" -s "4"
xfconf-query -cn xfce4-keyboard-shortcuts -pn /commands/custom/\<Super\>Return -t string -s "xfce4-terminal"
xfconf-query -cn xfce4-keyboard-shortcuts -pn /commands/custom/\<Super\>r -t string -s "xfce4-appfinder"
#xfconf-query -cn xfce4-notifyd -pn /do-slideout -t bool -s "true"
xfconf-query -cn xfce4-notifyd -pn /initial-opacity -t double -s "0.95"
xfconf-query -cn xfce4-notifyd -pn /notify-location -t uint -s "3"
xfconf-query -cn xfce4-session -pn /general/SaveOnExit -t bool -s "false"

# Apps
xfconf-query -cn thunar -pn /last-location-bar -t string -s "ThunarLocationButtons"
#xfconf-query -cn thunar -pn /last-menubar-visible -t bool -s "false"
#xfconf-query -cn thunar -pn /last-show-hidden -t bool -s "false"
#xfconf-query -cn thunar -pn /last-window-height -t int -s "531"
#xfconf-query -cn thunar -pn /last-window-width -t int -s "865"
xfconf-query -cn thunar -pn /misc-directory-specific-settings -t bool -s "true"
xfconf-query -cn thunar -pn /misc-parallel-copy-mode -t string -s "THUNAR_PARALLEL_COPY_MODE_ALWAYS"
xfconf-query -cn thunar -pn /misc-show-delete-action -t bool -s "true"
xfconf-query -cn thunar-volman -pn /automount-drives/enabled -t bool -s "true"
xfconf-query -cn thunar-volman -pn /automount-media/enabled -t bool -s "true"
xfconf-query -cn ristretto -pn /window/statusbar/show -t bool -s "false"
xfconf-query -cn ristretto -pn /window/thumbnails/show -t bool -s "false"
xfconf-query -cn ristretto -pn /window/toolbar/show -t bool -s "false"
xfconf-query -cn parole -pn /parole/plugins -t string -s "parole-notify.so"
xfconf-query -cn parole -pn /subtitles/font -t string -s "Noto Sans Bold 10"
dconf write /org/mate/Atril/Default/show-sidebar 'false'
dconf write /org/mate/Atril/Default/show-toolbar 'false'
dconf write /org/xfce/mousepad/preferences/view/auto-indent 'true'
dconf write /org/xfce/mousepad/preferences/view/color-scheme "'gruvbox-soft'"
dconf write /org/xfce/mousepad/preferences/view/font-name "'NotoMono Nerd Font 10'"
dconf write /org/xfce/mousepad/preferences/view/highlight-current-line 'true'
dconf write /org/xfce/mousepad/preferences/view/match-braces 'true'
dconf write /org/xfce/mousepad/preferences/view/word-wrap 'true'
dconf write /org/xfce/mousepad/preferences/window/statusbar-visible 'true'

if [[ ${machine} == "E5-476G" ]]; then
        xfconf-query -cn pointers -pn /ELAN050100_04F3305B_Touchpad/Acceleration -t double -s "5.0000"
        xfconf-query -cn pointers -pn /ELAN050100_04F3305B_Touchpad/Properties/libinput_Tapping_Enabled -t int -s "1"
        xfconf-query -cn pointers -pn /ELAN050100_04F3305B_Touchpad/ReverseScrolling -t bool -s "true"
fi


elif [[ ${wm_de} == "cinnamon" ]]; then

# Themes
gsettings set org.cinnamon.theme name 'vimix-dark-compact-beryl'
gsettings set org.cinnamon.desktop.wm.preferences theme 'vimix-dark-compact-beryl'
gsettings set org.cinnamon.desktop.interface gtk-theme 'vimix-dark-compact-beryl'
gsettings set org.cinnamon.desktop.interface icon-theme 'Vimix-beryl-dark'
gsettings set org.cinnamon.desktop.interface cursor-theme 'Vimix-white-cursors'
gsettings set org.cinnamon.desktop.interface font-name 'Noto Sans 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'NotoMono Nerd Font 10'

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
#gsettings set org.cinnamon.settings-daemon.peripherals.keyboard numlock-state 'on'

# Apps
gsettings set org.cinnamon.recorder file-extension 'mp4'
gsettings set org.cinnamon.recorder framerate '60'
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar 'false'
gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'
#gsettings set org.gnome.builder style-variant 'dark'
#gsettings set org.gnome.builder.editor style-scheme-name 'Adwaita-dark'
#gsettings set org.gnome.builder.editor font-name 'NotoMono Nerd Font 11'
#gsettings set org.gnome.builder.terminal font-name 'NotoMono Nerd Font 11'
gsettings set org.nemo.desktop desktop-layout 'false::false'
gsettings set org.nemo.preferences show-hidden-files 'false'
gsettings set org.nemo.window-state geometry '683x545+153+96'
gsettings set org.nemo.window-state start-with-menu-bar 'false'
#gsettings set org.x.editor.plugins active-plugins "['spell', 'docinfo', 'time', 'modelines', 'joinlines', 'filebrowser', 'textsize', 'open-uri-context-menu', 'sort']"
gsettings set org.x.editor.preferences.ui menubar-visible 'false'
gsettings set org.x.editor.preferences.ui toolbar-visible 'false'
gsettings set org.x.editor.preferences.editor tabs-size '8'
gsettings set org.x.editor.preferences.editor insert-spaces 'false'
#gsettings set org.x.editor.preferences.editor scheme 'Adwaita-dark'
gsettings set org.x.reader show-menubar 'false'
gsettings set org.x.reader show-toolbar 'false'
gsettings set org.x.viewer.ui toolbar 'false'
#gsettings set org.x.viewer.plugins active-plugins "['light-theme']"
gsettings set org.x.warpinator.preferences receiving-folder 'file:///media/Media/Shared'

################################### Cinnamon ###################################

# GNOME Backgrounds
cd /tmp/ && git clone https://github.com/xelser/gnome-backgrounds-day-night
cp -rf gnome-backgrounds-day-night/{backgrounds,gnome-background-properties} $HOME/.local/share/

# GNOME Terminal Profile
cat $HOME/.config/gnome-terminal-profile | dconf load /org/gnome/terminal/legacy/profiles:/

# Cinnamon Panel
cat $HOME/.config/panel.ini | dconf load /org/cinnamon/

# Cinnamon Sound Settings
cinnamon-settings sound

fi

##################################### POST #####################################

# INSTALL: gaming, darkman, stylepak
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/gaming.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/darkman.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/stylepak.sh)"

# stylepak
stylepak install-system vimix-compact-beryl
stylepak install-system vimix-dark-compact-beryl
