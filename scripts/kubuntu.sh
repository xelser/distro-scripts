#!/bin/bash
set -e
clear

user="axel"

################################ Packages #################################

# Debloat
apt autoremove --purge -y \
  partitionmanager
    
# Update
apt update
apt upgrade -y
apt full-upgrade -y

# Install
apt install -y \
  htop neofetch gparted gnome-disk-utility timeshift \
  ktorrent qt5-style-kvantum lxappearance latte-dock \  
  qml-module-qt-websockets python3-docopt python3-numpy python3-pyaudio python3-cffi python3-websockets \
  cmake extra-cmake-modules g++ qtbase5-dev qtdeclarative5-dev libqt5x11extras5-dev libkf5plasma-dev libkf5xmlgui-dev \
  sassc

# Dependencies
apt-mark auto \
  qml-module-qt-websockets python3-docopt python3-numpy python3-pyaudio python3-cffi python3-websockets \
  cmake extra-cmake-modules g++ qtbase5-dev qtdeclarative5-dev libqt5x11extras5-dev libkf5plasma-dev libkf5xmlgui-dev \
  sassc
    
clear
############################## Plasma Addons ###############################

# Installing Panon
cd /home/${user}/Downloads
git clone https://github.com/rbn42/panon.git
cd panon
git submodule update --init
su - ${user} << EOF
kpackagetool5 -t Plasma/Applet --install /home/${user}/Downloads/panon/plasmoid
EOF

# Installing Virtual Desktop Bar
cd /home/${user}/Downloads
git clone https://github.com/wsdfhjxc/virtual-desktop-bar.git
cd virtual-desktop-bar
./scripts/install-applet.sh

clear
################################# Config #################################

# Autostart
cd /home/${user}/.config/autostart-scripts
echo "#!/bin/bash
# Keyboard LED
xset led 3
# Update Panon
kpackagetool5 -t Plasma/Applet --upgrade /home/${user}/Downloads/panon/plasmoid
# Update Virtual Desktop Bar
/bin/bash /home/${user}/Downloads/virtual-desktop-bar/scripts/install-applet.sh
" > startup.sh
chmod +x startup.sh

clear
################################## Theme ##################################

# GTK
cd /home/${user}/Downloads/
git clone https://github.com/vinceliuice/Qogir-theme
cd Qogir-theme
./install.sh

# KDE
cd /home/${user}/Downloads/
git clone https://github.com/vinceliuice/Qogir-kde
su - ${user} /home/${user}/Downloads/Qogir-kde/install.sh
cd Qogir-kde/sddm
./install.sh

# Icons
cd /home/${user}/Downloads/
git clone https://github.com/vinceliuice/Qogir-icon-theme
cd Qogir-icon-theme
./install.sh
sed -i 's/xcursor-breeze/Qogir-dark/g' /usr/share/icons/default/index.theme

clear
############################## Housekeeping ###############################

# Clean packages
apt autoremove --purge -y
apt autoclean

# Change owner
chown -R ${user} /home/${user}
