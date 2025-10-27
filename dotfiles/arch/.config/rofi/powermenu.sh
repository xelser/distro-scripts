#!/bin/bash

choice=$(printf "  Exit i3\n  Reboot\n  Shutdown" | \
  rofi -dmenu -p "Select:" -theme ~/.config/rofi/powermenu.rasi)

case "$choice" in
  "  Exit i3")    i3-msg exit ;;
  "  Reboot")     sudo systemctl reboot ;;
  "  Shutdown")   sudo systemctl poweroff ;;
  *)               notify-send -t 1800 "Cancelled" ;;
esac
