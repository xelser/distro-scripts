#!/bin/bash

cd /tmp/ ; sudo rm -rf /tmp/salientos-* /usr/share/backgrounds/salientos
git clone https://github.com/salientos/salientos-wallpapers-xfce.git
sudo cp -rf /tmp/salientos-wallpapers-xfce/usr/share/backgrounds/salientos/ /usr/share/backgrounds/
