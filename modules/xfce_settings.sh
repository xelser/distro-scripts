#!/bin/bash

# Settings
xfconf-query -cn xsettings -pn /Gtk/ButtonImages -t bool -s "false"
xfconf-query -cn xsettings -pn /Xft/HintStyle -t string -s "hintslight"
xfconf-query -cn xsettings -pn /Xft/RGBA -t string -s "rgb"
#xfconf-query -cn xfwm4 -pn /general/borderless_maximize -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/button_layout -t string -s "|HMC"
xfconf-query -cn xfwm4 -pn /general/frame_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/inactive_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/margin_bottom -t int -s "10"
xfconf-query -cn xfwm4 -pn /general/margin_left -t int -s "10"
xfconf-query -cn xfwm4 -pn /general/margin_right -t int -s "10"
xfconf-query -cn xfwm4 -pn /general/margin_top -t int -s "36"
xfconf-query -cn xfwm4 -pn /general/move_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/placement_ratio -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/popup_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/resize_opacity -t int -s "100"
xfconf-query -cn xfwm4 -pn /general/scroll_workspaces -t bool -s "true"
xfconf-query -cn xfwm4 -pn /general/show_dock_shadow -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/show_popup_shadow -t bool -s "true"
xfconf-query -cn xfwm4 -pn /general/title_alignment -t string -s "center"
#xfconf-query -cn xfwm4 -pn /general/vblank_mode -t string -s "glx"
xfconf-query -cn xfwm4 -pn /general/wrap_cycle -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/wrap_windows -t bool -s "false"
xfconf-query -cn xfwm4 -pn /general/workspace_names -t string -t string -t string -t string -s "1" -s "2" -s "3" -s "4"
xfconf-query -cn xfce4-desktop -pn /desktop-icons/style -t int -s "0"
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
dconf write /org/mate/Atril/Default/show-sidebar 'false'
dconf write /org/mate/Atril/Default/show-toolbar 'false'
dconf write /org/xfce/mousepad/preferences/view/auto-indent 'true'
dconf write /org/xfce/mousepad/preferences/view/highlight-current-line 'true'
dconf write /org/xfce/mousepad/preferences/view/match-braces 'true'
dconf write /org/xfce/mousepad/preferences/view/word-wrap 'true'
dconf write /org/xfce/mousepad/preferences/window/statusbar-visible 'true'

if [[ ${machine} == "E5-476G" ]]; then
	xfconf-query -cn pointers -pn /ELAN050100_04F3305B_Touchpad/Acceleration -t double -s "5.0000"
        xfconf-query -cn pointers -pn /ELAN050100_04F3305B_Touchpad/ReverseScrolling -t bool -s "true"
fi
