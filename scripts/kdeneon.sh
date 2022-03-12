#!/bin/bash
set -e
clear

user="nikki"

############################ Pre-installation ############################

# mkdir
mkdir /home/${user}/Github

# Fix update
touch /var/lib/man-db/auto-update
mandb -pq

clear
################################ Packages #################################

# Update
pkcon update

# Install
apt install -y \
    htop neofetch gparted timeshift \
    ktorrent qt5-style-kvantum lxappearance \
    cmake extra-cmake-modules qtdeclarative5-dev libqt5x11extras5-dev libkf5iconthemes-dev libkf5plasma-dev libkf5windowsystem-dev \
    libkf5declarative-dev libkf5xmlgui-dev libkf5activities-dev build-essential libxcb-util-dev libkf5wayland-dev git gettext \
    libkf5archive-dev libkf5notifications-dev libxcb-util0-dev libsm-dev libkf5crash-dev libkf5newstuff-dev libxcb-shape0-dev \
    libxcb-randr0-dev libx11-dev libx11xcb-dev kirigami2-dev \
    qml-module-qt-websockets python3-docopt python3-numpy python3-pyaudio python3-cffi python3-websockets \
    cmake extra-cmake-modules g++ qtbase5-dev qtdeclarative5-dev libqt5x11extras5-dev libkf5plasma-dev libkf5globalaccel-dev libkf5xmlgui-dev \
    sassc

apt-mark auto \
    cmake extra-cmake-modules qtdeclarative5-dev libqt5x11extras5-dev libkf5iconthemes-dev libkf5plasma-dev libkf5windowsystem-dev \
    libkf5declarative-dev libkf5xmlgui-dev libkf5activities-dev build-essential libxcb-util-dev libkf5wayland-dev git gettext \
    libkf5archive-dev libkf5notifications-dev libxcb-util0-dev libsm-dev libkf5crash-dev libkf5newstuff-dev libxcb-shape0-dev \
    libxcb-randr0-dev libx11-dev libx11xcb-dev kirigami2-dev \
    qml-module-qt-websockets python3-docopt python3-numpy python3-pyaudio python3-cffi python3-websockets \
    cmake extra-cmake-modules g++ qtbase5-dev qtdeclarative5-dev libqt5x11extras5-dev libkf5plasma-dev libkf5globalaccel-dev libkf5xmlgui-dev \
    sassc

clear
############################## Plasma Addons ###############################

# Installing Latte Dock Git
cd /home/${user}/Github
git clone https://github.com/KDE/latte-dock.git
cd latte-dock
sh install.sh

# Installing Virtual Desktop Bar
cd /home/${user}/Github
git clone https://github.com/wsdfhjxc/virtual-desktop-bar.git
cd virtual-desktop-bar
./scripts/install-applet.sh

# Installing Panon
cd /home/${user}/Github
git clone https://github.com/rbn42/panon.git
cd panon
git submodule update --init
su - ${user} << EOF
kpackagetool5 -t Plasma/Applet --install ~/Github/panon/plasmoid
EOF

clear
################################# Config #################################

# Autostart
cd /home/${user}/.config/autostart-scripts
echo "#!/bin/bash
# Keyboard LED
xset led 3
# Update Panon
kpackagetool5 -t Plasma/Applet --upgrade ~/Github/panon/plasmoid
# Update Virtual Desktop Bar
/bin/bash ~/Github/virtual-desktop-bar/scripts/install-applet.sh
" > startup.sh
chmod +x startup.sh

clear
################################## Theme ##################################

# KDE
cd /home/${user}/Github
git clone https://github.com/vinceliuice/Qogir-kde
cd Qogir-kde
#su - ${user} << EOF
#./install.sh
#EOF
cd sddm
./install.sh

# GTK
cd /home/${user}/Github
git clone https://github.com/vinceliuice/Qogir-theme
cd Qogir-theme
./install.sh

# Icons
cd /home/${user}/Github
git clone https://github.com/vinceliuice/Qogir-icon-theme
cd Qogir-icon-theme
./install.sh
sed -i 's/breeze_cursors/Qogir-dark/g' /usr/share/icons/default/index.theme

clear
############################## Housekeeping ###############################

# Clean packages
chown -R ${user} /home/${user}
apt autoremove --purge -y
apt autoclean
