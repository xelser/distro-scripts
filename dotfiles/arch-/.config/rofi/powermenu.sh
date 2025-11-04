#!/bin/bash

choice=$(printf "  Exit\n  Reboot\n  Shutdown" | \
  rofi -dmenu -p "Select:" -theme ~/.config/rofi/powermenu.rasi)

exit_command () {
  if [ "${XDG_CURRENT_DESKTOP}" = "i3" ]; then
    i3-msg exit
  elif [ "${XDG_CURRENT_DESKTOP}" = "sway" ]; then
    swaymsg exit
  fi
}

case "$choice" in
  "  Exit")      exit_command;;
  "  Reboot")    sudo systemctl reboot ;;
  "  Shutdown")  sudo systemctl poweroff ;;
  *)              notify-send -t 1800 "Cancelled";;
esac
