#!/bin/bash

# Settings
xfconf-query -cn xsettings -pn /Gtk/ButtonImages -t bool -s "false"
xfconf-query -cn xsettings -pn /Xft/HintStyle -t string -s "hintslight"
xfconf-query -cn xsettings -pn /Xft/RGBA -t string -s "rgb"
xfconf-query -cn xfwm4 -pn /general/borderless_maximize -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/button_layout -t string -s "|HMC"
xfconf-query -cn xfwm4 -pn /general/frame_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/inactive_opacity -t int -s "100"
#xfconf-query -cn xfwm4 -pn /general/margin_bottom -t int -s "40"
#xfconf-query -cn xfwm4 -pn /general/margin_left -t int -s "10"
#xfconf-query -cn xfwm4 -pn /general/margin_right -t int -s "10"
#xfconf-query -cn xfwm4 -pn /general/margin_top -t int -s "10"
xfconf-query -cn xfwm4 -pn /general/move_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/placement_ratio -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/popup_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/resize_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/scroll_workspaces -t bool -s "true"
xfconf-query -cn xfwm4 -pn /general/show_dock_shadow -t bool -s "true"
xfconf-query -cn xfwm4 -pn /general/show_popup_shadow -t bool -s "true"
xfconf-query -cn xfwm4 -pn /general/title_alignment -t string -s "center"
xfconf-query -cn xfwm4 -pn /general/vblank_mode -t string -s "glx"
xfconf-query -cn xfwm4 -pn /general/wrap_cycle -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/wrap_windows -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/workspace_count -t int -s "1"
xfconf-query -cn xfwm4 -pn /general/workspace_names -t string -t string -t string -t string -s "1" -s "2" -s "3" -s "4"
xfconf-query -cn xfce4-desktop -pn /desktop-icons/style -t int -s "0"
xfconf-query -cn xfce4-keyboard-shortcuts -pn /commands/custom/\<Super\>Return -t string -s "exo-open --launch TerminalEmulator"
xfconf-query -cn xfce4-keyboard-shortcuts -pn /commands/custom/\<Super\>e -t string -s "exo-open --launch FileManager"
xfconf-query -cn xfce4-keyboard-shortcuts -pn /commands/custom/\<Super\>d -t string -s "xfce4-appfinder"
xfconf-query -cn xfce4-notifyd -pn /do-slideout -t bool -s "true"
xfconf-query -cn xfce4-notifyd -pn /initial-opacity -t double -s "0.95"
xfconf-query -cn xfce4-notifyd -pn /notify-location -t uint -s "3"
xfconf-query -cn xfce4-power-manager -pn /xfce4-power-manager/blank-on-ac -t int -s "0"
xfconf-query -cn xfce4-power-manager -pn /xfce4-power-manager/lid-action-on-ac -t uint -s "1"
xfconf-query -cn xfce4-power-manager -pn /xfce4-power-manager/lid-action-on-battery -t uint -s "1"
xfconf-query -cn xfce4-power-manager -pn /xfce4-power-manager/logind-handle-lid-switch -t bool -s "true"
xfconf-query -cn xfce4-session -pn /general/SaveOnExit -t bool -s "false"
xfconf-query -cn xfce4-appfinder -pn /sort-by-frecency -t bool -s "true"

# Apps
xfconf-query -cn xfce4-terminal -pn /background-darkness -t double -s "0.9750"
xfconf-query -cn xfce4-terminal -pn /background-mode -t string -s "TERMINAL_BACKGROUND_TRANSPARENT"
xfconf-query -cn xfce4-terminal -pn /font-allow-bold -t bool -s "true"
xfconf-query -cn xfce4-terminal -pn /misc-cursor-blinks -t bool -s "true"
xfconf-query -cn xfce4-terminal -pn /misc-cursor-shape -t string -s "TERMINAL_CURSOR_SHAPE_IBEAM"
xfconf-query -cn xfce4-terminal -pn /misc-default-geometry -t string -s "90x26"
xfconf-query -cn xfce4-terminal -pn /misc-menubar-default -t bool -s "false"
xfconf-query -cn xfce4-terminal -pn /overlay-scrolling -t bool -s "true"
xfconf-query -cn xfce4-terminal -pn /misc-show-unsafe-paste-dialog -t bool -s "false"
xfconf-query -cn thunar -pn /last-location-bar -t string -s "ThunarLocationButtons"
#xfconf-query -cn thunar -pn /last-menubar-visible -t bool -s "false"
xfconf-query -cn thunar -pn /misc-directory-specific-settings -t bool -s "true"
xfconf-query -cn thunar -pn /misc-parallel-copy-mode -t string -s "THUNAR_PARALLEL_COPY_MODE_ALWAYS"
xfconf-query -cn thunar -pn /misc-show-delete-action -t bool -s "true"
xfconf-query -cn thunar-volman -pn /automount-drives/enabled -t bool -s "true"
xfconf-query -cn thunar-volman -pn /automount-media/enabled -t bool -s "true"
xfconf-query -cn ristretto -pn /window/statusbar/show -t bool -s "false"
xfconf-query -cn ristretto -pn /window/thumbnails/show -t bool -s "false"
xfconf-query -cn ristretto -pn /window/toolbar/show -t bool -s "false"
xfconf-query -cn parole -pn /parole/plugins -t string -s "parole-notify.so"
dconf write /org/mate/Atril/Default/show-sidebar 'false'
dconf write /org/mate/Atril/Default/show-toolbar 'false'
dconf write /org/xfce/mousepad/preferences/view/auto-indent 'true'
dconf write /org/xfce/mousepad/preferences/view/highlight-current-line 'true'
dconf write /org/xfce/mousepad/preferences/view/match-braces 'true'
dconf write /org/xfce/mousepad/preferences/view/tab-width '2'
dconf write /org/xfce/mousepad/preferences/view/word-wrap 'true'
dconf write /org/xfce/mousepad/preferences/window/statusbar-visible 'true'

# Panel
xfce4-panel-profiles load "$HOME/.config/xfce4-panel-backups/my-panel.tar.bz2"

#if [[ ${machine} == "E5-476G" ]]; then
#	xfconf-query -cn pointers -pn /ELAN050100_04F3305B_Touchpad/Acceleration -t double -s "5.0000"
#  xfconf-query -cn pointers -pn /ELAN050100_04F3305B_Touchpad/ReverseScrolling -t bool -s "true"
#fi
