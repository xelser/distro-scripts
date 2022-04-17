# My Distro Setups
These setups are accompanied by the scripts and for personal use ***ideally***.
### Clone the repo
```
git clone https://github.com/xelser/distro-scripts
./distro-scripts/install.sh
```
---
## :: Fedora (GNOME) ::
### GNOME Shell Extensions
> Visit [GNOME Shell Extension Website](https://extensions.gnome.org/) for more extensions
- [Alphabetical App Grid](https://extensions.gnome.org/extension/4269/alphabetical-app-grid/)
- [Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
- [Espresso](https://extensions.gnome.org/extension/4135/espresso/)
- [Gnome 40 UI Improvements](https://extensions.gnome.org/extension/4158/gnome-40-ui-improvements/)
- [Quick Close in Overview](https://extensions.gnome.org/extension/352/middle-click-to-close-in-overview/)
- [Top Panel Workspace Scroll](https://extensions.gnome.org/extension/701/top-panel-workspace-scroll/)
- [Windows Is Ready - Notification Remover](https://extensions.gnome.org/extension/1007/window-is-ready-notification-remover/)

#### Zoom: Enable Wayland screen share
> Some configurations for some apps
```
sed -i 's/enableWaylandShare=false/enableWaylandShare=true/g' $HOME/.var/app/us.zoom.Zoom/config/zoomus.conf
```
##### Recommendations
> Just in case you need to setup these again.
- [rEFInd](https://www.rodsbooks.com/refind/getting.html) | [Theme](https://github.com/bobafetthotmail/refind-theme-regular)
> Already Included in the script. Download the `.rpm` again if needs to be updated.
- [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor/releases) | Theme : `Modern-Classic`


## :: Manjaro (KDE Plasma) ::
### Plasma 5 Applets
> Install the applets using the built-in store
- Minimal Menu
- Window Title Applet
- Latte Separator
- Latte Spacer
- Better Inline Clock
- Shutdown or Switch
